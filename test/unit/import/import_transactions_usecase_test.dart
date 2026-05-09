import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:money_manager/features/import/data/models/import_preview_row.dart';
import 'package:money_manager/features/import/data/models/import_row.dart';
import 'package:money_manager/features/import/data/models/import_session.dart';
import 'package:money_manager/features/import/domain/usecases/import_transactions_usecase.dart';
import 'package:money_manager/features/transactions/data/models/account_model.dart';
import 'package:money_manager/features/transactions/data/models/category_model.dart';
import 'package:money_manager/features/transactions/data/models/transaction_model.dart';

void main() {
  late Directory directory;
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(
      libraries: {Abi.current(): _isarLibraryPath()},
      download: true,
    );
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('import_usecase_test');
    isar = await Isar.open(
      [TransactionModelSchema, CategoryModelSchema, AccountModelSchema],
      directory: directory.path,
      name: 'import_usecase_test',
    );
    await isar.writeTxn(() async {
      await isar.accountModels.put(
        AccountModel(name: 'Main', iconCodePoint: 1, colorValue: 1),
      );
      await isar.categoryModels.put(
        CategoryModel(
          name: 'Food',
          iconCodePoint: 1,
          colorValue: 1,
          isIncome: false,
        ),
      );
    });
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('commits imported rows with tags and currency metadata', () async {
    final session = ImportSession(
      batchId: 'batch_1',
      filePath: 'sample.xlsx',
      format: ImportFormat.excel,
      rows: [
        ExpenseImportRow(
          rowNumber: 2,
          date: DateTime(2026, 5, 8),
          categoryName: 'Food',
          accountName: 'Main',
          amount: 573,
          currencyCode: 'INR',
          originalAmount: 573,
          originalCurrencyCode: 'INR',
          tags: const ['KFC'],
          note: 'Lunch',
        ),
      ],
    );

    final result = await ImportTransactionsUseCase(isar)(
      session: session,
      previewRows: [
        ImportPreviewRow(
          row: session.rows.first,
          status: ImportPreviewStatus.ready,
          selected: true,
        ),
      ],
    );

    final txs = await isar.transactionModels.where().findAll();
    expect(result.insertedTransactions, 1);
    expect(txs.single.tags, ['KFC']);
    expect(txs.single.currencyCode, 'INR');
    expect(txs.single.importBatchId, 'batch_1');
  });

  test('creates transfer pairs with shared transferGroupId', () async {
    final row = TransferImportRow(
      rowNumber: 4,
      date: DateTime(2026, 5, 9),
      outgoingAccountName: 'Main',
      incomingAccountName: 'Credit Card',
      amount: 1000,
      currencyCode: 'INR',
    );
    final session = ImportSession(
      batchId: 'batch_2',
      filePath: 'sample.xlsx',
      format: ImportFormat.excel,
      rows: [row],
    );

    final result = await ImportTransactionsUseCase(isar)(
      session: session,
      previewRows: [
        ImportPreviewRow(
          row: row,
          status: ImportPreviewStatus.ready,
          selected: true,
        ),
      ],
    );

    final txs = await isar.transactionModels.where().findAll();
    expect(result.insertedTransactions, 2);
    expect(result.createdAccounts, 1);
    expect(txs.map((tx) => tx.entryType).toSet(), {
      TransactionEntryType.transfer,
    });
    expect(txs.first.transferGroupId, isNotNull);
    expect(txs.first.transferGroupId, txs.last.transferGroupId);
    expect(txs.where((tx) => tx.isIncome), hasLength(1));
    expect(txs.where((tx) => !tx.isIncome), hasLength(1));
  });
}

String _isarLibraryPath() {
  final extension = Platform.isWindows
      ? 'dll'
      : Platform.isMacOS
      ? 'dylib'
      : 'so';
  return '${Directory.systemTemp.path}/libisar_import_tests.$extension';
}
