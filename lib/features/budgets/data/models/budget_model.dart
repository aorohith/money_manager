import 'package:isar/isar.dart';

part 'budget_model.g.dart';

enum BudgetPeriod { monthly, weekly, yearly }

@collection
class BudgetModel {
  BudgetModel({
    required this.limitAmount,
    required this.period,
    required this.month,
    this.categoryId,
    this.rolloverEnabled = false,
  });

  Id id = Isar.autoIncrement;

  /// null = overall / total budget; non-null = per-category budget
  @Index()
  int? categoryId;

  double limitAmount;

  @enumerated
  BudgetPeriod period;

  /// YYYYMM (e.g. 202503 for March 2025); 0 = all-time
  @Index()
  int month;

  bool rolloverEnabled;

  /// Extra amount rolled over from previous period (added to limit effectively)
  double rolloverAmount = 0;
}
