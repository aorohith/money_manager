import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/providers/transaction_providers.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/transaction_filter_chips.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState
    extends ConsumerState<TransactionsScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref
          .read(transactionFilterProvider.notifier)
          .update((f) => f.copyWith(searchQuery: q));
    });
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionListProvider);
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? [];
    final currencySymbol =
        ref.watch(currencySymbolProvider).valueOrNull ?? '\$';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    0,
                    AppSpacing.screenPadding,
                    AppSpacing.xs),
                child: AppTextField(
                  controller: _searchCtrl,
                  hint: 'Search transactions…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  onChanged: _onSearch,
                  textInputAction: TextInputAction.search,
                  semanticLabel: 'Search transactions',
                ),
              ),
              const TransactionFilterChips(),
            ],
          ),
        ),
      ),
      body: txAsync.when(
        loading: () => ListView.builder(
          itemCount: 6,
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.xs),
            child: ShimmerLoader(
              child: ShimmerBox(width: double.infinity, height: 64),
            ),
          ),
        ),
        error: (e, _) => EmptyState(
          title: 'Something went wrong',
          subtitle: e.toString(),
          icon: Icons.error_rounded,
        ),
        data: (txs) {
          if (txs.isEmpty) {
            return EmptyState(
              title: 'No transactions yet',
              subtitle: 'Tap + to add your first transaction.',
              icon: Icons.receipt_long_rounded,
              actionLabel: 'Add Transaction',
              action: () => showAddTransactionSheet(context),
            );
          }

          final grouped = _groupByDate(txs);
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(transactionListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: AppSpacing.xxl + AppSpacing.fabSize),
              itemCount: grouped.length,
              itemBuilder: (_, i) {
                final entry = grouped[i];
                if (entry is DateTime) {
                  return _DateHeader(date: entry);
                }
                final tx = entry as TransactionModel;
                final cat = categories
                    .where((c) => c.id == tx.categoryId)
                    .firstOrNull;
                return TransactionTile(
                  transaction: tx,
                  category: cat,
                  currencySymbol: currencySymbol,
                  onTap: () =>
                      showAddTransactionSheet(context, existing: tx),
                  onDismissed: () => ref
                      .read(deleteTransactionUseCaseProvider)(tx.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTransactionSheet(context),
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  /// Returns a flat list alternating [DateTime] headers and [TransactionModel] items.
  List<Object> _groupByDate(List<TransactionModel> txs) {
    final result = <Object>[];
    DateTime? lastDate;
    for (final tx in txs) {
      final d =
          DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (lastDate == null || d != lastDate) {
        result.add(d);
        lastDate = d;
      }
      result.add(tx);
    }
    return result;
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.md,
          AppSpacing.screenPadding,
          AppSpacing.xs),
      child: Text(
        AppFormatters.groupDate(date),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color:
                  Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
