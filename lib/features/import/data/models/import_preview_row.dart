import 'package:money_manager/features/import/data/models/import_row.dart';

enum ImportPreviewStatus { ready, duplicate, error }

class ImportPreviewRow {
  const ImportPreviewRow({
    required this.row,
    required this.status,
    required this.selected,
    this.duplicateReason,
  });

  final ImportRow row;
  final ImportPreviewStatus status;
  final bool selected;
  final String? duplicateReason;

  ImportPreviewRow copyWith({
    ImportPreviewStatus? status,
    bool? selected,
    String? duplicateReason,
  }) {
    return ImportPreviewRow(
      row: row,
      status: status ?? this.status,
      selected: selected ?? this.selected,
      duplicateReason: duplicateReason ?? this.duplicateReason,
    );
  }

  bool get canCommit => selected && status != ImportPreviewStatus.error;
}
