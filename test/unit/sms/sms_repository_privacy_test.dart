import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:money_manager/features/sms/data/models/sms_parsed_transaction.dart';
import 'package:money_manager/features/sms/data/models/sms_raw_log_model.dart';
import 'package:money_manager/features/sms/data/models/sms_rule_model.dart';
import 'package:money_manager/features/sms/data/repositories/sms_repository.dart';
import 'package:money_manager/features/transactions/data/models/transaction_model.dart';
import 'package:money_manager/features/transactions/data/models/account_model.dart';
import 'package:money_manager/features/transactions/data/models/category_model.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late SmsRepository repo;

  setUpAll(() async {
    await Isar.initializeIsarCore(
      libraries: {Abi.current(): _isarLibraryPath()},
      download: true,
    );
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('sms_repo_test');
    isar = await Isar.open(
      [
        SmsParsedTransactionSchema,
        SmsRuleModelSchema,
        SmsRawLogModelSchema,
        TransactionModelSchema,
        AccountModelSchema,
        CategoryModelSchema,
      ],
      directory: directory.path,
      name: 'sms_repo_test',
    );
    repo = SmsRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  SmsParsedTransaction seed({
    SmsReviewStatus status = SmsReviewStatus.pending,
    DateTime? detectedAt,
    DateTime? updatedAt,
    String rawText = 'A/C XX1234 debited Rs.500 at SWIGGY',
  }) {
    final t = SmsParsedTransaction(
      amount: 500,
      merchantRaw: 'SWIGGY',
      merchantNormalized: 'SWIGGY',
      transactionDate: DateTime(2026, 5, 1),
      paymentMethod: 'UPI',
      rawText: rawText,
      senderAddress: 'HDFCBK',
      status: status,
    );
    if (detectedAt != null) t.detectedAt = detectedAt;
    if (updatedAt != null) t.updatedAt = updatedAt;
    return t;
  }

  test('updateStatus to non-pending wipes the raw notification body', () async {
    late int id;
    await isar.writeTxn(() async {
      id = await isar.smsParsedTransactions.put(seed());
    });

    await repo.updateStatus(id, SmsReviewStatus.skipped);

    final stored = await isar.smsParsedTransactions.get(id);
    expect(stored, isNotNull);
    expect(stored!.status, SmsReviewStatus.skipped);
    expect(stored.rawText, isEmpty,
        reason: 'rawText must be cleared once the user has reviewed the row.');
  });

  test('updateStatus back to pending leaves rawText untouched', () async {
    late int id;
    await isar.writeTxn(() async {
      id = await isar.smsParsedTransactions.put(seed());
    });

    await repo.updateStatus(id, SmsReviewStatus.pending);

    final stored = await isar.smsParsedTransactions.get(id);
    expect(stored!.rawText, isNotEmpty);
  });

  test('approveTransaction clears rawText and links the transaction',
      () async {
    late int smsId;
    await isar.writeTxn(() async {
      smsId = await isar.smsParsedTransactions.put(seed());
    });

    final txId = await repo.approveTransaction(
      smsId: smsId,
      tx: TransactionModel(
        amount: 500,
        categoryId: 1,
        accountId: 1,
        date: DateTime(2026, 5, 1),
        isIncome: false,
      ),
    );

    final stored = await isar.smsParsedTransactions.get(smsId);
    expect(stored!.status, SmsReviewStatus.approved);
    expect(stored.linkedTransactionId, txId);
    expect(stored.rawText, isEmpty);
  });

  test('pruneOldParsedTransactions deletes stale reviewed and pending rows',
      () async {
    final now = DateTime.now();

    await isar.writeTxn(() async {
      // Reviewed 60 days ago — should be deleted (reviewedTtl = 30d).
      await isar.smsParsedTransactions.put(seed(
        status: SmsReviewStatus.approved,
        updatedAt: now.subtract(const Duration(days: 60)),
      ));
      // Reviewed 5 days ago — keep.
      await isar.smsParsedTransactions.put(seed(
        status: SmsReviewStatus.approved,
        updatedAt: now.subtract(const Duration(days: 5)),
      ));
      // Pending 100 days ago — should be deleted (pendingTtl = 90d).
      await isar.smsParsedTransactions.put(seed(
        status: SmsReviewStatus.pending,
        detectedAt: now.subtract(const Duration(days: 100)),
      ));
      // Pending 10 days ago — keep.
      await isar.smsParsedTransactions.put(seed(
        status: SmsReviewStatus.pending,
        detectedAt: now.subtract(const Duration(days: 10)),
      ));
    });

    await repo.pruneOldParsedTransactions();

    final remaining = await isar.smsParsedTransactions.where().findAll();
    expect(remaining, hasLength(2));
    expect(
      remaining.where((r) => r.status == SmsReviewStatus.approved).length,
      1,
    );
    expect(
      remaining.where((r) => r.status == SmsReviewStatus.pending).length,
      1,
    );
  });
}

String _isarLibraryPath() {
  final extension = Platform.isWindows
      ? 'dll'
      : Platform.isMacOS
          ? 'dylib'
          : 'so';
  return '${Directory.systemTemp.path}/libisar_sms_repo_tests.$extension';
}
