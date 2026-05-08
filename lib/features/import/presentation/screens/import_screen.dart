import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/core/constants/constants.dart';
import 'package:money_manager/core/router/app_router.dart';
import 'package:money_manager/core/widgets/widgets.dart';
import 'package:money_manager/features/import/domain/providers/import_providers.dart';

class ImportScreen extends ConsumerWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importControllerProvider);

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

    return Scaffold(
      appBar: AppBar(title: const Text('Import data')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.upload_file_rounded,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Import transactions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Choose an Excel or PDF export. Excel imports are fully supported; PDF imports are parsed best-effort.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Choose file',
                    icon: const Icon(Icons.folder_open_rounded),
                    loading: state.isLoading,
                    expanded: true,
                    onPressed: () => _pickFile(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: const ListTile(
                leading: Icon(Icons.verified_rounded),
                title: Text('Safe preview before import'),
                subtitle: Text(
                  'Rows are checked for errors and duplicates before anything is saved.',
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'pdf'],
    );
    final path = result?.files.single.path;
    if (path == null) return;

    await ref.read(importControllerProvider.notifier).parse(File(path));
    final state = ref.read(importControllerProvider);
    if (context.mounted && state.errorMessage == null) {
      context.push(AppRoutes.importPreview);
    }
  }
}
