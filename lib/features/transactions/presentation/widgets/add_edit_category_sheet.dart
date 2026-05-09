import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/category_model.dart';
import '../../domain/providers/transaction_providers.dart';

// Curated icon list for categories
const _categoryIcons = [
  Icons.restaurant_rounded,
  Icons.fastfood_rounded,
  Icons.local_cafe_rounded,
  Icons.lunch_dining_rounded,
  Icons.shopping_bag_rounded,
  Icons.shopping_cart_rounded,
  Icons.local_mall_rounded,
  Icons.checkroom_rounded,
  Icons.directions_car_rounded,
  Icons.train_rounded,
  Icons.flight_rounded,
  Icons.pedal_bike_rounded,
  Icons.movie_rounded,
  Icons.music_note_rounded,
  Icons.sports_esports_rounded,
  Icons.sports_basketball_rounded,
  Icons.local_hospital_rounded,
  Icons.fitness_center_rounded,
  Icons.spa_rounded,
  Icons.medication_rounded,
  Icons.school_rounded,
  Icons.auto_stories_rounded,
  Icons.science_rounded,
  Icons.home_work_rounded,
  Icons.bolt_rounded,
  Icons.water_drop_rounded,
  Icons.phone_rounded,
  Icons.wifi_rounded,
  Icons.work_rounded,
  Icons.laptop_rounded,
  Icons.business_center_rounded,
  Icons.trending_up_rounded,
  Icons.credit_card_rounded,
  Icons.savings_rounded,
  Icons.account_balance_rounded,
  Icons.card_giftcard_rounded,
  Icons.pets_rounded,
  Icons.subscriptions_rounded,
  Icons.face_retouching_natural_rounded,
  Icons.real_estate_agent_rounded,
  Icons.category_rounded,
];

Future<void> showAddEditCategorySheet(
  BuildContext context, {
  CategoryModel? existing,
  bool? initialIsIncome,
}) {
  return showAppBottomSheet(
    context: context,
    title: existing == null ? 'Add Category' : 'Edit Category',
    maxHeightFraction: 0.92,
    child: _AddEditCategoryForm(
      existing: existing,
      initialIsIncome: initialIsIncome,
    ),
  );
}

bool isDuplicateCategoryName({
  required String candidate,
  required List<CategoryModel> categories,
  required bool isIncome,
  int? excludeCategoryId,
}) {
  final normalizedCandidate = candidate.trim().toLowerCase();
  if (normalizedCandidate.isEmpty) {
    return false;
  }

  return categories.any((category) {
    if (category.isIncome != isIncome) {
      return false;
    }
    if (excludeCategoryId != null && category.id == excludeCategoryId) {
      return false;
    }
    return category.name.trim().toLowerCase() == normalizedCandidate;
  });
}

class _AddEditCategoryForm extends ConsumerStatefulWidget {
  const _AddEditCategoryForm({this.existing, this.initialIsIncome});
  final CategoryModel? existing;
  final bool? initialIsIncome;

  @override
  ConsumerState<_AddEditCategoryForm> createState() =>
      _AddEditCategoryFormState();
}

class _AddEditCategoryFormState extends ConsumerState<_AddEditCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  late bool _isIncome;
  late int _selectedColorValue;
  late int _selectedIconCodePoint;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _isIncome = e?.isIncome ?? widget.initialIsIncome ?? false;
    _selectedColorValue =
        e?.colorValue ?? AppColors.categoryPalette.first.toARGB32();
    _selectedIconCodePoint =
        e?.iconCodePoint ?? Icons.category_rounded.codePoint;
    if (e != null) _nameCtrl.text = e.name;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(categoryRepositoryProvider);
      if (widget.existing == null) {
        final cat = CategoryModel(
          name: _nameCtrl.text.trim(),
          iconCodePoint: _selectedIconCodePoint,
          colorValue: _selectedColorValue,
          isIncome: _isIncome,
          isDefault: false,
        );
        await repo.add(cat);
      } else {
        widget.existing!
          ..name = _nameCtrl.text.trim()
          ..iconCodePoint = _selectedIconCodePoint
          ..colorValue = _selectedColorValue
          ..isIncome = _isIncome;
        await repo.update(widget.existing!);
      }
      if (mounted) {
        Navigator.of(context).pop();
        showAppSnackBar(
          context,
          message: widget.existing == null
              ? 'Category added'
              : 'Category updated',
          type: AppSnackBarType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        showAppSnackBar(
          context,
          message: 'Something went wrong',
          type: AppSnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Color(_selectedColorValue);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final existingNames =
        categories
            .where(
              (category) =>
                  category.isIncome == _isIncome &&
                  category.id != widget.existing?.id,
            )
            .map((category) => category.name)
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type toggle
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Expense'),
                icon: Icon(Icons.arrow_upward_rounded),
              ),
              ButtonSegment(
                value: true,
                label: Text('Income'),
                icon: Icon(Icons.arrow_downward_rounded),
              ),
            ],
            selected: {_isIncome},
            onSelectionChanged: widget.existing != null
                ? null
                : (s) => setState(() => _isIncome = s.first),
          ),

          const SizedBox(height: AppSpacing.md),

          // Name field
          AppTextField(
            controller: _nameCtrl,
            label: 'Category name',
            hint: 'e.g. Coffee, Groceries…',
            prefixIcon: const Icon(Icons.label_rounded),
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Name is required';
              if (v.trim().length > 30) return 'Name too long';
              if (isDuplicateCategoryName(
                candidate: v,
                categories: categories,
                isIncome: _isIncome,
                excludeCategoryId: widget.existing?.id,
              )) {
                return 'Category already exists';
              }
              return null;
            },
          ),

          if (existingNames.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Existing ${_isIncome ? 'income' : 'expense'} categories:',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: existingNames
                  .map(
                    (name) => Chip(
                      label: Text(name, overflow: TextOverflow.ellipsis),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // Color picker
          _SectionLabel('Color'),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: AppColors.categoryPalette.map((color) {
              final selected = color.toARGB32() == _selectedColorValue;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedColorValue = color.toARGB32()),
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 2.5,
                          )
                        : null,
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: color.withAlpha(100),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.md),

          // Icon picker
          _SectionLabel('Icon'),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 160,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: AppSpacing.xs,
                crossAxisSpacing: AppSpacing.xs,
              ),
              itemCount: _categoryIcons.length,
              itemBuilder: (_, i) {
                final icon = _categoryIcons[i];
                final selected = icon.codePoint == _selectedIconCodePoint;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedIconCodePoint = icon.codePoint),
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    decoration: BoxDecoration(
                      color: selected
                          ? selectedColor.withAlpha(40)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: selected
                          ? Border.all(color: selectedColor, width: 1.5)
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: selected
                          ? selectedColor
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          AppButton(
            expanded: true,
            label: widget.existing == null ? 'Add Category' : 'Save',
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.titleSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}
