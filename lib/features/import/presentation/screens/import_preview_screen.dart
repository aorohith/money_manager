import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/core/constants/constants.dart';
import 'package:money_manager/core/router/app_router.dart';
import 'package:money_manager/core/widgets/widgets.dart';
import 'package:money_manager/features/import/domain/providers/import_providers.dart';
import 'package:money_manager/features/import/presentation/widgets/column_mapping_sheet.dart';
import 'package:money_manager/features/import/presentation/widgets/import_row_tile.dart';

class ImportPreviewScreen extends ConsumerWidget {
  const ImportPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importControllerProvider);
    final session = state.session;

    ref.listen(importControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        showAppSnackBar(
          context,
          message: next.errorMessage!,
          type: AppSnackBarType.error,
        );
      }
    });

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Import preview')),
        body: EmptyState(
          title: 'No import loaded',
          subtitle: 'Choose a file before reviewing rows.',
          icon: Icons.upload_file_rounded,
          actionLabel: 'Choose file',
          action: () => context.go(AppRoutes.importData),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import preview'),
        actions: [
          IconButton(
            tooltip: 'Column mapping',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (_) => const ColumnMappingSheet(),
            ),
            icon: const Icon(Icons.view_column_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Stat(label: 'Rows', value: '${state.previewRows.length}'),
                  _Stat(label: 'Selected', value: '${state.selectedCount}'),
                  _Stat(label: 'Duplicates', value: '${state.duplicateCount}'),
                  _Stat(label: 'Errors', value: '${state.errorCount}'),
                ],
              ),
            ),
          ),
          Expanded(
            child: state.previewRows.isEmpty
                ? const EmptyState(
                    title: 'No rows found',
                    subtitle: 'This file did not contain supported rows.',
                    icon: Icons.table_rows_rounded,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      0,
                      AppSpacing.screenPadding,
                      AppSpacing.screenPadding,
                    ),
                    itemCount: state.previewRows.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      return ImportRowTile(
                        previewRow: state.previewRows[index],
                        onChanged: (selected) => ref
                            .read(importControllerProvider.notifier)
                            .toggleRow(index, selected),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: AppButton(
                label: 'Import ${state.selectedCount} rows',
                loading: state.isLoading,
                expanded: true,
                onPressed: state.selectedCount == 0
                    ? null
                    : () async {
                        await ref
                            .read(importControllerProvider.notifier)
                            .commit();
                        if (context.mounted &&
                            ref.read(importControllerProvider).result != null) {
                          context.go(AppRoutes.importSummary);
                        }
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
