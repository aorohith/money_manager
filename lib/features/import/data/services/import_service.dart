import 'dart:io';

import 'package:isar/isar.dart';
import 'package:money_manager/features/import/data/models/import_preview_row.dart';
import 'package:money_manager/features/import/data/models/import_session.dart';
import 'package:money_manager/features/import/data/parsers/excel_parser.dart';
import 'package:money_manager/features/import/data/parsers/import_parser.dart';
import 'package:money_manager/features/import/data/parsers/pdf_parser.dart';
import 'package:money_manager/features/import/data/services/duplicate_detector.dart';
import 'package:money_manager/features/transactions/data/models/account_model.dart';
import 'package:money_manager/features/transactions/data/models/category_model.dart';
import 'package:money_manager/features/transactions/data/models/transaction_model.dart';

class ImportService {
  ImportService(this._isar, {DuplicateDetector? duplicateDetector})
    : _duplicateDetector = duplicateDetector ?? DuplicateDetector();

  final Isar _isar;
  final DuplicateDetector _duplicateDetector;

  final Map<String, ImportParser> _parsers = const {
    'xlsx': ExcelImportParser(),
    'pdf': PdfImportParser(),
  };

  Future<ImportSession> parse(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    final parser = _parsers[extension];
    if (parser == null) {
      throw UnsupportedError('Unsupported import format: .$extension');
    }
    return parser.parse(file);
  }

  Future<List<ImportPreviewRow>> buildPreview(ImportSession session) async {
    final accounts = await _isar.accountModels.where().findAll();
    final categories = await _isar.categoryModels.where().findAll();
    final transactions = await _isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
    final existing = _duplicateDetector.existingFingerprints(
      transactions: transactions,
      accounts: accounts,
      categories: categories,
    );

    return session.rows
        .map((row) {
          if (row.hasErrors) {
            return ImportPreviewRow(
              row: row,
              status: ImportPreviewStatus.error,
              selected: false,
            );
          }
          final duplicate = _duplicateDetector.isDuplicate(row, existing);
          return ImportPreviewRow(
            row: row,
            status: duplicate
                ? ImportPreviewStatus.duplicate
                : ImportPreviewStatus.ready,
            selected: !duplicate,
            duplicateReason: duplicate
                ? 'Possible duplicate transaction'
                : null,
          );
        })
        .toList(growable: false);
  }
}
