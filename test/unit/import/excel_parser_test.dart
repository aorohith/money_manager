import 'dart:io';

import 'package:excel/excel.dart' as excel;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/import/data/models/import_row.dart';
import 'package:money_manager/features/import/data/parsers/excel_parser.dart';

void main() {
  group('ExcelImportParser', () {
    test('parses expenses, income, transfers, tags, and currencies', () async {
      final file = await _sampleWorkbook();

      final session = await const ExcelImportParser().parse(file);

      expect(session.rows, hasLength(3));
      final expense = session.rows[0] as ExpenseImportRow;
      expect(expense.categoryName, 'Food');
      expect(expense.accountName, 'Main');
      expect(expense.tags, ['KFC', 'Dinner']);
      expect(expense.currencyCode, 'INR');

      final income = session.rows[1] as IncomeImportRow;
      expect(income.categoryName, 'Salary');
      expect(income.amount, 50000);

      final transfer = session.rows[2] as TransferImportRow;
      expect(transfer.outgoingAccountName, 'Main');
      expect(transfer.incomingAccountName, 'Credit Card');
      expect(transfer.amount, 1000);
    });
  });
}

Future<File> _sampleWorkbook() async {
  final workbook = excel.Excel.createExcel();
  workbook.rename('Sheet1', 'Expenses');
  workbook['Expenses'].appendRow([excel.TextCellValue('expenses list')]);
  workbook['Expenses'].appendRow(_transactionHeader());
  workbook['Expenses'].appendRow([
    excel.DateCellValue(year: 2026, month: 5, day: 8),
    excel.TextCellValue('Food'),
    excel.TextCellValue('Main'),
    const excel.DoubleCellValue(573),
    excel.TextCellValue('INR'),
    const excel.DoubleCellValue(573),
    excel.TextCellValue('INR'),
    excel.TextCellValue(''),
    excel.TextCellValue(''),
    excel.TextCellValue('KFC,Dinner'),
    excel.TextCellValue('Lunch'),
  ]);

  workbook['Income'].appendRow([excel.TextCellValue('income list')]);
  workbook['Income'].appendRow(_transactionHeader());
  workbook['Income'].appendRow([
    excel.DateCellValue(year: 2026, month: 5, day: 8),
    excel.TextCellValue('Salary'),
    excel.TextCellValue('Main'),
    const excel.DoubleCellValue(50000),
    excel.TextCellValue('INR'),
    const excel.DoubleCellValue(50000),
    excel.TextCellValue('INR'),
    excel.TextCellValue(''),
    excel.TextCellValue(''),
    excel.TextCellValue(''),
    excel.TextCellValue('Salary'),
  ]);

  workbook['Transfers'].appendRow([excel.TextCellValue('transfers list')]);
  workbook['Transfers'].appendRow([
    excel.TextCellValue('Date and time'),
    excel.TextCellValue('Outgoing'),
    excel.TextCellValue('Incoming'),
    excel.TextCellValue('Amount in outgoing currency'),
    excel.TextCellValue('Outgoing currency'),
    excel.TextCellValue('Amount in incoming currency'),
    excel.TextCellValue('Incoming currency'),
    excel.TextCellValue('Comment'),
  ]);
  workbook['Transfers'].appendRow([
    excel.DateCellValue(year: 2026, month: 5, day: 9),
    excel.TextCellValue('Main'),
    excel.TextCellValue('Credit Card'),
    const excel.DoubleCellValue(1000),
    excel.TextCellValue('INR'),
    excel.TextCellValue(''),
    excel.TextCellValue(''),
    excel.TextCellValue('Payment'),
  ]);

  final bytes = workbook.save()!;
  final file = File('${Directory.systemTemp.path}/import_parser_test.xlsx');
  return file.writeAsBytes(bytes, flush: true);
}

List<excel.CellValue> _transactionHeader() {
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
