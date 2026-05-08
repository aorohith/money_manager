import 'package:isar/isar.dart';

import '../../../transactions/data/repositories/transaction_repository.dart';
import '../models/budget_model.dart';

// ── BudgetProgress value object ───────────────────────────────────────────────

enum BudgetColorState { onTrack, moderate, runningLow, over }

class BudgetProgress {
  const BudgetProgress({
    required this.budget,
    required this.spent,
    required this.daysInPeriod,
    required this.daysElapsed,
  });

  final BudgetModel budget;
  final double spent;
  final int daysInPeriod;
  final int daysElapsed;

  double get effectiveLimit => budget.limitAmount + budget.rolloverAmount;
  double get remaining => effectiveLimit - spent;
  double get percentage => effectiveLimit == 0 ? 0 : spent / effectiveLimit;
  bool get isOver => spent > effectiveLimit;

  double get dailyAllowance {
    final daysLeft = daysInPeriod - daysElapsed;
    if (daysLeft <= 0) return 0;
    return remaining / daysLeft;
  }

  double get projectedMonthEnd {
    if (daysElapsed == 0) return 0;
    return (spent / daysElapsed) * daysInPeriod;
  }

  BudgetColorState get colorState {
    if (isOver) return BudgetColorState.over;
    if (percentage >= 0.80) return BudgetColorState.runningLow;
    if (percentage >= 0.50) return BudgetColorState.moderate;
    return BudgetColorState.onTrack;
  }

  String get statusLabel {
    if (isOver) {
      return 'Over by \$${(-remaining).toStringAsFixed(0)}';
    }
    if (colorState == BudgetColorState.runningLow) {
      return 'Running low';
    }
    if (colorState == BudgetColorState.moderate) {
      return 'Moderate spend';
    }
    return 'On track 🎯';
  }
}

// ── Repository ────────────────────────────────────────────────────────────────

abstract class BudgetRepository {
  Future<void> setBudget(BudgetModel budget);
  Future<List<BudgetModel>> getBudgetsForMonth(int month);
  Future<BudgetProgress> getBudgetProgress({
    required BudgetModel budget,
    required int month,
  });
  Future<void> deleteBudget(Id id);
  Future<BudgetModel?> getOverallBudget(int month);
  Stream<List<BudgetModel>> watchBudgetsForMonth(int month);
}

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._isar, this._transactionRepo);

  final Isar _isar;
  final TransactionRepository _transactionRepo;

  @override
  Future<void> setBudget(BudgetModel budget) async {
    budget.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.budgetModels.put(budget);
    });
  }

  @override
  Future<List<BudgetModel>> getBudgetsForMonth(int month) async {
    return _isar.budgetModels
        .filter()
        .monthEqualTo(month)
        .findAll();
  }

  @override
  Stream<List<BudgetModel>> watchBudgetsForMonth(int month) {
    return _isar.budgetModels
        .filter()
        .monthEqualTo(month)
        .watch(fireImmediately: true);
  }

  @override
  Future<BudgetModel?> getOverallBudget(int month) async {
    final results = await _isar.budgetModels
        .filter()
        .monthEqualTo(month)
        .categoryIdIsNull()
        .findAll();
    return results.firstOrNull;
  }

  @override
  Future<BudgetProgress> getBudgetProgress({
    required BudgetModel budget,
    required int month,
  }) async {
    final year = month ~/ 100;
    final mo = month % 100;
    final from = DateTime(year, mo, 1);
    final to = DateTime(year, mo + 1, 1).subtract(const Duration(microseconds: 1));
    final now = DateTime.now();

    final daysInPeriod = DateTime(year, mo + 1, 0).day;
    final daysElapsed = now.isBefore(from)
        ? 0
        : now.isAfter(to)
            ? daysInPeriod
            : now.difference(from).inDays + 1;

    final double spent;
    if (budget.categoryId == null) {
      spent = await _transactionRepo.getTotalExpense(from: from, to: to);
    } else {
      final summary = await _transactionRepo.getCategorySummary(
          isIncome: false, from: from, to: to);
      spent = summary[budget.categoryId] ?? 0.0;
    }

    return BudgetProgress(
      budget: budget,
      spent: spent,
      daysInPeriod: daysInPeriod,
      daysElapsed: daysElapsed,
    );
  }

  @override
  Future<void> deleteBudget(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.budgetModels.delete(id);
    });
  }
}
