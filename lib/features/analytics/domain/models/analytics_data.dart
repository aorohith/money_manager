import 'package:flutter/material.dart';

import '../../../transactions/data/models/category_model.dart';
import '../../../transactions/data/models/transaction_model.dart';

// ── Period ────────────────────────────────────────────────────────────────────

enum AnalyticsPeriod { day, week, month, year }

// ── Params (FutureProvider.family key — must implement == / hashCode) ─────────

class AnalyticsParams {
  const AnalyticsParams({
    required this.period,
    required this.referenceDate,
  });

  final AnalyticsPeriod period;
  final DateTime referenceDate;

  /// Normalized reference (midnight) so family key is stable.
  DateTime get normalised => DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
      );

  @override
  bool operator ==(Object other) =>
      other is AnalyticsParams &&
      other.period == period &&
      other.normalised == normalised;

  @override
  int get hashCode => Object.hash(period, normalised);
}

// ── Per-category breakdown ────────────────────────────────────────────────────

class CategorySummary {
  const CategorySummary({
    required this.categoryId,
    required this.name,
    required this.color,
    required this.icon,
    required this.totalAmount,
    required this.percentage,
    required this.txCount,
  });

  final int categoryId;
  final String name;
  final Color color;
  final IconData icon;
  final double totalAmount;

  /// 0–100 (percentage of total expense for the period).
  final double percentage;
  final int txCount;
}

// ── Day-level group ───────────────────────────────────────────────────────────

class DayGroup {
  const DayGroup({
    required this.date,
    required this.totalExpense,
    required this.totalIncome,
    required this.transactions,
  });

  final DateTime date; // midnight of the day
  final double totalExpense;
  final double totalIncome;
  final List<TransactionModel> transactions; // sorted by time desc

  /// Transactions grouped by categoryId for compact view.
  Map<int, List<TransactionModel>> get byCategory {
    final map = <int, List<TransactionModel>>{};
    for (final tx in transactions) {
      (map[tx.categoryId] ??= []).add(tx);
    }
    return map;
  }
}

// ── Month-level group (for year view) ────────────────────────────────────────

class MonthGroup {
  const MonthGroup({
    required this.year,
    required this.month,
    required this.totalExpense,
    required this.totalIncome,
    required this.transactions,
  });

  final int year;
  final int month;
  final double totalExpense;
  final double totalIncome;
  final List<TransactionModel> transactions;

  String get label {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}

// ── Top-level analytics result ────────────────────────────────────────────────

class AnalyticsData {
  AnalyticsData({
    required this.totalExpense,
    required this.totalIncome,
    required this.categorySummaries,
    required this.dayGroups,
    required this.monthGroups,
    required this.periodStart,
    required this.periodEnd,
    required this.periodLabel,
    required this.allTransactions,
    required this.categoryMap,
  });

  final double totalExpense;
  final double totalIncome;
  final List<CategorySummary> categorySummaries; // sorted by amount desc
  final List<DayGroup> dayGroups;                 // sorted by date desc
  final List<MonthGroup> monthGroups;             // for year view, sorted desc
  final DateTime periodStart;
  final DateTime periodEnd;
  final String periodLabel;
  final List<TransactionModel> allTransactions;
  final Map<int, CategoryModel> categoryMap;

  double get netBalance => totalIncome - totalExpense;

  bool get isEmpty => allTransactions.isEmpty;

  static final empty = AnalyticsData(
    totalExpense: 0,
    totalIncome: 0,
    categorySummaries: [],
    dayGroups: [],
    monthGroups: [],
    periodStart: DateTime(2000),
    periodEnd: DateTime(2000),
    periodLabel: '',
    allTransactions: [],
    categoryMap: {},
  );

}
