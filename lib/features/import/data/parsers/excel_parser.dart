import 'dart:io';

import 'package:excel/excel.dart' as excel;
import 'package:flutter/foundation.dart';
import 'package:money_manager/features/import/data/models/column_mapping.dart';
import 'package:money_manager/features/import/data/models/import_diagnostic.dart';
import 'package:money_manager/features/import/data/models/import_row.dart';
import 'package:money_manager/features/import/data/models/import_session.dart';
import 'package:money_manager/features/import/data/parsers/column_mapper.dart';
import 'package:money_manager/features/import/data/parsers/import_parser.dart';

class ExcelImportParser implements ImportParser {
  const ExcelImportParser();

  @override
  String get formatId => 'xlsx';

  @override
  Future<ImportSession> parse(File file, {ColumnMapping? overrides}) {
    return compute(_parseExcelFile, {
      'path': file.path,
      'overrides': overrides?.columns,
    });
  }
}

ImportSession _parseExcelFile(Map<String, Object?> args) {
  final path = args['path']! as String;
  final overrides = args['overrides'] as Map<String, String>?;
  final bytes = File(path).readAsBytesSync();
  final workbook = excel.Excel.decodeBytes(bytes);
  final rows = <ImportRow>[];
  final diagnostics = <ImportDiagnostic>[];
  final mapper = const ColumnMapper();

  for (final tableName in workbook.tables.keys) {
    final table = workbook.tables[tableName];
    if (table == null) continue;

    final headerIndex = _findHeaderIndex(table.rows);
    if (headerIndex == null) {
      diagnostics.add(
        ImportDiagnostic(
          rowNumber: 0,
          message: 'No supported header row found in sheet "$tableName".',
        ),
      );
      continue;
    }

    final headers = table.rows[headerIndex]
        .map((cell) => _cellText(cell?.value))
        .toList(growable: false);
    final mapping = mapper
        .detect(headers)
        .merge(overrides == null ? null : ColumnMapping(columns: overrides));
    final isTransferSheet =
        tableName.toLowerCase().contains('transfer') ||
        mapping.sourceFor(ImportColumn.outgoingAccount) != null;

    for (var index = headerIndex + 1; index < table.rows.length; index++) {
      final row = table.rows[index];
      if (_isBlankRow(row)) continue;
      final values = _rowMap(headers, row);
      final rowNumber = index + 1;
      final parsed = isTransferSheet
          ? _parseTransferRow(values, mapping, rowNumber)
          : _parseTransactionRow(
              values,
              mapping,
              rowNumber,
              isIncome: tableName.toLowerCase().contains('income'),
            );
      rows.add(parsed);
    }
  }

  return ImportSession(
    batchId: _batchId(),
    filePath: path,
    format: ImportFormat.excel,
    rows: rows,
    diagnostics: diagnostics,
  );
}

int? _findHeaderIndex(List<List<excel.Data?>> rows) {
  for (var index = 0; index < rows.length; index++) {
    final normalized = rows[index]
        .map((cell) => ColumnMapper.normalizeHeader(_cellText(cell?.value)))
        .toSet();
    if (normalized.contains('date and time') || normalized.contains('date')) {
      return index;
    }
  }
  return null;
}

bool _isBlankRow(List<excel.Data?> row) {
  return row.every((cell) => _cellText(cell?.value).trim().isEmpty);
}

Map<String, Object?> _rowMap(List<String> headers, List<excel.Data?> row) {
  final values = <String, Object?>{};
  for (var index = 0; index < headers.length; index++) {
    values[headers[index]] = index < row.length ? row[index]?.value : null;
  }
  return values;
}

ImportRow _parseTransactionRow(
  Map<String, Object?> values,
  ColumnMapping mapping,
  int rowNumber, {
  required bool isIncome,
}) {
  final diagnostics = <ImportDiagnostic>[];
  final date = _requiredDate(
    values,
    mapping,
    ImportColumn.date,
    rowNumber,
    diagnostics: diagnostics,
  );
  final amount = _requiredDouble(
    values,
    mapping,
    ImportColumn.defaultAmount,
    rowNumber,
    diagnostics: diagnostics,
  );
  final category = _requiredText(
    values,
    mapping,
    ImportColumn.category,
    rowNumber,
    diagnostics: diagnostics,
  );
  final account = _requiredText(
    values,
    mapping,
    ImportColumn.account,
    rowNumber,
    diagnostics: diagnostics,
  );
  final currency =
      _text(values, mapping, ImportColumn.defaultCurrency) ?? 'INR';
  final originalAmount =
      _double(values, mapping, ImportColumn.transactionAmount) ??
      _double(values, mapping, ImportColumn.accountAmount);
  final originalCurrency =
      _text(values, mapping, ImportColumn.transactionCurrency) ??
      _text(values, mapping, ImportColumn.accountCurrency);
  final fxRate = originalAmount == null || originalAmount == 0
      ? null
      : amount / originalAmount;

  if (isIncome) {
    return IncomeImportRow(
      rowNumber: rowNumber,
      date: date,
      categoryName: category,
      accountName: account,
      amount: amount,
      currencyCode: currency,
      originalAmount: originalAmount,
      originalCurrencyCode: originalCurrency,
      fxRate: fxRate,
      note: _text(values, mapping, ImportColumn.comment),
      tags: _tags(_text(values, mapping, ImportColumn.tags)),
      diagnostics: diagnostics,
    );
  }

  return ExpenseImportRow(
    rowNumber: rowNumber,
    date: date,
    categoryName: category,
    accountName: account,
    amount: amount,
    currencyCode: currency,
    originalAmount: originalAmount,
    originalCurrencyCode: originalCurrency,
    fxRate: fxRate,
    note: _text(values, mapping, ImportColumn.comment),
    tags: _tags(_text(values, mapping, ImportColumn.tags)),
    diagnostics: diagnostics,
  );
}

