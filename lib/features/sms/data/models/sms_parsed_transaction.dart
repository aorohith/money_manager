import 'package:isar/isar.dart';
import 'package:money_manager/core/sms/sms_parser_types.dart';

part 'sms_parsed_transaction.g.dart';

/// A banking notification that has been parsed and is awaiting user review.
@collection
class SmsParsedTransaction {
  SmsParsedTransaction({
    required this.amount,
    required this.merchantRaw,
    required this.merchantNormalized,
    required this.transactionDate,
    required this.paymentMethod,
    required this.rawText,
    required this.senderAddress,
    this.accountHint,
    this.availableBalance,
    this.referenceNumber,
    this.suggestedCategoryId,
    this.confidence,
    this.status = SmsReviewStatus.pending,
    this.linkedTransactionId,
    this.isIncome = false,
    this.directionConfidence,
    this.directionSignals,
    this.merchantExtractionSource,
    this.counterpartyType = SmsCounterpartyType.unknown,
    this.isRecurring = false,
    this.merchantIdentityId,
    this.counterpartyVpa,
  });

  Id id = Isar.autoIncrement;

  @Index()
  late double amount;

  /// Original merchant string from the notification, e.g. "UPI-Swiggy India Pvt".
  late String merchantRaw;

  /// Uppercase-normalised key used for rule matching, e.g. "SWIGGY".
  @Index()
  late String merchantNormalized;

  @Index()
  late DateTime transactionDate;

  /// "UPI", "Credit Card", "Debit Card", "Wallet", "Net Banking", "Unknown"
  late String paymentMethod;

  /// Last 4 digits hint, e.g. "XX1234".
  String? accountHint;

  double? availableBalance;
  String? referenceNumber;

  /// Full raw notification body kept for debugging / user reference.
  late String rawText;

  late String senderAddress;

  @enumerated
  late SmsReviewStatus status;

  int? suggestedCategoryId;

  /// 0.0 – 1.0. Reflects categorization engine confidence.
  double? confidence;

  @Index()
  late bool isIncome;

  /// 0.0–1.0. How confident the parser is about expense vs income.
  double? directionConfidence;

  /// Comma-separated direction signals matched in the raw message.
  String? directionSignals;

  /// Parser strategy label, e.g. "upiTo", "infoBlock".
  String? merchantExtractionSource;

  @enumerated
  SmsCounterpartyType counterpartyType = SmsCounterpartyType.unknown;

  bool isRecurring = false;

  /// Links this record to a [MerchantIdentityModel] for identity-based
  /// suggestions and category scoring.
  int? merchantIdentityId;

  /// UPI VPA extracted from the message, e.g. "9562802757@superyes".
  String? counterpartyVpa;

  DateTime detectedAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  /// Set once the user approves → linked TransactionModel id.
  int? linkedTransactionId;
}

enum SmsReviewStatus { pending, approved, skipped, duplicate }
