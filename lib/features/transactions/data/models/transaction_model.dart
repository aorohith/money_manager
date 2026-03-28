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

  late bool isDeleted;
}

enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}
