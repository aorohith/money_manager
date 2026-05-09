import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../transactions/domain/providers/transaction_providers.dart';
import '../models/insights_data.dart';

final insightsProvider = FutureProvider.autoDispose<InsightsData>((ref) async {
  final repo = ref.read(transactionRepositoryProvider);
  final categoryRepo = ref.read(categoryRepositoryProvider);

  final now = DateTime.now();
  final thisMonthStart = DateTime(now.year, now.month, 1);
  final thisMonthEnd = DateTime(now.year, now.month + 1, 1);
  final lastMonthStart = DateTime(now.year, now.month - 1, 1);
  final lastMonthEnd = thisMonthStart;

  final results = await Future.wait([
    repo.getAll(from: thisMonthStart, to: thisMonthEnd),
    repo.getAll(from: lastMonthStart, to: lastMonthEnd),
    categoryRepo.getAll(),
  ]);

  final thisTxs = results[0] as List;
  final lastTxs = results[1] as List;
  final categories = results[2] as List;
  final catMap = {for (final c in categories) c.id: c};

  double expenseThis = 0, incomeThis = 0;
  for (final tx in thisTxs) {
    if (tx.isIncome) {
      incomeThis += tx.amount;
    } else {
      expenseThis += tx.amount;
    }
  }

  double expenseLast = 0;
  for (final tx in lastTxs) {
    if (!tx.isIncome) expenseLast += tx.amount;
  }

  final changePct = expenseLast > 0
      ? ((expenseThis - expenseLast) / expenseLast) * 100
      : 0.0;

  final savingsRate =
      incomeThis > 0 ? ((incomeThis - expenseThis) / incomeThis) * 100 : 0.0;

  final daysElapsed = now.difference(thisMonthStart).inDays + 1;
  final dailyAvg = daysElapsed > 0 ? expenseThis / daysElapsed : 0.0;

  // Top categories
  final catAmounts = <int, double>{};
  for (final tx in thisTxs) {
    if (!tx.isIncome) {
      catAmounts[tx.categoryId] =
          (catAmounts[tx.categoryId] ?? 0) + tx.amount;
    }
  }

  final sorted = catAmounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final topCats = sorted.take(5).map((e) {
    final cat = catMap[e.key];
    return TopCategory(
      name: cat?.name ?? 'Unknown',
      amount: e.value,
      percentage: expenseThis > 0 ? (e.value / expenseThis) * 100 : 0,
      color: cat?.color ??
          AppColors.categoryPalette[e.key % AppColors.categoryPalette.length],
      icon: cat?.icon ?? const IconData(0xe25a, fontFamily: 'MaterialIcons'),
    );
  }).toList();

  // Daily spending
  final dayAmounts = <int, double>{};
  for (final tx in thisTxs) {
    if (!tx.isIncome) {
      dayAmounts[tx.date.day] =
          (dayAmounts[tx.date.day] ?? 0) + tx.amount;
    }
  }

  final daily = List.generate(
    daysElapsed,
    (i) => DailySpending(day: i + 1, amount: dayAmounts[i + 1] ?? 0),
  );

  return InsightsData(
    totalExpenseThisPeriod: expenseThis,
    totalExpenseLastPeriod: expenseLast,
    totalIncomeThisPeriod: incomeThis,
    spendingChangePercent: changePct,
    savingsRate: savingsRate,
    dailyAverage: dailyAvg,
    topCategories: topCats,
    dailySpending: daily,
    daysElapsed: daysElapsed,
  );
});
