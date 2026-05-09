import 'dart:io';

import 'package:money_manager/features/import/data/models/column_mapping.dart';
import 'package:money_manager/features/import/data/models/import_diagnostic.dart';
import 'package:money_manager/features/import/data/models/import_session.dart';
import 'package:money_manager/features/import/data/parsers/import_parser.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfImportParser implements ImportParser {
  const PdfImportParser();

  @override
  String get formatId => 'pdf';

  @override
  Future<ImportSession> parse(File file, {ColumnMapping? overrides}) async {
    final bytes = await file.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(document).extractText();
    document.dispose();

    return ImportSession(
      batchId: 'imp_${DateTime.now().microsecondsSinceEpoch}',
      filePath: file.path,
      format: ImportFormat.pdf,
      rows: const [],
      diagnostics: [
        ImportDiagnostic(
          rowNumber: 0,
          message: text.trim().isEmpty
              ? 'PDF text extraction found no readable table content.'
              : 'PDF import preview is not yet enabled. Export Excel for reliable import.',
          severity: ImportDiagnosticSeverity.warning,
        ),
      ],
    );
  }
}
