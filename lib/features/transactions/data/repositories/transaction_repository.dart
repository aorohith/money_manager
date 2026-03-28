import 'package:isar/isar.dart';

import '../models/transaction_model.dart';

abstract class TransactionRepository {
  Stream<List<TransactionModel>> watchAll({
    bool? isIncome,
    int? categoryId,
    DateTime? from,
    DateTime? to,
  });

  Future<List<TransactionModel>> getAll({
    bool? isIncome,
    int? categoryId,
    DateTime? from,
    DateTime? to,
    String? searchNote,
  });

  Future<TransactionModel?> getById(int id);
  Future<int> add(TransactionModel transaction);
  Future<void> update(TransactionModel transaction);

  /// Soft-delete: sets isDeleted = true.
  Future<void> delete(int id);

  Future<Map<int, double>> getCategorySummary({
    required bool isIncome,
    DateTime? from,
    DateTime? to,
  });

  Future<double> getTotalIncome({DateTime? from, DateTime? to});
  Future<double> getTotalExpense({DateTime? from, DateTime? to});
}

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Stream<List<TransactionModel>> watchAll({
    bool? isIncome,
    int? categoryId,
    DateTime? from,
    DateTime? to,
  }) {
    return _isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .optional(isIncome != null, (q) => q.isIncomeEqualTo(isIncome!))
        .optional(
            categoryId != null, (q) => q.categoryIdEqualTo(categoryId!))
        .optional(from != null, (q) => q.dateGreaterThan(from!))
        .optional(to != null, (q) => q.dateLessThan(to!))
        .sortByDateDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<List<TransactionModel>> getAll({
    bool? isIncome,
    int? categoryId,
    DateTime? from,
    DateTime? to,
    String? searchNote,
  }) async {
    return _isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .optional(isIncome != null, (q) => q.isIncomeEqualTo(isIncome!))
        .optional(
            categoryId != null, (q) => q.categoryIdEqualTo(categoryId!))
        .optional(from != null, (q) => q.dateGreaterThan(from!))
        .optional(to != null, (q) => q.dateLessThan(to!))
        .optional(
            searchNote != null && searchNote.isNotEmpty,
            (q) => q.noteContains(searchNote!, caseSensitive: false))
        .sortByDateDesc()
        .findAll();
  }

  @override
  Future<TransactionModel?> getById(int id) =>
      _isar.transactionModels.get(id);

  @override
  Future<int> add(TransactionModel transaction) async {
    int id = 0;
    await _isar.writeTxn(() async {
      id = await _isar.transactionModels.put(transaction);
    });
    return id;
  }

  @override
  Future<void> update(TransactionModel transaction) async {
    await _isar.writeTxn(
        () async => _isar.transactionModels.put(transaction));
  }

  @override
  Future<void> delete(int id) async {
    final tx = await getById(id);
    if (tx == null) return;
    tx.isDeleted = true;
    await update(tx);
  }

  @override
  Future<Map<int, double>> getCategorySummary({
    required bool isIncome,
    DateTime? from,
    DateTime? to,
  }) async {
    final txs = await getAll(isIncome: isIncome, from: from, to: to);
    final map = <int, double>{};
    for (final tx in txs) {
      map[tx.categoryId] = (map[tx.categoryId] ?? 0) + tx.amount;
    }
    return map;
  }

  @override
  Future<double> getTotalIncome({DateTime? from, DateTime? to}) async {
    final txs = await getAll(isIncome: true, from: from, to: to);
    return txs.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<double> getTotalExpense({DateTime? from, DateTime? to}) async {
    final txs = await getAll(isIncome: false, from: from, to: to);
    return txs.fold<double>(0.0, (sum, t) => sum + t.amount);
  }
}
