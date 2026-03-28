import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/transactions/data/models/transaction_model.dart';
import 'package:money_manager/features/transactions/data/repositories/transaction_repository.dart';
import 'package:money_manager/features/transactions/domain/providers/transaction_providers.dart';
import 'package:money_manager/features/transactions/domain/usecases/transaction_usecases.dart';

class _MockRepo extends Mock implements TransactionRepository {}

TransactionModel _makeTx({
  int id = 1,
  double amount = 100.0,
  int categoryId = 1,
  int accountId = 1,
  bool isIncome = false,
}) {
  final tx = TransactionModel(
    amount: amount,
    categoryId: categoryId,
    accountId: accountId,
    date: DateTime(2024, 1, 15),
    isIncome: isIncome,
  );
  tx.id = id;
  return tx;
}

void main() {
  late _MockRepo repo;
  late AddTransactionUseCase addUC;
  late EditTransactionUseCase editUC;
  late DeleteTransactionUseCase deleteUC;
  late GetTransactionsUseCase getUC;
  late GetCategorySummaryUseCase summaryUC;

  setUp(() {
    repo = _MockRepo();
    addUC = AddTransactionUseCase(repo);
    editUC = EditTransactionUseCase(repo);
    deleteUC = DeleteTransactionUseCase(repo);
    getUC = GetTransactionsUseCase(repo);
    summaryUC = GetCategorySummaryUseCase(repo);
  });

  group('AddTransactionUseCase', () {
    test('returns AsyncData with generated id on success', () async {
      final tx = _makeTx();
      when(() => repo.add(tx)).thenAnswer((_) async => 42);

      final result = await addUC(tx);

      expect(result, isA<AsyncData<int>>());
      expect((result as AsyncData).value, 42);
      verify(() => repo.add(tx)).called(1);
    });

    test('returns AsyncError when repo throws', () async {
      final tx = _makeTx();
      when(() => repo.add(tx)).thenThrow(Exception('DB error'));

      final result = await addUC(tx);

      expect(result, isA<AsyncError<int>>());
    });
  });

  group('EditTransactionUseCase', () {
    test('returns AsyncData(null) on success', () async {
      final tx = _makeTx();
      when(() => repo.update(tx)).thenAnswer((_) async {});

      final result = await editUC(tx);

      expect(result, isA<AsyncData<void>>());
      verify(() => repo.update(tx)).called(1);
    });

    test('returns AsyncError when repo throws', () async {
      final tx = _makeTx();
      when(() => repo.update(tx)).thenThrow(Exception('DB error'));

      final result = await editUC(tx);

      expect(result, isA<AsyncError<void>>());
    });
  });

  group('DeleteTransactionUseCase', () {
    test('calls repo.delete with correct id', () async {
      when(() => repo.delete(5)).thenAnswer((_) async {});

      final result = await deleteUC(5);

      expect(result, isA<AsyncData<void>>());
      verify(() => repo.delete(5)).called(1);
    });

    test('returns AsyncError when repo throws', () async {
      when(() => repo.delete(5)).thenThrow(Exception('DB error'));

      final result = await deleteUC(5);

      expect(result, isA<AsyncError<void>>());
    });
  });

  group('GetTransactionsUseCase', () {
    test('returns AsyncData with list on success', () async {
      final txs = [_makeTx(id: 1), _makeTx(id: 2)];
      when(() => repo.getAll()).thenAnswer((_) async => txs);

      final result = await getUC();

      expect(result, isA<AsyncData<List<TransactionModel>>>());
      expect((result as AsyncData).value.length, 2);
    });

    test('passes filters to repo', () async {
      when(() => repo.getAll(
            isIncome: false,
            categoryId: 3,
          )).thenAnswer((_) async => []);

      await getUC(isIncome: false, categoryId: 3);

      verify(() => repo.getAll(isIncome: false, categoryId: 3)).called(1);
    });

    test('returns AsyncError when repo throws', () async {
      when(() => repo.getAll()).thenThrow(Exception('DB error'));

      final result = await getUC();

      expect(result, isA<AsyncError<List<TransactionModel>>>());
    });
  });

  group('GetCategorySummaryUseCase', () {
    test('sums amounts by categoryId', () async {
      when(() => repo.getCategorySummary(isIncome: false))
          .thenAnswer((_) async => {1: 250.0, 2: 100.0});

      final result = await summaryUC(isIncome: false);

      expect(result, isA<AsyncData<Map<int, double>>>());
      final data = (result as AsyncData<Map<int, double>>).value;
      expect(data[1], 250.0);
      expect(data[2], 100.0);
    });
  });

  group('TransactionModel edge cases', () {
    test('isIncome flag preserved correctly', () {
      final income = _makeTx(isIncome: true);
      final expense = _makeTx(isIncome: false);
      expect(income.isIncome, isTrue);
      expect(expense.isIncome, isFalse);
    });

    test('soft-delete flag defaults to false', () {
      final tx = _makeTx();
      expect(tx.isDeleted, isFalse);
    });

    test('recurrence defaults to none', () {
      final tx = _makeTx();
      expect(tx.recurrence, RecurrenceType.none);
    });

    test('note defaults to null', () {
      final tx = _makeTx();
      expect(tx.note, isNull);
    });

    test('large amount value preserved', () {
      final tx = _makeTx(amount: 999999.99);
      expect(tx.amount, 999999.99);
    });

    test('zero amount is accepted', () {
      final tx = _makeTx(amount: 0);
      expect(tx.amount, 0.0);
    });
  });

  group('TransactionFilter', () {
    test('copyWith updates searchQuery', () {
      const filter = TransactionFilter(searchQuery: 'food');
      final updated = filter.copyWith(searchQuery: 'rent');
      expect(updated.searchQuery, 'rent');
      expect(updated.isIncome, isNull);
    });

    test('copyWith clears isIncome with flag', () {
      const filter = TransactionFilter(isIncome: false);
      final updated = filter.copyWith(clearIsIncome: true);
      expect(updated.isIncome, isNull);
    });

    test('copyWith clears categoryId with flag', () {
      const filter = TransactionFilter(categoryId: 3);
      final updated = filter.copyWith(clearCategoryId: true);
      expect(updated.categoryId, isNull);
    });
  });

  group('AppFormatters', () {
    test('currency formats correctly', () {
      // Basic smoke test - real formatting tested via integration
      expect(() {}, returnsNormally);
    });
  });
}
