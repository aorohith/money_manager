import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/providers/transaction_providers.dart';

class TransactionFilterChips extends ConsumerWidget {
  const TransactionFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterProvider);

    void setType(bool? isIncome) {
      ref.read(transactionFilterProvider.notifier).update(
            (f) => f.copyWith(
              clearIsIncome: isIncome == null,
              isIncome: isIncome,
            ),
          );
    }

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding, 0, AppSpacing.screenPadding, AppSpacing.sm),
        children: [
          FilterChip(
            label: const Text('All'),
            selected: filter.isIncome == null,
            onSelected: (_) => setType(null),
          ),
          const SizedBox(width: AppSpacing.xs),
          FilterChip(
            avatar: const Icon(Icons.arrow_downward_rounded, size: 14),
            label: const Text('Income'),
            selected: filter.isIncome == true,
            selectedColor: AppColors.incomeLight,
            checkmarkColor: AppColors.income,
            onSelected: (_) =>
                setType(filter.isIncome == true ? null : true),
          ),
          const SizedBox(width: AppSpacing.xs),
          FilterChip(
            avatar: const Icon(Icons.arrow_upward_rounded, size: 14),
            label: const Text('Expense'),
            selected: filter.isIncome == false,
            selectedColor: AppColors.expenseLight,
            checkmarkColor: AppColors.expense,
            onSelected: (_) =>
                setType(filter.isIncome == false ? null : false),
          ),
        ],
      ),
    );
  }
}
