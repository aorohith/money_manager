import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:money_manager/features/transactions/data/models/account_model.dart';
import 'package:money_manager/features/transactions/data/models/category_model.dart';
import 'package:money_manager/features/transactions/data/models/transaction_model.dart';
import 'package:money_manager/features/transactions/domain/services/recurrence_service.dart';

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
    directory = await Directory.systemTemp.createTemp('recurrence_svc_test');
    isar = await Isar.open(
      [TransactionModelSchema, CategoryModelSchema, AccountModelSchema],
      directory: directory.path,
      name: 'recurrence_svc_test',
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('generated occurrences clone monetary + tag fields from the template',
      () async {
    // Template last fired ~14 days ago so the daily rule produces multiple
    // historical occurrences.
    final lastDate = DateTime.now().subtract(const Duration(days: 14));
    final template = TransactionModel(
      amount: 199,
      categoryId: 7,
      accountId: 3,
      date: DateTime(lastDate.year, lastDate.month, lastDate.day),
      isIncome: false,
      note: 'Netflix',
      tags: const ['subscription', 'streaming'],
      currencyCode: 'INR',
      originalAmount: 2.39,
      originalCurrencyCode: 'USD',
      fxRate: 199 / 2.39,
      recurrence: RecurrenceType.daily,
    );

    await isar.writeTxn(() async {
      await isar.transactionModels.put(template);
    });

    await RecurrenceService(isar).processRecurringTransactions();

    final all = await isar.transactionModels.where().findAll();
    final instances =
        all.where((t) => t.recurrence == RecurrenceType.none).toList();

    expect(instances, isNotEmpty);
    for (final t in instances) {
      expect(t.tags, ['subscription', 'streaming']);
      expect(t.currencyCode, 'INR');
      expect(t.originalAmount, 2.39);
      expect(t.originalCurrencyCode, 'USD');
      expect(t.fxRate, closeTo(199 / 2.39, 0.0001));
      expect(t.amount, 199);
      expect(t.isIncome, isFalse);
      expect(t.note, 'Netflix');
      // Generated rows MUST NOT inherit transferGroupId / importBatchId,
      // otherwise downstream features like multi-leg delete and import undo
      // would treat them as part of an unrelated group.
      expect(t.transferGroupId, isNull);
      expect(t.importBatchId, isNull);
    }
  });
}

String _isarLibraryPath() {
  final extension = Platform.isWindows
      ? 'dll'
      : Platform.isMacOS
          ? 'dylib'
          : 'so';
  return '${Directory.systemTemp.path}/libisar_recurrence_svc_tests.$extension';
}
