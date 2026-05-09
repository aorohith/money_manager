@Tags(['manual'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/import/data/models/import_row.dart';
import 'package:money_manager/features/import/data/parsers/excel_parser.dart';

/// Smoke-tests the manually-prepared cleaned sample workbook against the real
/// [ExcelImportParser]. Skipped automatically when the file isn't on disk so
/// the suite stays green for everyone else; opt-in via:
///
///   flutter test --tags manual test/unit/import/cleaned_sample_smoke_test.dart
const _cleanedFilePath =
    '/Users/rohith/Downloads/money_manager_import_sample_cleaned.xlsx';

void main() {
  test('cleaned 1Money export parses without missing-required diagnostics',
      () async {
    final file = File(_cleanedFilePath);
    if (!file.existsSync()) {
      markTestSkipped('Cleaned sample not present at $_cleanedFilePath');
      return;
    }

    final session = await const ExcelImportParser().parse(file);

    final expenses = session.rows.whereType<ExpenseImportRow>().toList();
    final incomes = session.rows.whereType<IncomeImportRow>().toList();
    final transfers = session.rows.whereType<TransferImportRow>().toList();

    expect(expenses, isNotEmpty);
    expect(incomes, isNotEmpty);
    expect(transfers, isNotEmpty);

    final rowsWithDiagnostics =
        session.rows.where((r) => r.diagnostics.isNotEmpty).toList();
    expect(
      rowsWithDiagnostics,
      isEmpty,
      reason: 'No row should produce a parser-level diagnostic. '
          'Got: ${rowsWithDiagnostics.map((r) => r.diagnostics).toList()}',
    );

    final allCategories = <String>{
      ...expenses.map((e) => e.categoryName),
      ...incomes.map((i) => i.categoryName),
    };
    expect(allCategories.contains('Food & Dining'), isTrue);
    expect(allCategories.contains('Salary'), isTrue);

    final allAccounts = <String>{
      ...expenses.map((e) => e.accountName),
      ...incomes.map((i) => i.accountName),
      ...transfers.expand(
        (t) => [t.outgoingAccountName, t.incomingAccountName],
      ),
    };
    expect(allAccounts.contains('Main'), isTrue);
    expect(allAccounts.contains('HDFC Credit Card'), isTrue);
    expect(allAccounts.contains('Utkarsh Credit Card'), isTrue);
  });
}
