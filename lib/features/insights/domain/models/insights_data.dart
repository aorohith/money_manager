import 'package:flutter/material.dart';

class InsightsData {
  const InsightsData({
    required this.totalExpenseThisPeriod,
    required this.totalExpenseLastPeriod,
    required this.totalIncomeThisPeriod,
    required this.spendingChangePercent,
    required this.savingsRate,
    required this.dailyAverage,
    required this.topCategories,
    required this.dailySpending,
    required this.daysElapsed,
  });

  final double totalExpenseThisPeriod;
  final double totalExpenseLastPeriod;
  final double totalIncomeThisPeriod;
  final double spendingChangePercent;
  final double savingsRate;
  final double dailyAverage;
  final List<TopCategory> topCategories;
  final List<DailySpending> dailySpending;
  final int daysElapsed;

  bool get spendingUp => spendingChangePercent > 0;
  bool get hasData => totalExpenseThisPeriod > 0 || totalIncomeThisPeriod > 0;
}

class TopCategory {
  const TopCategory({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  final String name;
  final double amount;
  final double percentage;
  final Color color;
  final IconData icon;
}

class DailySpending {
  const DailySpending({required this.day, required this.amount});
  final int day;
  final double amount;
}
