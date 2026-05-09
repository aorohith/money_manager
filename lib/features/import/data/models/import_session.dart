import 'package:money_manager/features/import/data/models/import_diagnostic.dart';
import 'package:money_manager/features/import/data/models/import_row.dart';

enum ImportFormat { excel, pdf }

enum ImportSessionStatus { parsed, failed }

class ImportSession {
  const ImportSession({
    required this.batchId,
    required this.filePath,
    required this.format,
    required this.rows,
    this.diagnostics = const [],
    this.status = ImportSessionStatus.parsed,
  });

  final String batchId;
  final String filePath;
  final ImportFormat format;
  final List<ImportRow> rows;
  final List<ImportDiagnostic> diagnostics;
  final ImportSessionStatus status;

  int get totalRows => rows.length;
  int get errorCount =>
      diagnostics.where((diagnostic) => diagnostic.isError).length +
      rows.where((row) => row.hasErrors).length;
}

class ImportCommitResult {
  const ImportCommitResult({
    required this.batchId,
    required this.insertedTransactions,
    required this.createdAccounts,
    required this.createdCategories,
    required this.skippedRows,
  });

  final String batchId;
  final int insertedTransactions;
  final int createdAccounts;
  final int createdCategories;
  final int skippedRows;
}
