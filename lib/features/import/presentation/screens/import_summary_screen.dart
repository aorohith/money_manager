import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/core/constants/constants.dart';
import 'package:money_manager/core/router/app_router.dart';
import 'package:money_manager/core/widgets/widgets.dart';
import 'package:money_manager/features/import/domain/providers/import_providers.dart';

class ImportSummaryScreen extends ConsumerWidget {
  const ImportSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(importControllerProvider).result;

    return Scaffold(
      appBar: AppBar(title: const Text('Import summary')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: result == null
            ? EmptyState(
                title: 'No import result',
                subtitle: 'Complete an import to see the summary.',
                icon: Icons.receipt_long_rounded,
                actionLabel: 'Import data',
                action: () => context.go(AppRoutes.importData),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 56,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Import complete',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Batch: ${result.batchId}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      children: [
                        _SummaryTile(
                          label: 'Transactions inserted',
                          value: '${result.insertedTransactions}',
                        ),
                        _SummaryTile(
                          label: 'Accounts created',
                          value: '${result.createdAccounts}',
                        ),
                        _SummaryTile(
                          label: 'Categories created',
                          value: '${result.createdCategories}',
                        ),
                        _SummaryTile(
                          label: 'Rows skipped',
                          value: '${result.skippedRows}',
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Done',
                    expanded: true,
                    onPressed: () {
                      ref.read(importControllerProvider.notifier).reset();
                      context.go(AppRoutes.settings);
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      contentPadding: EdgeInsets.zero,
    );
  }
}
