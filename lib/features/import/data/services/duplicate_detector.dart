import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/import/data/models/import_row.dart';
import 'package:money_manager/features/transactions/data/models/account_model.dart';
import 'package:money_manager/features/transactions/data/models/category_model.dart';
import 'package:money_manager/features/transactions/data/models/transaction_model.dart';

class DuplicateDetector {
  DuplicateDetector({DateFormat? dateFormat})
    : _dateFormat = dateFormat ?? DateFormat('yyyyMMdd');

  static const transferCategoryName = 'Transfer';

  final DateFormat _dateFormat;

  Set<String> existingFingerprints({
    required List<TransactionModel> transactions,
    required List<AccountModel> accounts,
    required List<CategoryModel> categories,
  }) {
    final accountNames = {
      for (final account in accounts) account.id: account.name,
    };
    final categoryNames = {
      for (final category in categories) category.id: category.name,
    };

    return transactions
        .map(
          (transaction) => fingerprint(
            date: transaction.date,
            amount: transaction.amount,
            accountName: accountNames[transaction.accountId] ?? '',
            categoryName: categoryNames[transaction.categoryId] ?? '',
            note: transaction.note,
          ),
        )
        .toSet();
  }

  bool isDuplicate(ImportRow row, Set<String> existing) {
    return fingerprintsFor(row).any(existing.contains);
  }

  List<String> fingerprintsFor(ImportRow row) {
    return switch (row) {
      ExpenseImportRow() => [
        fingerprint(
          date: row.date,
          amount: row.amount,
          accountName: row.accountName,
          categoryName: row.categoryName,
          note: row.note,
        ),
      ],
      IncomeImportRow() => [
        fingerprint(
          date: row.date,
          amount: row.amount,
          accountName: row.accountName,
          categoryName: row.categoryName,
          note: row.note,
        ),
      ],
      TransferImportRow() => [
        fingerprint(
          date: row.date,
          amount: row.amount,
          accountName: row.outgoingAccountName,
          categoryName: transferCategoryName,
          note: row.note,
        ),
        fingerprint(
          date: row.date,
          amount: row.incomingAmount ?? row.amount,
          accountName: row.incomingAccountName,
          categoryName: transferCategoryName,
          note: row.note,
        ),
      ],
    };
  }

  String fingerprint({
    required DateTime date,
    required double amount,
    required String accountName,
    required String categoryName,
    String? note,
  }) {
    final payload = [
      _dateFormat.format(date),
      amount.toStringAsFixed(2),
      _normalize(accountName),
      _normalize(categoryName),
      _normalize(note ?? ''),
    ].join('|');
    return sha1.convert(utf8.encode(payload)).toString();
  }

  String _normalize(String value) => value.trim().toLowerCase();
}
