import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/data/models/category_model.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/providers/transaction_providers.dart';

// ── Period selector ──────────────────────────────────────────────────────────

enum DashboardPeriod { thisMonth, lastMonth, last3Months }

final dashboardPeriodProvider =
    StateProvider<DashboardPeriod>((_) => DashboardPeriod.thisMonth);

// ── Dashboard data model ─────────────────────────────────────────────────────

class DashboardData {
  const DashboardData({
    required this.totalIncome,
    required this.totalExpense,
    required this.recentTransactions,
    required this.categoryExpenseSummary,
    required this.categories,
    required this.todayExpense,
    required this.weekExpense,
  });

  final double totalIncome;
  final double totalExpense;
  final List<TransactionModel> recentTransactions;

  /// categoryId → total expense amount (for the spending ring)
  final Map<int, double> categoryExpenseSummary;
  final List<CategoryModel> categories;

  final double todayExpense;
  final double weekExpense;

  double get netBalance => totalIncome - totalExpense;

  static const empty = DashboardData(
    totalIncome: 0,
    totalExpense: 0,
    recentTransactions: [],
    categoryExpenseSummary: {},
    categories: [],
    todayExpense: 0,
    weekExpense: 0,
  );
}

// ── Dashboard provider (stream — reacts to new transactions) ─────────────────

/// Streams [DashboardData] for the selected [DashboardPeriod].
///
/// Uses [TransactionRepository.watchAll] as the trigger so the dashboard
/// automatically refreshes whenever a transaction is added, edited, or deleted.
/// All heavy queries inside the loop are parallelised with [Future.wait].
final dashboardProvider =
    StreamProvider.autoDispose<DashboardData>((ref) async* {
  final period = ref.watch(dashboardPeriodProvider);
  final repo = ref.read(transactionRepositoryProvider);
  final categoryRepo = ref.read(categoryRepositoryProvider);

  final (from, to) = _periodRange(period);

  // Re-emit whenever Isar changes.
  await for (final _ in repo.watchAll(from: from, to: to)) {
    // Run all queries concurrently for performance.
    final results = await Future.wait([
      repo.getTotalIncome(from: from, to: to),
      repo.getTotalExpense(from: from, to: to),
      repo.getAll(from: from, to: to),
      repo.getCategorySummary(isIncome: false, from: from, to: to),
      categoryRepo.getAll(),
      _getTodayExpense(repo),
      _getWeekExpense(repo),
    ]);

    // Unpack into named variables before use.  This keeps the mapping
    // explicit so that any future reordering of the list above is caught
    // immediately at the cast site rather than silently producing wrong data.
    final totalIncome        = results[0] as double;
    final totalExpense       = results[1] as double;
    final allTransactions    = results[2] as List<TransactionModel>;
    final categorySummary    = results[3] as Map<int, double>;
    final categories         = results[4] as List<CategoryModel>;
    final todayExpense       = results[5] as double;
    final weekExpense        = results[6] as double;

    yield DashboardData(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      recentTransactions: allTransactions.take(5).toList(),
      categoryExpenseSummary: categorySummary,
      categories: categories,
      todayExpense: todayExpense,
      weekExpense: weekExpense,
    );
  }
});

/// Returns the inclusive [from, to) date range for a given [DashboardPeriod].
///
/// The end of range is always set to 1 microsecond before midnight of the
/// next period's start so that Isar's `dateLessThan` filter captures the
/// last transaction of the day without crossing into the following period.
(DateTime, DateTime) _periodRange(DashboardPeriod period) {
  final now = DateTime.now();
  switch (period) {
    case DashboardPeriod.thisMonth:
      return (
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(microseconds: 1))
      );
    case DashboardPeriod.lastMonth:
      final last = DateTime(now.year, now.month - 1, 1);
      return (
        last,
        DateTime(now.year, now.month, 1)
            .subtract(const Duration(microseconds: 1))
      );
    case DashboardPeriod.last3Months:
      return (
        DateTime(now.year, now.month - 2, 1),
        DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(microseconds: 1))
      );
  }
}

Future<double> _getTodayExpense(dynamic repo) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  return repo.getTotalExpense(from: start, to: end);
}

Future<double> _getWeekExpense(dynamic repo) async {
  final now = DateTime.now();
  final start =
      DateTime(now.year, now.month, now.day - now.weekday + 1); // Monday
  return repo.getTotalExpense(from: start);
}
