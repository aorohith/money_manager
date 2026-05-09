import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../transactions/data/models/category_model.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/providers/transaction_providers.dart';
import '../models/analytics_data.dart';

export '../models/analytics_data.dart';

// ── Period & date state ───────────────────────────────────────────────────────

final analyticsPeriodProvider =
    StateProvider<AnalyticsPeriod>((_) => AnalyticsPeriod.month);

final analyticsDateProvider =
    StateProvider<DateTime>((_) => DateTime.now());

// ── Derived params ────────────────────────────────────────────────────────────

final analyticsParamsProvider = Provider<AnalyticsParams>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  final date = ref.watch(analyticsDateProvider);
  return AnalyticsParams(period: period, referenceDate: date);
});

// ── Period range helpers ──────────────────────────────────────────────────────

(DateTime, DateTime) periodRange(AnalyticsParams p) {
  final d = p.normalised;
  switch (p.period) {
    case AnalyticsPeriod.day:
      return (d, d.add(const Duration(days: 1)));
    case AnalyticsPeriod.week:
      final monday = d.subtract(Duration(days: d.weekday - 1));
      return (monday, monday.add(const Duration(days: 7)));
    case AnalyticsPeriod.month:
      final start = DateTime(d.year, d.month, 1);
      final end = DateTime(d.year, d.month + 1, 1);
      return (start, end);
    case AnalyticsPeriod.year:
      final start = DateTime(d.year, 1, 1);
      final end = DateTime(d.year + 1, 1, 1);
      return (start, end);
  }
}

