import 'dart:io';

import 'package:money_manager/features/import/data/models/column_mapping.dart';
import 'package:money_manager/features/import/data/models/import_session.dart';

abstract class ImportParser {
  String get formatId;

  Future<ImportSession> parse(File file, {ColumnMapping? overrides});
}
