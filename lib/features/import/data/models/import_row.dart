import 'package:money_manager/features/import/data/models/import_diagnostic.dart';

sealed class ImportRow {
  const ImportRow({
    required this.rowNumber,
    required this.date,
    required this.amount,
    required this.currencyCode,
    this.originalAmount,
    this.originalCurrencyCode,
    this.fxRate,
    this.note,
    this.tags = const [],
    this.diagnostics = const [],
  });

  final int rowNumber;
  final DateTime date;
  final double amount;
  final String currencyCode;
  final double? originalAmount;
  final String? originalCurrencyCode;
  final double? fxRate;
  final String? note;
  final List<String> tags;
  final List<ImportDiagnostic> diagnostics;

  bool get hasErrors => diagnostics.any((diagnostic) => diagnostic.isError);
}

class ExpenseImportRow extends ImportRow {
  const ExpenseImportRow({
    required super.rowNumber,
    required super.date,
    required this.categoryName,
    required this.accountName,
    required super.amount,
    required super.currencyCode,
    super.originalAmount,
    super.originalCurrencyCode,
    super.fxRate,
    super.note,
    super.tags,
    super.diagnostics,
  });

  final String categoryName;
  final String accountName;
}

class IncomeImportRow extends ImportRow {
  const IncomeImportRow({
    required super.rowNumber,
    required super.date,
    required this.categoryName,
    required this.accountName,
    required super.amount,
    required super.currencyCode,
    super.originalAmount,
    super.originalCurrencyCode,
    super.fxRate,
    super.note,
    super.tags,
    super.diagnostics,
  });

  final String categoryName;
  final String accountName;
}

class TransferImportRow extends ImportRow {
  const TransferImportRow({
    required super.rowNumber,
    required super.date,
    required this.outgoingAccountName,
    required this.incomingAccountName,
    required super.amount,
    required super.currencyCode,
    this.incomingAmount,
    this.incomingCurrencyCode,
    super.originalAmount,
    super.originalCurrencyCode,
    super.fxRate,
    super.note,
    super.tags,
    super.diagnostics,
  });

  final String outgoingAccountName;
  final String incomingAccountName;
  final double? incomingAmount;
  final String? incomingCurrencyCode;
}
