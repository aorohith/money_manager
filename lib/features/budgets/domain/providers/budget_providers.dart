import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/isar_service.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../transactions/domain/providers/transaction_providers.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';
import '../../domain/usecases/budget_usecases.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final isar = ref.read(isarProvider);
  final txRepo = ref.read(transactionRepositoryProvider);
  return BudgetRepositoryImpl(isar, txRepo);
});

// ── Use cases ─────────────────────────────────────────────────────────────────

final setBudgetUseCaseProvider = Provider<SetBudgetUseCase>((ref) {
  return SetBudgetUseCase(ref.read(budgetRepositoryProvider));
});

final deleteBudgetUseCaseProvider = Provider<DeleteBudgetUseCase>((ref) {
  return DeleteBudgetUseCase(ref.read(budgetRepositoryProvider));
});

final getBudgetsUseCaseProvider = Provider<GetBudgetsUseCase>((ref) {
  return GetBudgetsUseCase(ref.read(budgetRepositoryProvider));
});

// ── Selected month state ──────────────────────────────────────────────────────

/// Returns YYYYMM integer for a DateTime.
int toMonthInt(DateTime dt) => dt.year * 100 + dt.month;

final budgetSelectedMonthProvider = StateProvider<int>(
  (_) => toMonthInt(DateTime.now()),
);

// ── Budget list stream ────────────────────────────────────────────────────────

final budgetListProvider =
    StreamProvider.autoDispose.family<List<BudgetModel>, int>((ref, month) {
  final repo = ref.read(budgetRepositoryProvider);
  return repo.watchBudgetsForMonth(month);
});

// ── Budget progress list ──────────────────────────────────────────────────────

/// For the selected month: computes BudgetProgress for each budget.
/// Re-computed when budgetList or transactionList changes.
final budgetProgressListProvider =
    FutureProvider.autoDispose<List<BudgetProgress>>((ref) async {
  final month = ref.watch(budgetSelectedMonthProvider);
  final budgetsAsync = ref.watch(budgetListProvider(month));
  // Watch transactions to invalidate when they change
  ref.watch(transactionListProvider);

  final budgets = budgetsAsync.valueOrNull ?? [];
  if (budgets.isEmpty) return [];

  final repo = ref.read(budgetRepositoryProvider);
  final progressList = await Future.wait(
    budgets.map((b) => repo.getBudgetProgress(budget: b, month: month)),
  );

  final symbol = ref.read(currencySymbolProvider).valueOrNull ?? '\$';
  for (final p in progressList) {
    if (p.isOver) {
      unawaited(NotificationService.instance.showBudgetOverAlert(
        budgetId: p.budget.id,
        budgetName:
            p.budget.categoryId == null ? 'Overall Budget' : 'Category Budget',
        overBy: p.spent - p.effectiveLimit,
        currencySymbol: symbol,
      ));
    }
  }

  return progressList;
});

// ── Overall budget progress ───────────────────────────────────────────────────

final overallBudgetProgressProvider =
    FutureProvider.autoDispose<BudgetProgress?>((ref) async {
  final month = ref.watch(budgetSelectedMonthProvider);
  final repo = ref.read(budgetRepositoryProvider);
  final overall = await repo.getOverallBudget(month);
  if (overall == null) return null;
  return repo.getBudgetProgress(budget: overall, month: month);
});
