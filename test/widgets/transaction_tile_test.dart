import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/transactions/presentation/widgets/transaction_tile.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_factories.dart';

Widget _scaffold(Widget child) => Scaffold(body: ListView(children: [child]));

void main() {
  group('TransactionTile', () {
    testWidgets('shows category name when category is provided', (
      tester,
    ) async {
      final tx = makeTx(amount: 200, isIncome: false);
      final cat = makeCat(id: 1, name: 'Groceries');

      await tester.pumpApp(
        _scaffold(
          TransactionTile(transaction: tx, category: cat, currencySymbol: '\$'),
        ),
      );

      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('shows "Unknown" when category is null', (tester) async {
      final tx = makeTx(amount: 50, isIncome: false);

      await tester.pumpApp(
        _scaffold(
          TransactionTile(
            transaction: tx,
            category: null,
            currencySymbol: '\$',
          ),
        ),
      );

      expect(find.text('Unknown'), findsOneWidget);
    });

    testWidgets('displays formatted amount with minus sign for expense', (
      tester,
    ) async {
      final tx = makeTx(amount: 99.50, isIncome: false);
      final cat = makeCat(name: 'Food');

      await tester.pumpApp(
        _scaffold(
          TransactionTile(transaction: tx, category: cat, currencySymbol: '\$'),
        ),
      );

      expect(find.text('-\$99.50'), findsOneWidget);
    });

    testWidgets('displays + sign for income', (tester) async {
      final tx = makeTx(amount: 3000, isIncome: true);
      final cat = makeCat(name: 'Salary', isIncome: true);

      await tester.pumpApp(
        _scaffold(
          TransactionTile(transaction: tx, category: cat, currencySymbol: '\$'),
        ),
      );

      expect(find.text('+\$3,000.00'), findsOneWidget);
    });

    testWidgets('shows note when provided', (tester) async {
      final tx = makeTx(note: 'Lunch with team');
      final cat = makeCat(name: 'Food');

      await tester.pumpApp(
        _scaffold(
          TransactionTile(transaction: tx, category: cat, currencySymbol: '\$'),
        ),
      );

      expect(find.text('Lunch with team'), findsOneWidget);
    });

    testWidgets('shows formatted date when note is null', (tester) async {
      final tx = makeTx(date: DateTime(2024, 3, 15));
      final cat = makeCat(name: 'Food');

      await tester.pumpApp(
        _scaffold(
          TransactionTile(transaction: tx, category: cat, currencySymbol: '\$'),
        ),
      );

      expect(find.text('Mar 15, 2024'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      final tx = makeTx();
      final cat = makeCat(name: 'Food');

      await tester.pumpApp(
        _scaffold(
          TransactionTile(
            transaction: tx,
            category: cat,
            currencySymbol: '\$',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });

    testWidgets('wraps with Dismissible when onDismissed is provided', (
      tester,
    ) async {
      final tx = makeTx(id: 1);
      final cat = makeCat(name: 'Food');

      await tester.pumpApp(
        _scaffold(
          TransactionTile(
            transaction: tx,
            category: cat,
            currencySymbol: '\$',
            onDismissed: () {},
          ),
        ),
      );

      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('no Dismissible when onDismissed is null', (tester) async {
      final tx = makeTx(id: 1);
      final cat = makeCat(name: 'Food');

      await tester.pumpApp(
        _scaffold(
          TransactionTile(transaction: tx, category: cat, currencySymbol: '\$'),
        ),
      );

      expect(find.byType(Dismissible), findsNothing);
    });
  });
}
