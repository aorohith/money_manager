import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../core/database/isar_service.dart';
import '../../data/models/account_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/seed/default_accounts.dart';
import '../../data/seed/default_categories.dart';
import '../usecases/transaction_usecases.dart';

// ── Repositories ─────────────────────────────────────────────────────────────

final transactionRepositoryProvider =
    Provider<TransactionRepository>((ref) {
  final isar = ref.read(isarProvider);
  return TransactionRepositoryImpl(isar);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final isar = ref.read(isarProvider);
  return CategoryRepositoryImpl(isar);
});

// ── Use cases ─────────────────────────────────────────────────────────────────

final addTransactionUseCaseProvider =
    Provider<AddTransactionUseCase>((ref) {
  return AddTransactionUseCase(ref.read(transactionRepositoryProvider));
});

final editTransactionUseCaseProvider =
    Provider<EditTransactionUseCase>((ref) {
  return EditTransactionUseCase(ref.read(transactionRepositoryProvider));
});

final deleteTransactionUseCaseProvider =
    Provider<DeleteTransactionUseCase>((ref) {
  return DeleteTransactionUseCase(ref.read(transactionRepositoryProvider));
});

// ── Filter state ──────────────────────────────────────────────────────────────

class TransactionFilter {
  const TransactionFilter({
    this.isIncome,
    this.categoryId,
    this.from,
    this.to,
    this.searchQuery = '',
  });

  final bool? isIncome;
  final int? categoryId;
  final DateTime? from;
  final DateTime? to;
  final String searchQuery;

  TransactionFilter copyWith({
    bool? isIncome,
    int? categoryId,
    DateTime? from,
    DateTime? to,
    String? searchQuery,
    bool clearIsIncome = false,
    bool clearCategoryId = false,
  }) {
    return TransactionFilter(
      isIncome: clearIsIncome ? null : (isIncome ?? this.isIncome),
      categoryId:
          clearCategoryId ? null : (categoryId ?? this.categoryId),
      from: from ?? this.from,
      to: to ?? this.to,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final transactionFilterProvider =
    StateProvider<TransactionFilter>((_) => const TransactionFilter());

// ── Transaction list (AsyncNotifier) ─────────────────────────────────────────

final transactionListProvider =
    AsyncNotifierProvider<TransactionListNotifier, List<TransactionModel>>(
        TransactionListNotifier.new);

class TransactionListNotifier
    extends AsyncNotifier<List<TransactionModel>> {
  StreamSubscription<List<TransactionModel>>? _sub;

  @override
  Future<List<TransactionModel>> build() async {
    final filter = ref.watch(transactionFilterProvider);
    final repo = ref.read(transactionRepositoryProvider);

    // Cancel previous stream sub before creating new one
    await _sub?.cancel();

    final completer = Completer<List<TransactionModel>>();

    _sub = repo
        .watchAll(
          isIncome: filter.isIncome,
          categoryId: filter.categoryId,
          from: filter.from,
          to: filter.to,
        )
        .listen((txs) {
          // Apply client-side text search (debounced in UI)
          final filtered = filter.searchQuery.isEmpty
              ? txs
              : txs
                  .where((t) =>
                      t.note
                          ?.toLowerCase()
                          .contains(filter.searchQuery.toLowerCase()) ??
                      false)
                  .toList();

          if (!completer.isCompleted) {
            completer.complete(filtered);
          } else {
            state = AsyncData(filtered);
          }
        });

    ref.onDispose(() => _sub?.cancel());
    return completer.future;
  }
}

// ── Categories ────────────────────────────────────────────────────────────────

final categoriesProvider =
    StreamProvider<List<CategoryModel>>((ref) {
  final repo = ref.read(categoryRepositoryProvider);
  return repo.watchAll();
});

final expenseCategoriesProvider =
    Provider<AsyncValue<List<CategoryModel>>>((ref) {
  return ref
      .watch(categoriesProvider)
      .whenData((cats) => cats.where((c) => !c.isIncome).toList());
});

final incomeCategoriesProvider =
    Provider<AsyncValue<List<CategoryModel>>>((ref) {
  return ref
      .watch(categoriesProvider)
      .whenData((cats) => cats.where((c) => c.isIncome).toList());
});

// ── Database seeder ───────────────────────────────────────────────────────────

final dbSeederProvider = FutureProvider<void>((ref) async {
  final isar = ref.read(isarProvider);

  // Seed categories once
  final existingCats = await isar.categoryModels.count();
  if (existingCats == 0) {
    await isar.writeTxn(() async {
      await isar.categoryModels.putAll(defaultCategories);
    });
  }

  // Seed accounts once
  final existingAccounts = await isar.accountModels.count();
  if (existingAccounts == 0) {
    await isar.writeTxn(() async {
      await isar.accountModels.putAll(defaultAccounts);
    });
  }
});

// ── Account list ──────────────────────────────────────────────────────────────

final accountsProvider = FutureProvider<List<AccountModel>>((ref) async {
  // Watch seeder first to ensure defaults exist
  await ref.watch(dbSeederProvider.future);
  final isar = ref.read(isarProvider);
  return isar.accountModels.where().findAll();
});
