import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:money_manager/features/transactions/data/models/account_model.dart';
import 'package:money_manager/features/transactions/data/models/category_model.dart';
import 'package:money_manager/features/transactions/data/models/transaction_model.dart';
import 'package:money_manager/features/transactions/data/repositories/transaction_repository.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late TransactionRepositoryImpl repo;

  setUpAll(() async {
    await Isar.initializeIsarCore(
      libraries: {Abi.current(): _isarLibraryPath()},
      download: true,
    );
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('tx_repo_ccy_test');
    isar = await Isar.open(
      [TransactionModelSchema, CategoryModelSchema, AccountModelSchema],
      directory: directory.path,
      name: 'tx_repo_ccy_test',
    );
    repo = TransactionRepositoryImpl(isar);

    await isar.writeTxn(() async {
      await isar.transactionModels.putAll([
        TransactionModel(
          amount: 100,
          categoryId: 1,
          accountId: 1,
          date: DateTime(2026, 5, 1),
          isIncome: false,
          currencyCode: 'INR',
        ),
        TransactionModel(
          amount: 200,
          categoryId: 1,
          accountId: 1,
          date: DateTime(2026, 5, 2),
          isIncome: false,
          currencyCode: null, // legacy row
        ),
        TransactionModel(
          amount: 50,
          categoryId: 1,
          accountId: 1,
          date: DateTime(2026, 5, 3),
          isIncome: false,
          currencyCode: 'USD',
        ),
        TransactionModel(
          amount: 1000,
          categoryId: 2,
          accountId: 1,
          date: DateTime(2026, 5, 4),
          isIncome: true,
          currencyCode: 'INR',
        ),
        TransactionModel(
          amount: 25,
          categoryId: 2,
          accountId: 1,
          date: DateTime(2026, 5, 5),
          isIncome: true,
          currencyCode: 'USD',
        ),
      ]);
    });
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('getTotalExpense excludes non-base-currency rows when filter is set',
      () async {
    final unfiltered = await repo.getTotalExpense();
    final inrOnly = await repo.getTotalExpense(baseCurrencyCode: 'INR');

    expect(unfiltered, closeTo(350, 0.001),
        reason: 'Without filter the sum collapses currencies (legacy behaviour).');
    expect(inrOnly, closeTo(300, 0.001),
        reason: 'INR row + null-currency row, USD excluded.');
  });

  test('getTotalIncome respects baseCurrencyCode', () async {
    final inrOnly = await repo.getTotalIncome(baseCurrencyCode: 'INR');
    final usdOnly = await repo.getTotalIncome(baseCurrencyCode: 'USD');
    expect(inrOnly, closeTo(1000, 0.001));
    expect(usdOnly, closeTo(25, 0.001));
  });

  test('getCategorySummary scopes per category and currency', () async {
    final summary = await repo.getCategorySummary(
      isIncome: false,
      baseCurrencyCode: 'INR',
    );
    expect(summary[1], closeTo(300, 0.001));
    expect(summary.containsKey(2), isFalse);
  });

  test('getTransactionDeltaForAccount nets income − expense in base currency',
      () async {
    final delta = await repo.getTransactionDeltaForAccount(
      1,
      baseCurrencyCode: 'INR',
    );
    expect(delta, closeTo(1000 - 300, 0.001));
  });

  test('null baseCurrencyCode keeps the legacy "sum-everything" behaviour',
      () async {
    final delta = await repo.getTransactionDeltaForAccount(1);
    // 1000 + 25 (income) − (100 + 200 + 50) expense = 675.
    expect(delta, closeTo(675, 0.001));
  });
}

String _isarLibraryPath() {
  final extension = Platform.isWindows
      ? 'dll'
      : Platform.isMacOS
          ? 'dylib'
          : 'so';
  return '${Directory.systemTemp.path}/libisar_tx_repo_ccy_tests.$extension';
}
