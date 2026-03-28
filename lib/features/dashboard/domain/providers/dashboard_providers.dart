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

final dashboardProvider =
    StreamProvider.autoDispose<DashboardData>((ref) async* {
  final period = ref.watch(dashboardPeriodProvider);
  final repo = ref.read(transactionRepositoryProvider);
  final categoryRepo = ref.read(categoryRepositoryProvider);

  final (from, to) = _periodRange(period);

  // Re-emit whenever Isar changes
  await for (final _ in repo.watchAll(from: from, to: to)) {
    final results = await Future.wait([
      repo.getTotalIncome(from: from, to: to),
      repo.getTotalExpense(from: from, to: to),
      repo.getAll(from: from, to: to),
      repo.getCategorySummary(isIncome: false, from: from, to: to),
      categoryRepo.getAll(),
      _getTodayExpense(repo),
      _getWeekExpense(repo),
    ]);

    yield DashboardData(
      totalIncome: results[0] as double,
      totalExpense: results[1] as double,
      recentTransactions:
          (results[2] as List<TransactionModel>).take(5).toList(),
      categoryExpenseSummary: results[3] as Map<int, double>,
      categories: results[4] as List<CategoryModel>,
      todayExpense: results[5] as double,
      weekExpense: results[6] as double,
    );
  }
});

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
