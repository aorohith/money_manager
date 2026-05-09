import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';

class SetBudgetUseCase {
  const SetBudgetUseCase(this._repo);
  final BudgetRepository _repo;

  Future<AsyncValue<void>> call(BudgetModel budget) async {
    try {
      await _repo.setBudget(budget);
      return const AsyncData(null);
    } catch (e, s) {
      return AsyncError(e, s);
    }
  }
}

class DeleteBudgetUseCase {
  const DeleteBudgetUseCase(this._repo);
  final BudgetRepository _repo;

  Future<AsyncValue<void>> call(Id id) async {
    try {
      await _repo.deleteBudget(id);
      return const AsyncData(null);
    } catch (e, s) {
      return AsyncError(e, s);
    }
  }
}

class GetBudgetsUseCase {
  const GetBudgetsUseCase(this._repo);
  final BudgetRepository _repo;

  Future<AsyncValue<List<BudgetModel>>> call(int month) async {
    try {
      final budgets = await _repo.getBudgetsForMonth(month);
      return AsyncData(budgets);
    } catch (e, s) {
      return AsyncError(e, s);
    }
  }
}

class GetBudgetProgressUseCase {
  const GetBudgetProgressUseCase(this._repo);
  final BudgetRepository _repo;

  Future<AsyncValue<BudgetProgress>> call({
    required BudgetModel budget,
    required int month,
    String? baseCurrencyCode,
  }) async {
    try {
      final progress = await _repo.getBudgetProgress(
        budget: budget,
        month: month,
        baseCurrencyCode: baseCurrencyCode,
      );
      return AsyncData(progress);
    } catch (e, s) {
      return AsyncError(e, s);
    }
  }
}

/// Returns rollover amount from previous month.
double computeRollover({
  required double previousLimit,
  required double previousSpent,
}) {
  final unspent = previousLimit - previousSpent;
  return unspent > 0 ? unspent : 0;
}
