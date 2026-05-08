import 'package:isar/isar.dart';
import 'package:money_manager/features/import/data/models/import_preview_row.dart';
import 'package:money_manager/features/import/data/models/import_row.dart';
import 'package:money_manager/features/import/data/models/import_session.dart';
import 'package:money_manager/features/import/data/services/account_resolver.dart';
import 'package:money_manager/features/import/data/services/category_resolver.dart';
import 'package:money_manager/features/import/data/services/duplicate_detector.dart';
import 'package:money_manager/features/transactions/data/models/account_model.dart';
import 'package:money_manager/features/transactions/data/models/category_model.dart';
import 'package:money_manager/features/transactions/data/models/transaction_model.dart';

class ImportTransactionsUseCase {
  ImportTransactionsUseCase(
    this._isar, {
    AccountResolver? accountResolver,
    CategoryResolver? categoryResolver,
  }) : _accountResolver = accountResolver ?? const AccountResolver(),
       _categoryResolver = categoryResolver ?? const CategoryResolver();

  final Isar _isar;
  final AccountResolver _accountResolver;
  final CategoryResolver _categoryResolver;

  Future<ImportCommitResult> call({
    required ImportSession session,
    required List<ImportPreviewRow> previewRows,
  }) async {
    final selectedRows = previewRows
        .where((preview) => preview.canCommit)
        .map((preview) => preview.row)
        .toList(growable: false);
    final skippedRows = previewRows.length - selectedRows.length;

    final existingAccounts = await _isar.accountModels.where().findAll();
    final existingCategories = await _isar.categoryModels.where().findAll();
    final accountsByName = _accountResolver.indexByName(existingAccounts);
    final expenseCategoriesByName = _categoryResolver.indexByName(
      existingCategories,
      isIncome: false,
    );
    final incomeCategoriesByName = _categoryResolver.indexByName(
      existingCategories,
      isIncome: true,
    );

    var createdAccounts = 0;
    var createdCategories = 0;
    var insertedTransactions = 0;

    await _isar.writeTxn(() async {
      for (final row in selectedRows) {
        switch (row) {
          case ExpenseImportRow():
            final account = await _accountFor(row.accountName, accountsByName);
            final category = await _categoryFor(
              row.categoryName,
              expenseCategoriesByName,
              isIncome: false,
            );
            createdAccounts += account.created ? 1 : 0;
            createdCategories += category.created ? 1 : 0;
            await _isar.transactionModels.put(
              _transactionFromRow(
                row,
                accountId: account.model.id,
                categoryId: category.model.id,
                isIncome: false,
                batchId: session.batchId,
              ),
            );
            insertedTransactions++;
          case IncomeImportRow():
            final account = await _accountFor(row.accountName, accountsByName);
            final category = await _categoryFor(
              row.categoryName,
              incomeCategoriesByName,
              isIncome: true,
            );
            createdAccounts += account.created ? 1 : 0;
            createdCategories += category.created ? 1 : 0;
            await _isar.transactionModels.put(
              _transactionFromRow(
                row,
                accountId: account.model.id,
                categoryId: category.model.id,
                isIncome: true,
                batchId: session.batchId,
              ),
            );
            insertedTransactions++;
          case TransferImportRow():
            final outgoing = await _accountFor(
              row.outgoingAccountName,
              accountsByName,
            );
            final incoming = await _accountFor(
              row.incomingAccountName,
              accountsByName,
            );
            final transferCategory = await _categoryFor(
              DuplicateDetector.transferCategoryName,
              expenseCategoriesByName,
              isIncome: false,
            );
            createdAccounts += outgoing.created ? 1 : 0;
            createdAccounts += incoming.created ? 1 : 0;
            createdCategories += transferCategory.created ? 1 : 0;
            final transferGroupId = '${session.batchId}_${row.rowNumber}';
            await _isar.transactionModels.putAll([
              _transactionFromRow(
                row,
                accountId: outgoing.model.id,
                categoryId: transferCategory.model.id,
                isIncome: false,
                batchId: session.batchId,
                transferGroupId: transferGroupId,
              ),
              _transactionFromRow(
                row,
                accountId: incoming.model.id,
                categoryId: transferCategory.model.id,
                isIncome: true,
                amount: row.incomingAmount ?? row.amount,
                currencyCode: row.incomingCurrencyCode ?? row.currencyCode,
                batchId: session.batchId,
                transferGroupId: transferGroupId,
              ),
            ]);
            insertedTransactions += 2;
        }
      }
    });

    return ImportCommitResult(
      batchId: session.batchId,
      insertedTransactions: insertedTransactions,
      createdAccounts: createdAccounts,
      createdCategories: createdCategories,
      skippedRows: skippedRows,
    );
  }

  Future<_ResolvedAccount> _accountFor(
    String name,
    Map<String, AccountModel> accountsByName,
  ) async {
    final key = AccountResolver.normalize(name);
    final existing = accountsByName[key];
    if (existing != null) return _ResolvedAccount(existing, created: false);

    final account = _accountResolver.buildImportedAccount(name);
    await _isar.accountModels.put(account);
    accountsByName[key] = account;
    return _ResolvedAccount(account, created: true);
  }

  Future<_ResolvedCategory> _categoryFor(
    String name,
    Map<String, CategoryModel> categoriesByName, {
    required bool isIncome,
  }) async {
    final key = CategoryResolver.normalize(name);
    final existing = categoriesByName[key];
    if (existing != null) return _ResolvedCategory(existing, created: false);

    final category = _categoryResolver.buildImportedCategory(
      name,
      isIncome: isIncome,
    );
    await _isar.categoryModels.put(category);
    categoriesByName[key] = category;
    return _ResolvedCategory(category, created: true);
  }

  TransactionModel _transactionFromRow(
    ImportRow row, {
    required int accountId,
    required int categoryId,
    required bool isIncome,
    required String batchId,
    double? amount,
    String? currencyCode,
    String? transferGroupId,
  }) {
    return TransactionModel(
      amount: amount ?? row.amount,
      categoryId: categoryId,
      accountId: accountId,
      date: row.date,
      isIncome: isIncome,
      note: _cleanNote(row.note),
      tags: row.tags,
      currencyCode: currencyCode ?? row.currencyCode,
      originalAmount: row.originalAmount,
      originalCurrencyCode: row.originalCurrencyCode,
      fxRate: row.fxRate,
      transferGroupId: transferGroupId,
      importBatchId: batchId,
      entryType: transferGroupId == null
          ? TransactionEntryType.regular
          : TransactionEntryType.transfer,
    );
  }

  String? _cleanNote(String? note) {
    final clean = note?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }
}

class _ResolvedAccount {
  const _ResolvedAccount(this.model, {required this.created});

  final AccountModel model;
  final bool created;
}

class _ResolvedCategory {
  const _ResolvedCategory(this.model, {required this.created});

  final CategoryModel model;
  final bool created;
}