ImportRow _parseTransferRow(
  Map<String, Object?> values,
  ColumnMapping mapping,
  int rowNumber,
) {
  final diagnostics = <ImportDiagnostic>[];
  final date = _requiredDate(
    values,
    mapping,
    ImportColumn.date,
    rowNumber,
    diagnostics: diagnostics,
  );
  final amount = _requiredDouble(
    values,
    mapping,
    ImportColumn.outgoingAmount,
    rowNumber,
    diagnostics: diagnostics,
  );
  final outgoing = _requiredText(
    values,
    mapping,
    ImportColumn.outgoingAccount,
    rowNumber,
    diagnostics: diagnostics,
  );
  final incoming = _requiredText(
    values,
    mapping,
    ImportColumn.incomingAccount,
    rowNumber,
    diagnostics: diagnostics,
  );
  final currency =
      _text(values, mapping, ImportColumn.outgoingCurrency) ?? 'INR';
  final incomingAmount = _double(values, mapping, ImportColumn.incomingAmount);
  final incomingCurrency = _text(
    values,
    mapping,
    ImportColumn.incomingCurrency,
  );

  return TransferImportRow(
    rowNumber: rowNumber,
    date: date,
    outgoingAccountName: outgoing,
    incomingAccountName: incoming,
    amount: amount,
    currencyCode: currency,
    incomingAmount: incomingAmount,
    incomingCurrencyCode: incomingCurrency,
    originalAmount: amount,
    originalCurrencyCode: currency,
    note: _text(values, mapping, ImportColumn.comment),
    diagnostics: diagnostics,
  );
}

DateTime _requiredDate(
  Map<String, Object?> values,
  ColumnMapping mapping,
  String column,
  int rowNumber, {
  required List<ImportDiagnostic> diagnostics,
}) {
  final value = values[mapping.sourceFor(column)];
  final parsed = _date(value);
  if (parsed != null) return parsed;
  diagnostics.add(
    ImportDiagnostic(rowNumber: rowNumber, message: 'Missing or invalid date.'),
  );
  return DateTime.fromMillisecondsSinceEpoch(0);
}

double _requiredDouble(
  Map<String, Object?> values,
  ColumnMapping mapping,
  String column,
  int rowNumber, {
  required List<ImportDiagnostic> diagnostics,
}) {
  final parsed = _double(values, mapping, column);
  if (parsed != null) return parsed;
  diagnostics.add(
    ImportDiagnostic(
      rowNumber: rowNumber,
      message: 'Missing or invalid amount.',
    ),
  );
  return 0;
}

String _requiredText(
  Map<String, Object?> values,
  ColumnMapping mapping,
  String column,
  int rowNumber, {
  required List<ImportDiagnostic> diagnostics,
}) {
  final value = _text(values, mapping, column);
  if (value != null && value.isNotEmpty) return value;
  diagnostics.add(
    ImportDiagnostic(
      rowNumber: rowNumber,
      message: 'Missing required value for $column.',
    ),
  );
  return 'Unknown';
}

String? _text(
  Map<String, Object?> values,
  ColumnMapping mapping,
  String column,
) {
  final source = mapping.sourceFor(column);
  if (source == null) return null;
  final text = _cellText(values[source]).trim();
  return text.isEmpty ? null : text;
}

double? _double(
  Map<String, Object?> values,
  ColumnMapping mapping,
  String column,
) {
  final source = mapping.sourceFor(column);
  if (source == null) return null;
  final value = values[source];
  if (value is excel.IntCellValue) return value.value.toDouble();
  if (value is excel.DoubleCellValue) return value.value;
  final text = _cellText(value).replaceAll(',', '').trim();
  if (text.isEmpty) return null;
  return double.tryParse(text);
}

DateTime? _date(Object? value) {
  if (value is excel.DateCellValue) return value.asDateTimeLocal();
  if (value is excel.DateTimeCellValue) return value.asDateTimeLocal();
  final text = _cellText(value);
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

List<String> _tags(String? value) {
  if (value == null || value.trim().isEmpty) return const [];
  return value
      .split(RegExp(r'[,;|]'))
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList(growable: false);
}

String _cellText(Object? value) {
  if (value == null) return '';
  if (value is excel.TextCellValue) return value.value.toString();
  if (value is excel.IntCellValue) return value.value.toString();
  if (value is excel.DoubleCellValue) return value.value.toString();
  if (value is excel.DateCellValue) return value.asDateTimeLocal().toString();
  if (value is excel.DateTimeCellValue) {
    return value.asDateTimeLocal().toString();
  }
  return value.toString();
}

String _batchId() => 'imp_${DateTime.now().microsecondsSinceEpoch}';
