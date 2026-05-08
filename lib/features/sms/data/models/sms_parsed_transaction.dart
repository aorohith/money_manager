import 'package:isar/isar.dart';

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

  DateTime detectedAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  /// Set once the user approves → linked TransactionModel id.
  int? linkedTransactionId;
}

enum SmsReviewStatus { pending, approved, skipped, duplicate }
