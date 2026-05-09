import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/import/data/parsers/pdf_parser.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  group('PdfImportParser', () {
    test('returns a parsed session with a warning scaffold', () async {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (_) => pw.Text('Date Amount Comment\n2026-05-08 100 Food'),
        ),
      );
      final file = File('${Directory.systemTemp.path}/import_parser_test.pdf');
      await file.writeAsBytes(await pdf.save(), flush: true);

      final session = await const PdfImportParser().parse(file);

      expect(session.rows, isEmpty);
      expect(session.diagnostics, isNotEmpty);
      expect(session.diagnostics.first.message, contains('PDF import'));
    });
  });
}