String periodLabel(AnalyticsParams p) {
  final d = p.normalised;
  switch (p.period) {
    case AnalyticsPeriod.day:
      return _formatDay(d);
    case AnalyticsPeriod.week:
      final monday = d.subtract(Duration(days: d.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      if (monday.month == sunday.month) {
        return '${_shortMonth(monday.month)} ${monday.day}–${sunday.day}';
      }
      return '${_shortMonth(monday.month)} ${monday.day} – ${_shortMonth(sunday.month)} ${sunday.day}';
    case AnalyticsPeriod.month:
      return '${_fullMonth(d.month)} ${d.year}';
    case AnalyticsPeriod.year:
      return '${d.year}';
  }
}

AnalyticsParams previousPeriod(AnalyticsParams p) {
  final d = p.normalised;
  switch (p.period) {
    case AnalyticsPeriod.day:
      return AnalyticsParams(
          period: p.period, referenceDate: d.subtract(const Duration(days: 1)));
    case AnalyticsPeriod.week:
      return AnalyticsParams(
          period: p.period, referenceDate: d.subtract(const Duration(days: 7)));
    case AnalyticsPeriod.month:
      return AnalyticsParams(
          period: p.period, referenceDate: DateTime(d.year, d.month - 1, 1));
    case AnalyticsPeriod.year:
      return AnalyticsParams(
          period: p.period, referenceDate: DateTime(d.year - 1, 1, 1));
  }
}

AnalyticsParams nextPeriod(AnalyticsParams p) {
  final d = p.normalised;
  switch (p.period) {
    case AnalyticsPeriod.day:
      return AnalyticsParams(
          period: p.period, referenceDate: d.add(const Duration(days: 1)));
    case AnalyticsPeriod.week:
      return AnalyticsParams(
          period: p.period, referenceDate: d.add(const Duration(days: 7)));
    case AnalyticsPeriod.month:
      return AnalyticsParams(
          period: p.period, referenceDate: DateTime(d.year, d.month + 1, 1));
    case AnalyticsPeriod.year:
      return AnalyticsParams(
          period: p.period, referenceDate: DateTime(d.year + 1, 1, 1));
  }
}

// ── Main analytics provider ───────────────────────────────────────────────────

final analyticsProvider =
    FutureProvider.autoDispose.family<AnalyticsData, AnalyticsParams>(
  (ref, params) async {
    final repo = ref.read(transactionRepositoryProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);

    final (from, to) = periodRange(params);
    final label = periodLabel(params);

    final results = await Future.wait([
      repo.getAll(from: from, to: to),
      categoryRepo.getAll(),
    ]);

    final allTx = results[0] as List<TransactionModel>;
    final categories = results[1] as List<CategoryModel>;
    final catMap = {for (final c in categories) c.id: c};

    // ── totals ────────────────────────────────────────────────────────────────
    double totalExpense = 0;
    double totalIncome = 0;
    for (final tx in allTx) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    // ── category summaries (expenses only) ───────────────────────────────────
    final catAmounts = <int, double>{};
    final catCounts = <int, int>{};
    for (final tx in allTx.where((t) => !t.isIncome)) {
      catAmounts[tx.categoryId] = (catAmounts[tx.categoryId] ?? 0) + tx.amount;
      catCounts[tx.categoryId] = (catCounts[tx.categoryId] ?? 0) + 1;
    }

    final categorySummaries = catAmounts.entries.map((e) {
      final cat = catMap[e.key];
      return CategorySummary(
        categoryId: e.key,
        name: cat?.name ?? 'Unknown',
        color: cat?.color ?? AppColors.categoryPalette[e.key % AppColors.categoryPalette.length],
        icon: cat?.icon ?? const IconData(0xe25a, fontFamily: 'MaterialIcons'),
        totalAmount: e.value,
        percentage: totalExpense > 0 ? (e.value / totalExpense) * 100 : 0,
        txCount: catCounts[e.key] ?? 0,
      );
    }).toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    // ── day groups ────────────────────────────────────────────────────────────
    final dayMap = <String, List<TransactionModel>>{};
    for (final tx in allTx) {
      final key =
          '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.day.toString().padLeft(2, '0')}';
      (dayMap[key] ??= []).add(tx);
    }

    final dayGroups = dayMap.entries.map((e) {
      final txs = e.value..sort((a, b) => b.date.compareTo(a.date));
      double exp = 0, inc = 0;
      for (final tx in txs) {
        if (tx.isIncome) { inc += tx.amount; } else { exp += tx.amount; }
      }
      final parts = e.key.split('-');
      return DayGroup(
        date: DateTime(
          int.tryParse(parts[0]) ?? from.year,
          int.tryParse(parts[1]) ?? from.month,
          int.tryParse(parts[2]) ?? 1,
        ),
        totalExpense: exp,
        totalIncome: inc,
        transactions: txs,
      );
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // ── month groups (year view) ──────────────────────────────────────────────
    final monthMap = <String, List<TransactionModel>>{};
    for (final tx in allTx) {
      final key = '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}';
      (monthMap[key] ??= []).add(tx);
    }

    final monthGroups = monthMap.entries.map((e) {
      final txs = e.value;
      double exp = 0, inc = 0;
      for (final tx in txs) {
        if (tx.isIncome) { inc += tx.amount; } else { exp += tx.amount; }
      }
      final parts = e.key.split('-');
      return MonthGroup(
        year: int.tryParse(parts[0]) ?? from.year,
        month: int.tryParse(parts[1]) ?? from.month,
        totalExpense: exp,
        totalIncome: inc,
        transactions: txs,
      );
    }).toList()
      ..sort((a, b) {
        final aDate = DateTime(a.year, a.month);
        final bDate = DateTime(b.year, b.month);
        return bDate.compareTo(aDate);
      });

    return AnalyticsData(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      categorySummaries: categorySummaries,
      dayGroups: dayGroups,
      monthGroups: monthGroups,
      periodStart: from,
      periodEnd: to,
      periodLabel: label,
      allTransactions: allTx,
      categoryMap: catMap,
    );
  },
);

// ── Category detail provider ──────────────────────────────────────────────────

class CategoryDetailParams {
  const CategoryDetailParams({
    required this.categoryId,
    required this.analyticsParams,
  });

  final int categoryId;
  final AnalyticsParams analyticsParams;

  @override
  bool operator ==(Object other) =>
      other is CategoryDetailParams &&
      other.categoryId == categoryId &&
      other.analyticsParams == analyticsParams;

  @override
  int get hashCode => Object.hash(categoryId, analyticsParams);
}

final categoryDetailProvider =
    FutureProvider.autoDispose.family<List<TransactionModel>, CategoryDetailParams>(
  (ref, params) async {
    final repo = ref.read(transactionRepositoryProvider);
    final (from, to) = periodRange(params.analyticsParams);
    return repo.getAll(
      categoryId: params.categoryId,
      from: from,
      to: to,
    );
  },
);

// ── String helpers ────────────────────────────────────────────────────────────

String _formatDay(DateTime d) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${days[d.weekday - 1]}, ${_shortMonth(d.month)} ${d.day}';
}

String _shortMonth(int m) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return months[(m - 1).clamp(0, 11)];
}

String _fullMonth(int m) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return months[(m - 1).clamp(0, 11)];
}
