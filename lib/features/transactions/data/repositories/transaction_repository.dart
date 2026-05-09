import 'package:isar/isar.dart';

import '../models/account_model.dart';
import '../models/transaction_model.dart';

/// Contract for all transaction persistence operations.
///
/// All queries automatically exclude soft-deleted records
/// (`isDeleted == true`) unless noted otherwise.
abstract class TransactionRepository {
  /// Returns a live stream that re-emits whenever the filtered set changes.
  /// [limit] caps the stream result to prevent full-table loads on large
  /// datasets. Defaults to 100 — pass a larger value only when necessary.
  Stream<List<TransactionModel>> watchAll({
    bool? isIncome,
    int? categoryId,
    int? accountId,
    DateTime? from,
    DateTime? to,
    int limit = 100,
  });

  /// One-shot fetch of transactions matching the given filters.
  /// Use [limit] + [offset] for cursor-style pagination.
  Future<List<TransactionModel>> getAll({
    bool? isIncome,
    int? categoryId,
    int? accountId,
    DateTime? from,
    DateTime? to,
    String? searchNote,
    int? limit,
    int offset = 0,
  });

  /// Total number of non-deleted transactions matching the given filters.
  /// Use this to compute page counts for paginated UIs.
  Future<int> getCount({
    bool? isIncome,
    int? categoryId,
    int? accountId,
    DateTime? from,
    DateTime? to,
  });

  Future<TransactionModel?> getById(int id);

  /// Persists a new transaction and returns the generated Isar ID.
  Future<int> add(TransactionModel transaction);

  Future<void> update(TransactionModel transaction);

  /// Soft-delete: sets [TransactionModel.isDeleted] = true so that the record
  /// stays in the database for audit/undo purposes but is hidden from all
  /// normal queries.
  Future<void> delete(int id);

  /// Adds [transaction] and writes [account] in a single Isar transaction.
  /// Used by reconciliation to keep the ledger consistent — partial failure
  /// of either write rolls back both.
  Future<int> addWithAccountUpdate({
    required TransactionModel transaction,
    required AccountModel account,
  });

  /// Returns a map of `categoryId → total amount` for the given period.
  ///
  /// When [baseCurrencyCode] is provided, transactions whose [currencyCode]
  /// is non-null and doesn't match are excluded from the sum so that
  /// imported foreign-currency rows can't pollute base-currency totals.
  Future<Map<int, double>> getCategorySummary({
    required bool isIncome,
    DateTime? from,
    DateTime? to,
    String? baseCurrencyCode,
  });

  Future<double> getTotalIncome({
    DateTime? from,
    DateTime? to,
    String? baseCurrencyCode,
  });
  Future<double> getTotalExpense({
    DateTime? from,
    DateTime? to,
    String? baseCurrencyCode,
  });

  /// Live stream of the computed balance for a single account.
  /// Balance = initialBalance is NOT stored here — it is owned by AccountModel.
  /// This stream yields the net transaction delta (income − expense) for the
  /// account so that callers can add it to AccountModel.initialBalance.
  Stream<double> watchTransactionDeltaForAccount(
    int accountId, {
    String? baseCurrencyCode,
  });

  /// One-shot fetch of the net transaction delta (income − expense) for an
  /// account. Add AccountModel.initialBalance to get the running balance.
  Future<double> getTransactionDeltaForAccount(
    int accountId, {
    String? baseCurrencyCode,
  });
}

