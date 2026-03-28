import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class AddTransactionUseCase {
  AddTransactionUseCase(this._repo);
  final TransactionRepository _repo;

  Future<AsyncValue<int>> call(TransactionModel transaction) async {
    try {
      final id = await _repo.add(transaction);
      return AsyncData(id);
    } catch (e, st) {
      return AsyncError(e, st);
    }
  }
}

class EditTransactionUseCase {
  EditTransactionUseCase(this._repo);
  final TransactionRepository _repo;

  Future<AsyncValue<void>> call(TransactionModel transaction) async {
    try {
      await _repo.update(transaction);
      return const AsyncData(null);
    } catch (e, st) {
      return AsyncError(e, st);
    }
  }
}

class DeleteTransactionUseCase {
  DeleteTransactionUseCase(this._repo);
  final TransactionRepository _repo;

  Future<AsyncValue<void>> call(int id) async {
    try {
      await _repo.delete(id);
      return const AsyncData(null);
    } catch (e, st) {
      return AsyncError(e, st);
    }
  }
}

class GetTransactionsUseCase {
  GetTransactionsUseCase(this._repo);
  final TransactionRepository _repo;

  Future<AsyncValue<List<TransactionModel>>> call({
    bool? isIncome,
    int? categoryId,
    DateTime? from,
    DateTime? to,
    String? searchNote,
  }) async {
    try {
      final txs = await _repo.getAll(
        isIncome: isIncome,
        categoryId: categoryId,
        from: from,
        to: to,
        searchNote: searchNote,
      );
      return AsyncData(txs);
    } catch (e, st) {
      return AsyncError(e, st);
    }
  }
}

class GetCategorySummaryUseCase {
  GetCategorySummaryUseCase(this._repo);
  final TransactionRepository _repo;

  Future<AsyncValue<Map<int, double>>> call({
    required bool isIncome,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final summary = await _repo.getCategorySummary(
          isIncome: isIncome, from: from, to: to);
      return AsyncData(summary);
    } catch (e, st) {
      return AsyncError(e, st);
    }
  }
}
