import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/transactions/domain/providers/transaction_providers.dart';
import 'package:money_manager/features/transactions/presentation/widgets/transaction_filter_chips.dart';

import '../helpers/pump_app.dart';

void main() {
  group('TransactionFilterChips', () {
    testWidgets('renders All, Income, Expense chips', (tester) async {
      await tester.pumpApp(const Scaffold(body: TransactionFilterChips()));

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
    });

    testWidgets('"All" chip is selected by default', (tester) async {
      await tester.pumpApp(const Scaffold(body: TransactionFilterChips()));

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final allChip = chips.firstWhere((c) => (c.label as Text).data == 'All');
      expect(allChip.selected, isTrue);

      final incomeChip = chips.firstWhere(
        (c) => (c.label as Text).data == 'Income',
      );
      expect(incomeChip.selected, isFalse);

      final expenseChip = chips.firstWhere(
        (c) => (c.label as Text).data == 'Expense',
      );
      expect(expenseChip.selected, isFalse);
    });

    testWidgets('tapping Income updates filter to isIncome=true', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const Scaffold(body: TransactionFilterChips()),
          ),
        ),
      );

      await tester.tap(find.text('Income'));
      await tester.pump();

      expect(container.read(transactionFilterProvider).isIncome, isTrue);
    });

    testWidgets('tapping Expense updates filter to isIncome=false', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const Scaffold(body: TransactionFilterChips()),
          ),
        ),
      );

      await tester.tap(find.text('Expense'));
      await tester.pump();

      expect(container.read(transactionFilterProvider).isIncome, isFalse);
    });

    testWidgets('tapping active Income chip again resets to All', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          transactionFilterProvider.overrideWith(
            (_) => const TransactionFilter(isIncome: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const Scaffold(body: TransactionFilterChips()),
          ),
        ),
      );

      await tester.tap(find.text('Income'));
      await tester.pump();

      expect(container.read(transactionFilterProvider).isIncome, isNull);
    });
  });
}
