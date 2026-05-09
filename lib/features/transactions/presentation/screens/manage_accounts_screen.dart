import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/account_model.dart';
import '../../domain/providers/transaction_providers.dart';
import '../widgets/add_edit_account_sheet.dart';

class ManageAccountsScreen extends ConsumerWidget {
  const ManageAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final currencySymbol =
        ref.watch(currencySymbolProvider).valueOrNull ?? '\$';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Accounts'),
            floating: true,
            snap: true,
          ),
          accountsAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                    vertical: AppSpacing.xs,
                  ),
                  child: ShimmerLoader(
                    child: ShimmerBox(width: double.infinity, height: 72),
                  ),
                ),
                childCount: 3,
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: EmptyState(
                icon: Icons.error_rounded,
                title: 'Failed to load accounts',
                subtitle: e.toString(),
              ),
            ),
            data: (accounts) {
              if (accounts.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'No accounts yet',
                    subtitle: 'Tap + to add your first account.',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                  AppSpacing.screenPadding,
                  AppSpacing.xxl + AppSpacing.fabSize,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _AccountTile(
                      account: accounts[i],
                      currencySymbol: currencySymbol,
                    ),
                    childCount: accounts.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditAccountSheet(context),
        tooltip: 'Add Account',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _AccountTile extends ConsumerWidget {
  const _AccountTile({required this.account, required this.currencySymbol});

  final AccountModel account;
  final String currencySymbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(accountBalanceProvider(account));

    return Dismissible(
      key: ValueKey(account.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, account),
      onDismissed: (_) async {
        await ref.read(accountRepositoryProvider).delete(account.id);
        if (context.mounted) {
          showAppSnackBar(
            context,
            message: '${account.name} deleted',
            type: AppSnackBarType.success,
          );
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: AppCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: account.color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(account.icon, color: account.color, size: 22),
          ),
          title: Text(
            account.name,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: balanceAsync.when(
            data: (balance) => Text(
              AppFormatters.currency(balance.abs(), currencySymbol) +
                  (balance < 0 ? ' (debt)' : ''),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: balance < 0 ? AppColors.expense : AppColors.income,
                fontWeight: FontWeight.w600,
              ),
            ),
            loading: () => const SizedBox(
              height: 14,
              width: 80,
              child: LinearProgressIndicator(),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (account.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    'Default',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
          contentPadding: EdgeInsets.zero,
          onTap: () =>
              context.push('${AppRoutes.manageAccounts}/${account.id}'),
          onLongPress: () =>
              showAddEditAccountSheet(context, existing: account),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, AccountModel account) {
    if (account.isDefault) {
      showAppSnackBar(
        context,
        message: 'Default accounts cannot be deleted',
        type: AppSnackBarType.error,
      );
      return Future.value(false);
    }
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account?'),
        content: Text(
          'Delete "${account.name}"? Transactions will keep their existing account reference.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
