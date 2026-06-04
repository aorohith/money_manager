/// Pure Dart SMS/notification parser for Indian banking messages.
library;

export 'sms_parser_types.dart';

import 'extraction/amount_extractor.dart';
import 'extraction/date_extractor.dart';
import 'extraction/direction_scorer.dart';
import 'extraction/internal_transfer_detector.dart';
import 'extraction/merchant_extractor.dart';
import 'extraction/noise_filter.dart';
import 'extraction/payment_method_detector.dart';
import 'extraction/rejection_filter.dart';
import 'extraction/subscription_detector.dart';
import 'sms_parser_types.dart';

class ParsedSmsData {
  const ParsedSmsData({
    required this.amount,
    required this.merchantRaw,
    required this.merchantNormalized,
    required this.paymentMethod,
    required this.transactionDate,
    required this.direction,
    required this.directionConfidence,
    required this.directionSignals,
    this.accountHint,
    this.availableBalance,
    this.referenceNumber,
    this.isIncome = false,
    this.merchantExtractionSource,
    this.counterpartyType = SmsCounterpartyType.unknown,
    this.isRecurring = false,
    this.isInternalTransfer = false,
    this.counterpartyVpa,
  });

  final double amount;
  final String merchantRaw;
  final String merchantNormalized;
  final String paymentMethod;
  final DateTime transactionDate;
  final String? accountHint;
  final double? availableBalance;
  final String? referenceNumber;
  final TransactionDirection direction;
  final double directionConfidence;
  final String directionSignals;
  final bool isIncome;
  final MerchantExtractionSource? merchantExtractionSource;
  final SmsCounterpartyType counterpartyType;
  final bool isRecurring;
  final bool isInternalTransfer;

  /// UPI VPA extracted from the SMS (e.g. "9562802757@superyes").
  /// Used to link transactions to a [MerchantIdentityModel] by handle.
  final String? counterpartyVpa;
}

/// Injectable SMS parser — create via [TransactionParser()] or use the
/// singleton [TransactionParser.instance] for convenience.
class TransactionParser {
  const TransactionParser();

  static const TransactionParser instance = TransactionParser();

  static final _balanceRe = RegExp(
    r'(?:Avl?\.?\s*[Bb]al\.?|Avbl\.?\s*[Bb]al\.?|Available\s+Bal(?:ance)?|[Bb]alance)\s*(?:is|:)?\s*(?:Rs\.?|INR|₹)\s*(\d[\d,\.]*)',
    caseSensitive: false,
  );

  static final _accountRe = RegExp(
    r'(?:[AaXx]{2,4}[-\s]?)(\d{4})\b|(?:ending|End(?:ing)?)\s+(\d{4})\b|Card\s+\*+(\d{4})\b',
    caseSensitive: false,
  );

  static final _refRe = RegExp(
    r'(?:Ref(?:\.?\s*No\.?)?|UTR|UPI\s+Ref|Txn(?:\s+ID)?)\s*[:\s]?\s*(\d{8,20})',
    caseSensitive: false,
  );

  static final _cardNumberRe =
      RegExp(r'\b\d{4}[\s\-]?\d{4}[\s\-]?\d{4}[\s\-]?\d{4}\b');

  static final _longAccountRe = RegExp(r'(?<![.,\d])\d{10,12}(?![.,\d])');

  DirectionResult detectDirection(
    String text, {
    bool detectRefunds = true,
    int? amountIndex,
  }) =>
      SmsDirectionScorer.detect(
        text,
        detectRefunds: detectRefunds,
        amountIndex: amountIndex,
      );

  /// Returns null when the text is not a debit/credit banking message.
  ParsedSmsData? parse(
    String text, {
    DateTime? overrideDate,
    bool detectRefunds = true,
    bool detectSubscriptions = false,
  }) {
    if (SmsRejectionFilter.shouldReject(text)) return null;

    if (SmsInternalTransferDetector.shouldSkip(text)) {
      return null;
    }

    final directionAnchor = RegExp(
      r'\b(?:debited|credited|spent|received|paid|sent|withdrawn)\b',
      caseSensitive: false,
    ).firstMatch(text)?.start;

    final amountMatch = SmsAmountExtractor.extract(
      text,
      directionAnchor: directionAnchor,
    );
    if (amountMatch == null) return null;

    final directionResult = SmsDirectionScorer.detect(
      text,
      detectRefunds: detectRefunds,
      amountIndex: amountMatch.start,
    );
    if (directionResult.confidence <= 0) return null;

    final isIncome =
        directionResult.direction == TransactionDirection.income;
    final direction =
        directionResult.direction == TransactionDirection.ambiguous
            ? TransactionDirection.ambiguous
            : directionResult.direction;

    final merchant = SmsMerchantExtractor.extract(text);
    final fallbackDate = overrideDate ?? DateTime.now();
    final transactionDate =
        SmsDateExtractor.extract(text, fallbackDate) ?? fallbackDate;

    final balanceMatch = _balanceRe.firstMatch(text);
    final availableBalance = balanceMatch != null
        ? double.tryParse(
            balanceMatch.group(1)!.replaceAll(',', '').replaceAll(' ', ''))
        : null;

    final accountMatch = _accountRe.firstMatch(text);
    final last4 = accountMatch?.group(1) ??
        accountMatch?.group(2) ??
        accountMatch?.group(3);
    final accountHint = last4 != null ? 'XX$last4' : null;

    final refMatch = _refRe.firstMatch(text);
    final referenceNumber = refMatch?.group(1);

    return ParsedSmsData(
      amount: amountMatch.amount,
      merchantRaw: merchant.raw,
      merchantNormalized: SmsNoiseFilter.normalizeMerchantKey(merchant.raw),
      paymentMethod: SmsPaymentMethodDetector.detect(text),
      transactionDate: transactionDate,
      accountHint: accountHint,
      availableBalance: availableBalance,
      referenceNumber: referenceNumber,
      direction: direction,
      directionConfidence: directionResult.confidence,
      directionSignals: directionResult.matchedSignals.join(','),
      isIncome: isIncome,
      merchantExtractionSource: merchant.source,
      counterpartyType: merchant.counterpartyType,
      counterpartyVpa: merchant.vpa,
      isRecurring: SmsSubscriptionDetector.isLikelySubscription(
        text,
        enabled: detectSubscriptions,
      ),
    );
  }

  static String buildFingerprint(
    double amount,
    String merchantNormalized,
    DateTime date, {
    String? referenceNumber,
  }) {
    if (referenceNumber != null && referenceNumber.length >= 8) {
      return '${amount.toStringAsFixed(2)}|$merchantNormalized|$referenceNumber';
    }
    final windowMinutes = (date.minute ~/ 5) * 5;
    final windowed =
        '${date.year}${date.month}${date.day}${date.hour}$windowMinutes';
    return '${amount.toStringAsFixed(2)}|$merchantNormalized|$windowed';
  }

  static String normalizeKey(String raw) =>
      SmsNoiseFilter.normalizeMerchantKey(raw);

  static String redactSensitive(String text) {
    var result = text.replaceAllMapped(
      _cardNumberRe,
      (_) => 'XXXX-XXXX-XXXX-XXXX',
    );
    result = result.replaceAllMapped(
      _longAccountRe,
      (m) {
        final s = m.group(0)!;
        return 'XX${s.substring(s.length - 4)}';
      },
    );
    return result;
  }
}
