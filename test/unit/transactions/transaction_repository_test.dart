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
    directory = await Directory.systemTemp.createTemp('tx_repo_test');
    isar = await Isar.open(
      [TransactionModelSchema, CategoryModelSchema, AccountModelSchema],
      directory: directory.path,
      name: 'tx_repo_test',
    );
    repo = TransactionRepositoryImpl(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  Future<List<int>> seedTransferPair() async {
    final out = TransactionModel(
      amount: 1000,
      categoryId: 1,
      accountId: 1,
      date: DateTime(2026, 5, 1),
      isIncome: false,
      entryType: TransactionEntryType.transfer,
      transferGroupId: 'grp-1',
    );
    final inn = TransactionModel(
      amount: 1000,
      categoryId: 1,
      accountId: 2,
      date: DateTime(2026, 5, 1),
      isIncome: true,
      entryType: TransactionEntryType.transfer,
      transferGroupId: 'grp-1',
    );
    final ids = <int>[];
    await isar.writeTxn(() async {
      ids.add(await isar.transactionModels.put(out));
      ids.add(await isar.transactionModels.put(inn));
    });
    return ids;
  }

  group('delete', () {
    test('soft-deletes both legs of a transfer atomically', () async {
      final ids = await seedTransferPair();

      await repo.delete(ids.first);

      final all = await isar.transactionModels.where().findAll();
      expect(all, hasLength(2));
      expect(all.every((t) => t.isDeleted), isTrue,
          reason: 'Both transfer legs must be soft-deleted together.');

      // No active rows remain in the watch query.
      final visible = await repo.getAll();
      expect(visible, isEmpty);
    });

    test('soft-deletes only the targeted row when transferGroupId is null',
        () async {
      final tx = TransactionModel(
        amount: 50,
        categoryId: 1,
        accountId: 1,
        date: DateTime(2026, 5, 1),
        isIncome: false,
      );
      late int id;
      await isar.writeTxn(() async {
        id = await isar.transactionModels.put(tx);
      });

      await repo.delete(id);

      final stored = await isar.transactionModels.get(id);
      expect(stored, isNotNull);
      expect(stored!.isDeleted, isTrue);
    });

    test('is a no-op when the transaction id does not exist', () async {
      await expectLater(repo.delete(99999), completes);
    });
  });

  group('addWithAccountUpdate', () {
    test('inserts the transaction and stamps the account in one writeTxn',
        () async {
      final account = AccountModel(
        name: 'Main',
        iconCodePoint: 1,
        colorValue: 1,
        initialBalance: 100,
        actualBalance: 100,
      );
      await isar.writeTxn(() async {
        await isar.accountModels.put(account);
      });

      final tx = TransactionModel(
        amount: 25,
        categoryId: 0,
        accountId: account.id,
        date: DateTime(2026, 5, 1),
        isIncome: true,
        note: 'Adjustment',
        entryType: TransactionEntryType.adjustment,
      );
      account.actualBalance = 125;

      final id = await repo.addWithAccountUpdate(
        transaction: tx,
        account: account,
      );

      final storedTx = await isar.transactionModels.get(id);
      final storedAcc = await isar.accountModels.get(account.id);
      expect(storedTx, isNotNull);
      expect(storedTx!.entryType, TransactionEntryType.adjustment);
      expect(storedAcc!.actualBalance, 125);
      expect(storedAcc.updatedAt, greaterThanOrEqualTo(storedTx.updatedAt));
    });
  });
}

String _isarLibraryPath() {
  final extension = Platform.isWindows
      ? 'dll'
      : Platform.isMacOS
          ? 'dylib'
          : 'so';
  return '${Directory.systemTemp.path}/libisar_tx_repo_tests.$extension';
}
