import 'dart:ffi';
import 'dart:io';

import 'package:excel/excel.dart' as excel;
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:money_manager/features/import/data/models/import_preview_row.dart';
import 'package:money_manager/features/import/data/parsers/excel_parser.dart';
import 'package:money_manager/features/import/domain/usecases/import_transactions_usecase.dart';
import 'package:money_manager/features/transactions/data/models/account_model.dart';
import 'package:money_manager/features/transactions/data/models/category_model.dart';
import 'package:money_manager/features/transactions/data/models/transaction_model.dart';

void main() {
  testWidgets('imports Excel rows into the ledger', (tester) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      await Isar.initializeIsarCore(
        libraries: {Abi.current(): _isarLibraryPath()},
        download: true,
      );
    }
    final directory = await Directory.systemTemp.createTemp('import_flow_test');
    final isar = await Isar.open(
      [TransactionModelSchema, CategoryModelSchema, AccountModelSchema],
      directory: directory.path,
      name: 'import_flow_test',
    );

    try {
      final file = await _fixture();
      final session = await const ExcelImportParser().parse(file);
      final result = await ImportTransactionsUseCase(isar)(
        session: session,
        previewRows: [
          for (final row in session.rows)
            ImportPreviewRow(
              row: row,
              status: ImportPreviewStatus.ready,
              selected: true,
            ),
        ],
      );
      final txs = await isar.transactionModels.where().findAll();

      expect(result.insertedTransactions, 2);
      expect(txs, hasLength(2));
      expect(txs.where((tx) => tx.isIncome), hasLength(1));
      expect(txs.where((tx) => !tx.isIncome), hasLength(1));
    } finally {
      await isar.close(deleteFromDisk: true);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  });
}

String _isarLibraryPath() {
  final extension = Platform.isWindows
      ? 'dll'
      : Platform.isMacOS
      ? 'dylib'
      : 'so';
  return '${Directory.systemTemp.path}/libisar_import_flow.$extension';
}

Future<File> _fixture() async {
  final workbook = excel.Excel.createExcel();
  workbook.rename('Sheet1', 'Expenses');
  workbook['Expenses'].appendRow([excel.TextCellValue('expenses list')]);
  workbook['Expenses'].appendRow(_header());
  workbook['Expenses'].appendRow([
    excel.DateCellValue(year: 2026, month: 5, day: 8),
    excel.TextCellValue('Food'),
    excel.TextCellValue('Main'),
    const excel.DoubleCellValue(100),
    excel.TextCellValue('INR'),
    const excel.DoubleCellValue(100),
    excel.TextCellValue('INR'),
    excel.TextCellValue(''),
    excel.TextCellValue(''),
    excel.TextCellValue('Dinner'),
    excel.TextCellValue('Test expense'),
  ]);
  workbook['Income'].appendRow([excel.TextCellValue('income list')]);
  workbook['Income'].appendRow(_header());
  workbook['Income'].appendRow([
    excel.DateCellValue(year: 2026, month: 5, day: 8),
    excel.TextCellValue('Salary'),
    excel.TextCellValue('Main'),
    const excel.DoubleCellValue(1000),
    excel.TextCellValue('INR'),
    const excel.DoubleCellValue(1000),
    excel.TextCellValue('INR'),
    excel.TextCellValue(''),
    excel.TextCellValue(''),
    excel.TextCellValue(''),
    excel.TextCellValue('Test income'),
  ]);

  final file = File('${Directory.systemTemp.path}/import_flow_fixture.xlsx');
  return file.writeAsBytes(workbook.save()!, flush: true);
}

List<excel.CellValue> _header() {
  return [
    excel.TextCellValue('Date and time'),
    excel.TextCellValue('Category'),
    excel.TextCellValue('Account'),
    excel.TextCellValue('Amount in default currency'),
    excel.TextCellValue('Default currency'),
    excel.TextCellValue('Amount in account currency'),
    excel.TextCellValue('Account currency'),
    excel.TextCellValue('Transaction amount in transaction currency'),
    excel.TextCellValue('Transaction currency'),
    excel.TextCellValue('Tags'),
    excel.TextCellValue('Comment'),
  ];
}
