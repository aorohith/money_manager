import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/settings/data/export_service.dart';
import 'package:money_manager/features/transactions/data/repositories/transaction_repository.dart';

import '../../helpers/test_factories.dart';

class _MockRepo extends Mock implements TransactionRepository {}

void main() {
  late _MockRepo repo;

  final categories = [
    makeCat(id: 1, name: 'Food'),
    makeCat(id: 2, name: 'Transport'),
    makeCat(id: 3, name: 'Salary', isIncome: true),
  ];

  setUp(() {
    repo = _MockRepo();
  });

  // ── buildCsvRows (pure, no I/O) ────────────────────────────────────────────

  group('buildCsvRows', () {
    test('first row is the header', () {
      final service = ExportService(repo, categories);
      final rows = service.buildCsvRows([]);
      expect(rows.first, ['Date', 'Type', 'Category', 'Amount', 'Note']);
    });

    test('empty transactions produces header-only output', () {
      final service = ExportService(repo, categories);
      final rows = service.buildCsvRows([]);
      expect(rows.length, 1);
    });

    test('expense transaction maps to correct columns', () {
      final service = ExportService(repo, categories);
      final tx = makeTx(
        id: 1,
        amount: 45.50,
        categoryId: 1,
        isIncome: false,
        date: DateTime(2024, 3, 15),
        note: 'Lunch',
      );

      final rows = service.buildCsvRows([tx]);
      expect(rows.length, 2);

      final row = rows[1];
      expect(row[0], '2024-03-15'); // Date
      expect(row[1], 'Expense'); // Type
      expect(row[2], 'Food'); // Category
      expect(row[3], '45.50'); // Amount
      expect(row[4], 'Lunch'); // Note
    });

    test('income transaction has "Income" type', () {
      final service = ExportService(repo, categories);
      final tx = makeTx(
        id: 2,
        amount: 3000.0,
        categoryId: 3,
        isIncome: true,
        date: DateTime(2024, 3, 1),
      );

      final rows = service.buildCsvRows([tx]);
      final row = rows[1];
      expect(row[1], 'Income');
      expect(row[2], 'Salary');
    });

    test('missing note defaults to empty string', () {
      final service = ExportService(repo, categories);
      final tx = makeTx(id: 3, note: null);

      final rows = service.buildCsvRows([tx]);
      expect(rows[1][4], '');
    });

    test('unknown category id falls back to "Unknown"', () {
      final service = ExportService(repo, categories);
      final tx = makeTx(id: 4, categoryId: 999);

      final rows = service.buildCsvRows([tx]);
      expect(rows[1][2], 'Unknown');
    });

    test('multiple transactions produce multiple rows', () {
      final service = ExportService(repo, categories);
      final txs = [
        makeTx(id: 1, categoryId: 1, amount: 10),
        makeTx(id: 2, categoryId: 2, amount: 20),
        makeTx(id: 3, categoryId: 3, amount: 30, isIncome: true),
      ];

      final rows = service.buildCsvRows(txs);
      expect(rows.length, 4); // 1 header + 3 data
    });

    test('amount is formatted to 2 decimal places', () {
      final service = ExportService(repo, categories);
      final tx = makeTx(id: 1, amount: 99.9);

      final rows = service.buildCsvRows([tx]);
      expect(rows[1][3], '99.90');
    });

    test('date is formatted as yyyy-MM-dd', () {
      final service = ExportService(repo, categories);
      final tx = makeTx(id: 1, date: DateTime(2024, 1, 5));

      final rows = service.buildCsvRows([tx]);
      expect(rows[1][0], '2024-01-05');
    });
  });

  // ── exportCsv delegates to repo ───────────────────────────────────────────

  group('exportCsv', () {
    test('calls repo.getAll() once', () async {
      when(() => repo.getAll()).thenAnswer((_) async => []);
      final service = ExportService(repo, categories);

      await expectLater(service.exportCsv(), throwsA(isA<Object>()));

      verify(() => repo.getAll()).called(1);
    });
  });

  // ── exportPdf delegates to repo ───────────────────────────────────────────

  group('exportPdf', () {
    test('calls repo.getAll() once', () async {
      when(() => repo.getAll()).thenAnswer((_) async => []);
      final service = ExportService(repo, categories);

      await expectLater(service.exportPdf(), throwsA(isA<Object>()));

      verify(() => repo.getAll()).called(1);
    });
  });
}
