import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/account_model.dart';
import '../../domain/providers/transaction_providers.dart';
import '../widgets/transaction_tile.dart';

class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final int accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final currencySymbol =
        ref.watch(currencySymbolProvider).valueOrNull ?? '\$';

    return Scaffold(
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load account: $e')),
        data: (accounts) {
          final account = accounts.where((a) => a.id == accountId).firstOrNull;
          if (account == null) {
            return const Center(child: Text('Account not found'));
          }
          final snapshotAsync = ref.watch(
            accountBalanceSnapshotProvider(account),
          );
          final txsAsync = ref.watch(accountTransactionsProvider(account.id));
          final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(account.name),
                actions: [
                  IconButton(
                    tooltip: 'Edit Balance',
                    onPressed: () => _showEditBalanceDialog(
                      context: context,
                      ref: ref,
                      account: account,
                    ),
                    icon: const Icon(Icons.edit_note_rounded),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _AccountHeaderCard(
                      account: account,
                      snapshotAsync: snapshotAsync,
                      currencySymbol: currencySymbol,
                      onResolve: (balance) => _showResolveDialog(
                        context: context,
                        ref: ref,
                        account: account,
                        targetBalance: balance,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Transaction History',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    txsAsync.when(
                      loading: () =>
                          const ShimmerBox(width: double.infinity, height: 72),
                      error: (e, _) => Text('Failed to load transactions: $e'),
                      data: (txs) {
                        if (txs.isEmpty) {
                          return const EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'No transactions yet',
                            subtitle:
                                'Transactions for this account will appear here.',
                          );
                        }
                        return Column(
                          children: txs.map((tx) {
                            final category = categories
                                .where((c) => c.id == tx.categoryId)
                                .firstOrNull;
                            return AppCard(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.xs,
                              ),
                              child: TransactionTile(
                                transaction: tx,
                                category: category,
                                currencySymbol: currencySymbol,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditBalanceDialog({
    required BuildContext context,
    required WidgetRef ref,
    required AccountModel account,
  }) async {
    final current = await ref.read(
      accountBalanceFutureProvider(account).future,
    );
    if (!context.mounted) return;
    final ctrl = TextEditingController(
      text: (account.actualBalance ?? current).toStringAsFixed(2),
    );
    final noteCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Balance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Actual current balance',
                prefixIcon: Icon(Icons.account_balance_wallet_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final target = double.tryParse(ctrl.text.replaceAll(',', ''));
    if (target == null) {
      showAppSnackBar(
        context,
        message: 'Invalid balance value',
        type: AppSnackBarType.error,
      );
      return;
    }
    await ref
        .read(accountReconciliationActionsProvider)
        .setActualBalance(
          account: account,
          targetBalance: target,
          note: noteCtrl.text,
        );
    if (context.mounted) {
      showAppSnackBar(
        context,
        message: 'Balance updated',
        type: AppSnackBarType.success,
      );
    }
  }

  Future<void> _showResolveDialog({
    required BuildContext context,
    required WidgetRef ref,
    required AccountModel account,
    required double targetBalance,
  }) async {
    final noteCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Resolve Discrepancy'),
        content: TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(
            labelText: 'Note (optional)',
            prefixIcon: Icon(Icons.notes_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await ref
        .read(accountReconciliationActionsProvider)
        .setActualBalance(
          account: account,
          targetBalance: targetBalance,
          note: noteCtrl.text,
        );
    if (context.mounted) {
      HapticFeedback.mediumImpact();
      showAppSnackBar(
        context,
        message: 'Discrepancy resolved',
        type: AppSnackBarType.success,
      );
    }
  }
}

class _AccountHeaderCard extends StatelessWidget {
  const _AccountHeaderCard({
    required this.account,
    required this.snapshotAsync,
    required this.currencySymbol,
    required this.onResolve,
  });

  final AccountModel account;
  final AsyncValue<AccountBalanceSnapshot> snapshotAsync;
  final String currencySymbol;
  final ValueChanged<double> onResolve;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: snapshotAsync.when(
        loading: () => const ShimmerBox(width: double.infinity, height: 120),
        error: (e, _) => Text('Failed to load balance: $e'),
        data: (snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(account.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                account.isDefault ? 'Default account' : 'Custom account',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              _BalanceRow(
                label: 'Calculated balance',
                value: AppFormatters.currency(
                  snapshot.calculatedBalance,
                  currencySymbol,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _BalanceRow(
                label: 'Actual balance',
                value: AppFormatters.currency(
                  snapshot.actualBalance,
                  currencySymbol,
                ),
              ),
              if (snapshot.hasDiscrepancy) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: AppColors.warning.withAlpha(90)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 18),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Discrepancy: ${AppFormatters.currency(snapshot.discrepancy.abs(), currencySymbol)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onResolve(snapshot.actualBalance),
                        child: const Text('Resolve'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