/// Returns true when [tx] should contribute to a base-currency aggregation.
///
/// * Always include rows with no [TransactionModel.currencyCode] (manual
///   entries created before multi-currency was introduced — they're assumed
///   to already be in base currency).
/// * Include rows whose currency matches [baseCurrencyCode] case-insensitively.
/// * Skip everything else; we do not yet store live FX rates so summing
///   foreign amounts in with the base currency would be misleading.
bool _isBaseCurrencyRow(TransactionModel tx, String? baseCurrencyCode) {
  if (baseCurrencyCode == null || baseCurrencyCode.isEmpty) return true;
  final code = tx.currencyCode;
  if (code == null || code.isEmpty) return true;
  return code.toUpperCase() == baseCurrencyCode.toUpperCase();
}

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Stream<List<TransactionModel>> watchAll({
    bool? isIncome,
    int? categoryId,
    int? accountId,
    DateTime? from,
    DateTime? to,
    int limit = 100,
  }) {
    return _isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .optional(isIncome != null, (q) => q.isIncomeEqualTo(isIncome!))
        .optional(categoryId != null, (q) => q.categoryIdEqualTo(categoryId!))
        .optional(accountId != null, (q) => q.accountIdEqualTo(accountId!))
        .optional(from != null, (q) => q.dateGreaterThan(from!))
        .optional(to != null, (q) => q.dateLessThan(to!))
        .sortByDateDesc()
        .limit(limit)
        .watch(fireImmediately: true);
  }

  @override
  Future<List<TransactionModel>> getAll({
    bool? isIncome,
    int? categoryId,
    int? accountId,
    DateTime? from,
    DateTime? to,
    String? searchNote,
    int? limit,
    int offset = 0,
  }) async {
    final q = _isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .optional(isIncome != null, (q) => q.isIncomeEqualTo(isIncome!))
        .optional(categoryId != null, (q) => q.categoryIdEqualTo(categoryId!))
        .optional(accountId != null, (q) => q.accountIdEqualTo(accountId!))
        .optional(from != null, (q) => q.dateGreaterThan(from!))
        .optional(to != null, (q) => q.dateLessThan(to!))
        .optional(
          searchNote != null && searchNote.isNotEmpty,
          (q) => q.noteContains(searchNote!, caseSensitive: false),
        )
        .sortByDateDesc();

    if (limit != null) {
      return q.offset(offset).limit(limit).findAll();
    }
    return q.findAll();
  }

  @override
  Future<int> getCount({
    bool? isIncome,
    int? categoryId,
    int? accountId,
    DateTime? from,
    DateTime? to,
  }) {
    return _isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .optional(isIncome != null, (q) => q.isIncomeEqualTo(isIncome!))
        .optional(categoryId != null, (q) => q.categoryIdEqualTo(categoryId!))
        .optional(accountId != null, (q) => q.accountIdEqualTo(accountId!))
        .optional(from != null, (q) => q.dateGreaterThan(from!))
        .optional(to != null, (q) => q.dateLessThan(to!))
        .count();
  }

  @override
  Future<TransactionModel?> getById(int id) => _isar.transactionModels.get(id);

  @override
  Future<int> add(TransactionModel transaction) async {
    transaction.updatedAt = DateTime.now();
    int id = 0;
    await _isar.writeTxn(() async {
      id = await _isar.transactionModels.put(transaction);
    });
    return id;
  }

  @override
  Future<void> update(TransactionModel transaction) async {
    transaction.updatedAt = DateTime.now();
    await _isar.writeTxn(() async => _isar.transactionModels.put(transaction));
  }

  @override
  Future<void> delete(int id) async {
    final tx = await getById(id);
    if (tx == null) return;
    final groupId = tx.transferGroupId;
    final now = DateTime.now();

    await _isar.writeTxn(() async {
      // Transfers persist as two paired rows that share a [transferGroupId].
      // Soft-deleting a single leg would leave one half active and corrupt
      // both account balances, so we delete every leg in the group atomically.
      if (groupId != null && groupId.isNotEmpty) {
        final legs = await _isar.transactionModels
            .filter()
            .transferGroupIdEqualTo(groupId)
            .isDeletedEqualTo(false)
            .findAll();
        for (final leg in legs) {
          leg.isDeleted = true;
          leg.updatedAt = now;
        }
        if (legs.isNotEmpty) {
          await _isar.transactionModels.putAll(legs);
        }
        return;
      }
      tx.isDeleted = true;
      tx.updatedAt = now;
      await _isar.transactionModels.put(tx);
    });
  }

  @override
  Future<int> addWithAccountUpdate({
    required TransactionModel transaction,
    required AccountModel account,
  }) async {
    final now = DateTime.now();
    transaction.updatedAt = now;
    account.updatedAt = now;
    var id = 0;
    await _isar.writeTxn(() async {
      id = await _isar.transactionModels.put(transaction);
      await _isar.accountModels.put(account);
    });
    return id;
  }

  @override
  Future<Map<int, double>> getCategorySummary({
    required bool isIncome,
    DateTime? from,
    DateTime? to,
    String? baseCurrencyCode,
  }) async {
    final txs = await getAll(isIncome: isIncome, from: from, to: to);
    final map = <int, double>{};
    for (final tx in txs) {
      if (!_isBaseCurrencyRow(tx, baseCurrencyCode)) continue;
      map[tx.categoryId] = (map[tx.categoryId] ?? 0) + tx.amount;
    }
    return map;
  }

  @override
  Future<double> getTotalIncome({
    DateTime? from,
    DateTime? to,
    String? baseCurrencyCode,
  }) async {
    final txs = await getAll(isIncome: true, from: from, to: to);
    return txs
        .where((t) => _isBaseCurrencyRow(t, baseCurrencyCode))
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<double> getTotalExpense({
    DateTime? from,
    DateTime? to,
    String? baseCurrencyCode,
  }) async {
    final txs = await getAll(isIncome: false, from: from, to: to);
    return txs
        .where((t) => _isBaseCurrencyRow(t, baseCurrencyCode))
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Stream<double> watchTransactionDeltaForAccount(
    int accountId, {
    String? baseCurrencyCode,
  }) {
    return _isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .accountIdEqualTo(accountId)
        .watch(fireImmediately: true)
        .map((txs) => _foldDelta(txs, baseCurrencyCode));
  }

  @override
  Future<double> getTransactionDeltaForAccount(
    int accountId, {
    String? baseCurrencyCode,
  }) async {
    final txs = await _isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .accountIdEqualTo(accountId)
        .findAll();
    return _foldDelta(txs, baseCurrencyCode);
  }

  static double _foldDelta(
    List<TransactionModel> txs,
    String? baseCurrencyCode,
  ) {
    return txs.where((t) => _isBaseCurrencyRow(t, baseCurrencyCode)).fold<double>(
      0.0,
      (sum, t) => t.isIncome ? sum + t.amount : sum - t.amount,
    );
  }
}
