import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.category,
    required this.currencySymbol,
    this.onTap,
    this.onDismissed,
  });

  final TransactionModel transaction;
  final CategoryModel? category;
  final String currencySymbol;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final amountColor =
        transaction.isIncome ? ext.incomeColor : ext.expenseColor;
    final sign = transaction.isIncome ? '+' : '-';
    final cat = category;

    final tile = ListTile(
      onTap: onTap,
      leading: Semantics(
        label: cat?.name ?? 'Unknown category',
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (cat?.color ?? Colors.grey).withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(
            cat?.icon ?? Icons.category_rounded,
            color: cat?.color ?? Colors.grey,
            size: 22,
          ),
        ),
      ),
      title: Text(
        cat?.name ?? 'Unknown',
        style: Theme.of(context).textTheme.titleSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: transaction.note != null && transaction.note!.isNotEmpty
          ? Text(
              transaction.note!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          : Text(
              AppFormatters.shortDate(transaction.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
      trailing: Semantics(
        label:
            '$sign${AppFormatters.currency(transaction.amount, currencySymbol)}',
        child: Text(
          '$sign${AppFormatters.currency(transaction.amount, currencySymbol)}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );

    if (onDismissed == null) return tile;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        color: AppColors.expense,
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete transaction?'),
            content:
                const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.expense),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDismissed?.call(),
      child: tile,
    );
  }
}
