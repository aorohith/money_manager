import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/constants/constants.dart';
import 'package:money_manager/core/widgets/widgets.dart';
import 'package:money_manager/features/import/data/models/import_preview_row.dart';
import 'package:money_manager/features/import/data/models/import_row.dart';
import 'package:money_manager/features/import/presentation/widgets/duplicate_badge.dart';

class ImportRowTile extends StatelessWidget {
  ImportRowTile({super.key, required this.previewRow, required this.onChanged});

  final ImportPreviewRow previewRow;
  final ValueChanged<bool> onChanged;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final row = previewRow.row;
    final title = switch (row) {
      ExpenseImportRow() => '${row.accountName} - ${row.categoryName}',
      IncomeImportRow() => '${row.accountName} - ${row.categoryName}',
      TransferImportRow() =>
        '${row.outgoingAccountName} -> ${row.incomingAccountName}',
    };
    final amount = '${row.currencyCode} ${row.amount.toStringAsFixed(2)}';
    final type = switch (row) {
      ExpenseImportRow() => 'Expense',
      IncomeImportRow() => 'Income',
      TransferImportRow() => 'Transfer',
    };

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: CheckboxListTile(
        value: previewRow.selected,
        onChanged: previewRow.status == ImportPreviewStatus.error
            ? null
            : (value) => onChanged(value ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$type - ${_dateFormat.format(row.date)} - $amount'),
            if (row.note != null && row.note!.isNotEmpty)
              Text(row.note!, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (row.tags.isNotEmpty)
              Text(
                row.tags.map((tag) => '#$tag').join(' '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (row.diagnostics.isNotEmpty)
              Text(
                row.diagnostics
                    .map((diagnostic) => diagnostic.message)
                    .join(' '),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
        secondary: _BadgeForStatus(previewRow: previewRow),
      ),
    );
  }
}

class _BadgeForStatus extends StatelessWidget {
  const _BadgeForStatus({required this.previewRow});

  final ImportPreviewRow previewRow;

  @override
  Widget build(BuildContext context) {
    return switch (previewRow.status) {
      ImportPreviewStatus.ready => DuplicateBadge(
        label: 'New',
        color: Theme.of(context).colorScheme.primary,
      ),
      ImportPreviewStatus.duplicate => DuplicateBadge(
        label: 'Duplicate',
        color: Colors.orange.shade700,
      ),
      ImportPreviewStatus.error => DuplicateBadge(
        label: 'Error',
        color: Theme.of(context).colorScheme.error,
      ),
    };
  }
}
