import 'package:isar/isar.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  TransactionModel({
    required this.amount,
    required this.categoryId,
    required this.accountId,
    required this.date,
    required this.isIncome,
    this.note,
    this.tags = const [],
    this.currencyCode,
    this.originalAmount,
    this.originalCurrencyCode,
    this.fxRate,
    this.transferGroupId,
    this.importBatchId,
    this.recurrence = RecurrenceType.none,
    this.entryType = TransactionEntryType.regular,
    this.isDeleted = false,
  });

  Id id = Isar.autoIncrement;

  @Index()
  late double amount;

  @Index()
  late int categoryId;

  @Index()
  late int accountId;

  @Index()
  late DateTime date;

  @Index()
  late bool isIncome;

  String? note;

  @Index(type: IndexType.value)
  late List<String> tags;

  /// Currency used by [amount]. Defaults to the app currency for manual rows.
  String? currencyCode;

  /// Original amount/currency from imported data when it differs from [amount].
  double? originalAmount;
  String? originalCurrencyCode;

  /// Conversion rate from [originalAmount] into [amount], when available.
  double? fxRate;

  @enumerated
  late RecurrenceType recurrence;

  @enumerated
  late TransactionEntryType entryType;

  late bool isDeleted;

  /// Shared by the two rows that represent one account-to-account transfer.
  @Index()
  String? transferGroupId;

  /// Import batch that created this row. Enables future import history/undo.
  @Index()
  String? importBatchId;

  /// Last write timestamp — used for future cloud sync conflict resolution.
  @Index()
  DateTime updatedAt = DateTime.now();

  /// Reserved for future multi-user / cloud sync. Null = local-only record.
  String? userId;
}

enum RecurrenceType { none, daily, weekly, monthly, yearly }

enum TransactionEntryType { regular, adjustment, transfer }
