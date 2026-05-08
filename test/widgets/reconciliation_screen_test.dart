import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/auth/providers/auth_provider.dart';
import 'package:money_manager/features/transactions/data/models/account_model.dart';
import 'package:money_manager/features/transactions/domain/providers/transaction_providers.dart';
import 'package:money_manager/features/transactions/presentation/screens/reconciliation_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('shows balanced empty state when no pending/history', (
    tester,
  ) async {
    final controller = StreamController<ReconciliationState>();
    addTearDown(controller.close);
    controller.add(const ReconciliationState(pending: [], history: []));

    await tester.pumpApp(
      const ReconciliationScreen(),
      overrides: [
        currencySymbolProvider.overrideWith((_) async => '₹'),
        reconciliationStateProvider.overrideWith((_) => controller.stream),
      ],
    );
    await tester.pump();

    expect(find.text('All accounts are balanced ✓'), findsOneWidget);
  });

  testWidgets('renders pending and history sections', (tester) async {
    final accountA = AccountModel(
      name: 'Cash',
      iconCodePoint: Icons.wallet.codePoint,
      colorValue: Colors.blue.toARGB32(),
      initialBalance: 1000,
    )..id = 1;
    final accountB = AccountModel(
      name: 'Bank',
      iconCodePoint: Icons.account_balance.codePoint,
      colorValue: Colors.green.toARGB32(),
      initialBalance: 2000,
    )..id = 2;

    final state = ReconciliationState(
      pending: [
        ReconciliationItem(
          account: accountA,
          calculatedBalance: 900,
          actualBalance: 1000,
        ),
      ],
      history: [
        ReconciliationItem(
          account: accountB,
          calculatedBalance: 2000,
          actualBalance: 2000,
        ),
      ],
    );

    await tester.pumpApp(
      const ReconciliationScreen(),
      overrides: [
        currencySymbolProvider.overrideWith((_) async => '₹'),
        reconciliationStateProvider.overrideWith((_) => Stream.value(state)),
      ],
    );
    await tester.pump();

    expect(find.text('Needs Reconciliation'), findsOneWidget);
    expect(find.text('Reconciliation History'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Bank'), findsOneWidget);
  });
}
