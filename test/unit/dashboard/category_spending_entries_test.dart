import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/dashboard/domain/providers/dashboard_providers.dart';
import 'package:money_manager/features/dashboard/presentation/screens/dashboard_screen.dart';

import '../../helpers/test_factories.dart';

void main() {
  group('buildCategorySpendEntries', () {
    final food = makeCat(id: 1, name: 'Food');
    final travel = makeCat(id: 2, name: 'Travel');
    final shopping = makeCat(id: 3, name: 'Shopping');

    DashboardData makeData({
      double totalExpense = 0,
      Map<int, double> summary = const {},
      List categories = const [],
    }) {
      return DashboardData(
        totalIncome: 0,
        totalExpense: totalExpense,
        recentTransactions: const [],
        categoryExpenseSummary: summary,
        categories: categories.cast(),
        todayExpense: 0,
        weekExpense: 0,
      );
    }

    test('returns empty list when there is no spending', () {
      final entries =
          buildCategorySpendEntries(makeData(totalExpense: 0, summary: {1: 50}));
      expect(entries, isEmpty);
    });

    test('drops zero amounts and orphaned category ids', () {
      final entries = buildCategorySpendEntries(
        makeData(
          totalExpense: 100,
          summary: {1: 100, 2: 0, 999: 25},
          categories: [food, travel],
        ),
      );

      expect(entries, hasLength(1));
      expect(entries.single.category.id, 1);
      expect(entries.single.fraction, closeTo(1.0, 1e-9));
    });

    test('sorts by amount descending and caps at maxRows', () {
      final entries = buildCategorySpendEntries(
        makeData(
          totalExpense: 100,
          summary: {1: 20, 2: 50, 3: 30},
          categories: [food, travel, shopping],
        ),
        maxRows: 2,
      );

      expect(entries.map((e) => e.category.id).toList(), [2, 3]);
      expect(entries[0].fraction, closeTo(0.5, 1e-9));
      expect(entries[1].fraction, closeTo(0.3, 1e-9));
    });
  });
}
