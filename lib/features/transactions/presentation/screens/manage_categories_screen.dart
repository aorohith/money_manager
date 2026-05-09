import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/category_model.dart';
import '../../domain/providers/transaction_providers.dart';
import '../widgets/add_edit_category_sheet.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Categories'),
            floating: true,
            snap: true,
          ),
          categoriesAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                      vertical: AppSpacing.xs),
                  child: ShimmerLoader(
                    child: ShimmerBox(width: double.infinity, height: 64),
                  ),
                ),
                childCount: 6,
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: EmptyState(
                icon: Icons.error_rounded,
                title: 'Failed to load categories',
                subtitle: e.toString(),
              ),
            ),
            data: (categories) {
              final expense =
                  categories.where((c) => !c.isIncome).toList();
              final income =
                  categories.where((c) => c.isIncome).toList();

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                  AppSpacing.screenPadding,
                  AppSpacing.xxl + AppSpacing.fabSize,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _GroupHeader('Expense', expense.length),
                    const SizedBox(height: AppSpacing.xs),
                    ...expense.map((c) => _CategoryTile(category: c)),
                    const SizedBox(height: AppSpacing.md),
                    _GroupHeader('Income', income.length),
                    const SizedBox(height: AppSpacing.xs),
                    ...income.map((c) => _CategoryTile(category: c)),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditCategorySheet(context),
        tooltip: 'Add Category',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.label, this.count);
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
            left: AppSpacing.xs, bottom: AppSpacing.xs),
        child: Text(
          '$label ($count)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.category});
  final CategoryModel category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(category.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, category),
      onDismissed: (_) async {
        await ref
            .read(categoryRepositoryProvider)
            .delete(category.id);
        if (context.mounted) {
          showAppSnackBar(context,
              message: '${category.name} deleted',
              type: AppSnackBarType.success);
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category.color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, color: category.color, size: 20),
          ),
          title: Text(category.name,
              style: Theme.of(context).textTheme.titleSmall),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (category.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text('Default',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          )),
                ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
          contentPadding: EdgeInsets.zero,
          onTap: () => showAddEditCategorySheet(context, existing: category),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(
      BuildContext context, CategoryModel category) {
    if (category.isDefault) {
      showAppSnackBar(context,
          message: 'Default categories cannot be deleted',
          type: AppSnackBarType.error);
      return Future.value(false);
    }
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
            'Delete "${category.name}"? Transactions using it will keep their existing category ID.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
