/// Pure Dart SMS/notification parser for Indian banking messages.
/// No external dependencies — runs synchronously on any isolate.
library;

class ParsedSmsData {
  const ParsedSmsData({
    required this.amount,
    required this.merchantRaw,
    required this.merchantNormalized,
    required this.paymentMethod,
    required this.transactionDate,
    this.accountHint,
    this.availableBalance,
    this.referenceNumber,
    this.isIncome = false,
  });

  final double amount;
  final String merchantRaw;
  final String merchantNormalized;
  final String paymentMethod;
  final DateTime transactionDate;
  final String? accountHint;
  final double? availableBalance;
  final String? referenceNumber;
  final bool isIncome;
}

/// Injectable SMS parser — create via [TransactionParser()] or use the
/// singleton [TransactionParser.instance] for convenience.
///
/// Using a regular constructor makes this mockable/swappable in tests.
class TransactionParser {
  const TransactionParser();

  /// Convenience singleton — prefer injecting [TransactionParser()] via
  /// Riverpod so tests can substitute a mock.
  static const TransactionParser instance = TransactionParser();

  // ── Amount ────────────────────────────────────────────────────────────────

  static final _amountRe = RegExp(
    r'(?:Rs\.?|INR|₹)\s*(\d{1,3}(?:,\d{2,3})*(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // ── Debit signals ─────────────────────────────────────────────────────────

  static final _debitRe = RegExp(
    r'\b(?:debited?|spent|paid|withdrawn?|deducted|purchase[d]?|used)\b',
    caseSensitive: false,
  );

  // ── Credit / income signals ───────────────────────────────────────────────

  static final _creditRe = RegExp(
    r'\b(?:credited|received|deposited|refunded|cashback)\b',
    caseSensitive: false,
  );

  // ── Failure / reversal — these should be ignored ─────────────────────────

  static final _failureRe = RegExp(
    r'\b(?:fail(?:ed|ure)|declin(?:ed|e)|reversal?|reversed|blocked|rejected|unsuccessful)\b',
    caseSensitive: false,
  );

  // ── OTP / spam signals — ignore these messages ───────────────────────────

  static final _otpRe = RegExp(
    r'\b(?:OTP|one.time.password|verification.code|do not share)\b',
    caseSensitive: false,
  );

  // ── Merchant — UPI ────────────────────────────────────────────────────────

  static final _upiToRe = RegExp(
    r'(?:UPI[-\s]?|paid\s+to\s+|to\s+VPA\s+|to\s+)([A-Za-z][A-Za-z0-9\s&@._\-]{2,40}?)(?:\s+(?:on|via|ref|Ref|\.|UPI|\d)|$)',
    caseSensitive: false,
  );

  // ── Merchant — Card ("at MERCHANT on") ───────────────────────────────────

  static final _cardAtRe = RegExp(
    r'\bat\s+([A-Z][A-Z0-9\s&\-\./]{2,35}?)(?:\s+on\s+\d|\s+Avbl|\s+Avl|\.)',
  );

  // ── Merchant — "to MERCHANT" fallback ────────────────────────────────────

  static final _toMerchantRe = RegExp(
    r'\bto\s+([A-Za-z][A-Za-z0-9\s&\-]{2,30}?)(?:\s+(?:from|via|on|ref|\.)|\.|$)',
    caseSensitive: false,
  );

  // ── Available balance ─────────────────────────────────────────────────────

  static final _balanceRe = RegExp(
    r'(?:Avl?\.?\s*[Bb]al\.?|Avbl\.?\s*[Bb]al\.?|Available\s+Bal(?:ance)?|[Bb]alance)\s*(?:is|:)?\s*(?:Rs\.?|INR|₹)\s*(\d[\d,\.]*)',
    caseSensitive: false,
  );

  // ── Account hint (last 4 digits) ──────────────────────────────────────────

  static final _accountRe = RegExp(
    r'(?:[AaXx]{2,4}[-\s]?)(\d{4})\b',
  );

  // ── Reference / UTR number ────────────────────────────────────────────────

  static final _refRe = RegExp(
    r'(?:Ref(?:\.?\s*No\.?)?|UTR|UPI\s+Ref|Txn(?:\s+ID)?)\s*[:\s]?\s*(\d{8,20})',
    caseSensitive: false,
  );

  // ── Payment method keywords ───────────────────────────────────────────────

  static final _upiRe = RegExp(r'\bUPI\b', caseSensitive: false);
  static final _creditCardRe = RegExp(
      r'\bCredit\s+Card\b|\bCC\b|\bCredit Cd\b',
      caseSensitive: false);
  static final _debitCardRe = RegExp(
      r'\bDebit\s+Card\b|\bDC\b|\bDebit Cd\b',
      caseSensitive: false);
  static final _walletRe = RegExp(
      r'\bWallet\b|\bPaytm\b|\bPhonePe\b|\bMobikwik\b',
      caseSensitive: false);
  static final _netBankingRe =
      RegExp(r'\bNet\s?Banking\b|\bNEFT\b|\bIMPS\b|\bRTGS\b',
          caseSensitive: false);

  // ── Sensitive data patterns for redaction ─────────────────────────────────

  /// Full card numbers (16 digits, spaced or contiguous).
  static final _cardNumberRe =
      RegExp(r'\b\d{4}[\s\-]?\d{4}[\s\-]?\d{4}[\s\-]?\d{4}\b');

  /// Long account numbers (10–12 contiguous digits not preceded by a digit).
  static final _longAccountRe = RegExp(r'(?<![.,\d])\d{10,12}(?![.,\d])');

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns null when the text is not a debit/credit banking message.
  ParsedSmsData? parse(String text, {DateTime? overrideDate}) {
    // Hard reject: OTP, failures, reversals
    if (_otpRe.hasMatch(text)) return null;
    if (_failureRe.hasMatch(text)) return null;

    // Must contain an amount
    final amountMatch = _amountRe.firstMatch(text);
    if (amountMatch == null) return null;

    final amountStr = amountMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(amountStr);
    // Accept anything ≥ 0.01 to handle cashback fractions
    if (amount == null || amount < 0.01) return null;

    final isDebit = _debitRe.hasMatch(text);
    final isCredit = _creditRe.hasMatch(text);
    if (!isDebit && !isCredit) return null;

    // Merchant extraction — try in priority order
    final merchantRaw = _extractMerchant(text);

    final paymentMethod = _extractPaymentMethod(text);

    final balanceMatch = _balanceRe.firstMatch(text);
    final availableBalance = balanceMatch != null
        ? double.tryParse(
            balanceMatch.group(1)!.replaceAll(',', '').replaceAll(' ', ''))
        : null;

    final accountMatch = _accountRe.firstMatch(text);
    final accountHint =
        accountMatch != null ? 'XX${accountMatch.group(1)}' : null;

    final refMatch = _refRe.firstMatch(text);
    final referenceNumber = refMatch?.group(1);

    return ParsedSmsData(
      amount: amount,
      merchantRaw: merchantRaw,
      merchantNormalized: _normalize(merchantRaw),
      paymentMethod: paymentMethod,
      transactionDate: overrideDate ?? DateTime.now(),
      accountHint: accountHint,
      availableBalance: availableBalance,
      referenceNumber: referenceNumber,
      isIncome: isCredit && !isDebit,
    );
  }

  String _extractMerchant(String text) {
    // 1. UPI pattern
    final upiMatch = _upiToRe.firstMatch(text);
    if (upiMatch != null) {
      final m = upiMatch.group(1)?.trim() ?? '';
      if (m.isNotEmpty && !_looksLikeNoise(m)) return m;
    }

    // 2. Card "at MERCHANT" pattern
    final cardMatch = _cardAtRe.firstMatch(text);
    if (cardMatch != null) {
      final m = cardMatch.group(1)?.trim() ?? '';
      if (m.isNotEmpty && !_looksLikeNoise(m)) return m;
    }

    // 3. "to MERCHANT" fallback
    final toMatch = _toMerchantRe.firstMatch(text);
    if (toMatch != null) {
      final m = toMatch.group(1)?.trim() ?? '';
      if (m.isNotEmpty && !_looksLikeNoise(m)) return m;
    }

    return 'Unknown Merchant';
  }

  bool _looksLikeNoise(String s) {
    // Reject pure numbers, account numbers, short strings
    if (s.length < 3) return true;
    if (RegExp(r'^\d+$').hasMatch(s)) return true;
    if (s.toLowerCase().contains('account')) return true;
    if (s.toLowerCase().contains('your')) return true;
    return false;
  }

  String _extractPaymentMethod(String text) {
    if (_upiRe.hasMatch(text)) return 'UPI';
    if (_creditCardRe.hasMatch(text)) return 'Credit Card';
    if (_debitCardRe.hasMatch(text)) return 'Debit Card';
    if (_walletRe.hasMatch(text)) return 'Wallet';
    if (_netBankingRe.hasMatch(text)) return 'Net Banking';
    return 'Unknown';
  }

  // ── Static helpers ────────────────────────────────────────────────────────

  /// Normalises a raw merchant string to an uppercase key for rule matching.
  static String _normalize(String raw) {
    return raw
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Generates a dedup fingerprint (not cryptographic, good enough for local use).
  static String buildFingerprint(
      double amount, String merchantNormalized, DateTime date) {
    // 5-minute time window: two notifications for the same tx arriving seconds
    // apart (bank SMS + app notification) will produce the same fingerprint.
    final windowMinutes = (date.minute ~/ 5) * 5;
    final windowed =
        '${date.year}${date.month}${date.day}${date.hour}$windowMinutes';
    return '${amount.toStringAsFixed(2)}|$merchantNormalized|$windowed';
  }

  /// Returns a normalised merchant key (public helper used by the engine).
  static String normalizeKey(String raw) => _normalize(raw);

  /// Redacts full card numbers and long account number sequences from raw
  /// notification text before storing it.  Amounts, merchant names, and
  /// reference numbers (≤ 9 digits) are preserved.
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
