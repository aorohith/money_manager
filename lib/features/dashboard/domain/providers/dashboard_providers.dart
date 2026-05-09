import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../transactions/data/models/category_model.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';
import '../../../transactions/domain/providers/transaction_providers.dart';
import '../models/home_section.dart';
import 'home_layout_provider.dart';

// ── Period selector ──────────────────────────────────────────────────────────

/// Period scope that drives every dashboard data query. Mirrors the
/// `AnalyticsPeriod` shape so the home and analytics screens speak the
/// same language.
enum HomePeriod { day, week, month, year }

/// User's most recent in-app selection. The default is `day` per product
/// spec; `effectiveDashboardPeriodProvider` is what the dashboard actually
/// reads — it falls back to `month` when the period selector section is
/// hidden so users who turn the widget off don't get stuck with whatever
/// they last picked.
final dashboardPeriodProvider =
    StateProvider<HomePeriod>((_) => HomePeriod.day);

/// The period actually applied to dashboard queries. When the user has
/// disabled `HomeSection.periodSelector` from Settings → Home screen we
/// fall back to `HomePeriod.month` so the dashboard still shows a sensible
/// roll-up. While the layout pref is loading we honour the user's current
/// selection so the dashboard never flashes empty.
final effectiveDashboardPeriodProvider = Provider<HomePeriod>((ref) {
  final selection = ref.watch(dashboardPeriodProvider);
  final layout = ref.watch(homeLayoutProvider).valueOrNull;
  if (layout == null) return selection;
  return layout.contains(HomeSection.periodSelector)
      ? selection
      : HomePeriod.month;
});

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

/// Streams [DashboardData] for the active [HomePeriod].
///
/// Uses [TransactionRepository.watchAll] as the trigger so the dashboard
/// automatically refreshes whenever a transaction is added, edited, or deleted.
/// All heavy queries inside the loop are parallelised with [Future.wait].
final dashboardProvider =
    StreamProvider.autoDispose<DashboardData>((ref) async* {
  final period = ref.watch(effectiveDashboardPeriodProvider);
  final repo = ref.read(transactionRepositoryProvider);
  final categoryRepo = ref.read(categoryRepositoryProvider);
  final baseCurrency = ref.watch(currencyCodeProvider).valueOrNull;

  final (from, to) = homePeriodRange(period);

  // Re-emit whenever Isar changes.
  await for (final _ in repo.watchAll(from: from, to: to)) {
    // Run all queries concurrently for performance.
    final results = await Future.wait([
      repo.getTotalIncome(
          from: from, to: to, baseCurrencyCode: baseCurrency),
      repo.getTotalExpense(
          from: from, to: to, baseCurrencyCode: baseCurrency),
      repo.getAll(from: from, to: to),
      repo.getCategorySummary(
          isIncome: false,
          from: from,
          to: to,
          baseCurrencyCode: baseCurrency),
      categoryRepo.getAll(),
      _getTodayExpense(repo, baseCurrency),
      _getWeekExpense(repo, baseCurrency),
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

/// Returns the inclusive `[from, to)` date range for a given [HomePeriod].
///
/// The end of range is always set to 1 microsecond before midnight of the
/// next period's start so that Isar's `dateLessThan` filter captures the
/// last transaction of the day without crossing into the following period.
///
/// Exposed at top-level (`@visibleForTesting`) so the bounds for each
/// period can be unit-tested without spinning up the full StreamProvider.
@visibleForTesting
(DateTime, DateTime) homePeriodRange(HomePeriod period, {DateTime? now}) {
  final n = now ?? DateTime.now();
  switch (period) {
    case HomePeriod.day:
      final start = DateTime(n.year, n.month, n.day);
      final end = start.add(const Duration(days: 1));
      return (start, end.subtract(const Duration(microseconds: 1)));
    case HomePeriod.week:
      final today = DateTime(n.year, n.month, n.day);
      final monday = today.subtract(Duration(days: today.weekday - 1));
      final nextMonday = monday.add(const Duration(days: 7));
      return (monday, nextMonday.subtract(const Duration(microseconds: 1)));
    case HomePeriod.month:
      return (
        DateTime(n.year, n.month, 1),
        DateTime(n.year, n.month + 1, 1)
            .subtract(const Duration(microseconds: 1)),
      );
    case HomePeriod.year:
      return (
        DateTime(n.year, 1, 1),
        DateTime(n.year + 1, 1, 1).subtract(const Duration(microseconds: 1)),
      );
  }
}

/// Short, period-aware label rendered next to "Net Balance" on the home
/// balance card, e.g. "Today", "This week", "Apr 2026", "2026".
String homePeriodLabel(HomePeriod period, {DateTime? now}) {
  final n = now ?? DateTime.now();
  switch (period) {
    case HomePeriod.day:
      return 'Today';
    case HomePeriod.week:
      return 'This week';
    case HomePeriod.month:
      return '${_shortMonth(n.month)} ${n.year}';
    case HomePeriod.year:
      return '${n.year}';
  }
}

const _monthShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _shortMonth(int m) => _monthShort[m - 1];

Future<double> _getTodayExpense(
  TransactionRepository repo,
  String? baseCurrency,
) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  return repo.getTotalExpense(
    from: start,
    to: end,
    baseCurrencyCode: baseCurrency,
  );
}

Future<double> _getWeekExpense(
  TransactionRepository repo,
  String? baseCurrency,
) async {
  final now = DateTime.now();
  final start =
      DateTime(now.year, now.month, now.day - now.weekday + 1); // Monday
  return repo.getTotalExpense(
    from: start,
    baseCurrencyCode: baseCurrency,
  );
}
