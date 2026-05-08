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

  @enumerated
  late RecurrenceType recurrence;

  @enumerated
  late TransactionEntryType entryType;

  late bool isDeleted;

  /// Last write timestamp — used for future cloud sync conflict resolution.
  @Index()
  DateTime updatedAt = DateTime.now();

  /// Reserved for future multi-user / cloud sync. Null = local-only record.
  String? userId;
}

enum RecurrenceType { none, daily, weekly, monthly, yearly }

enum TransactionEntryType { regular, adjustment }
