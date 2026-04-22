import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/models/analytics_data.dart';

// ── Category bar list ─────────────────────────────────────────────────────────
/// Renders one row per CategorySummary with an animated percentage bar.
/// Tap → calls [onTap] for drill-down navigation.

class CategoryBarList extends StatelessWidget {
  const CategoryBarList({
    super.key,
    required this.categories,
    required this.currencySymbol,
    required this.selectedIndex,
    required this.onTap,
    this.onHoverIndex,
  });

  final List<CategorySummary> categories;
  final String currencySymbol;
  final int? selectedIndex;
  final ValueChanged<int> onTap;
  final ValueChanged<int?>? onHoverIndex;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      children: List.generate(categories.length, (i) {
        final cat = categories[i];
        final isSelected = selectedIndex == i;
        return _CategoryRow(
          category: cat,
          currencySymbol: currencySymbol,
          isSelected: isSelected,
          isOtherSelected: selectedIndex != null && !isSelected,
          onTap: () {
            HapticFeedback.lightImpact();
            onTap(i);
          },
        );
      }),
    );
  }
}

class _CategoryRow extends StatefulWidget {
  const _CategoryRow({
    required this.category,
    required this.currencySymbol,
    required this.isSelected,
    required this.isOtherSelected,
    required this.onTap,
  });

  final CategorySummary category;
  final String currencySymbol;
  final bool isSelected;
  final bool isOtherSelected;
  final VoidCallback onTap;

  @override
  State<_CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<_CategoryRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _barController;
  late Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: AppDurations.emphasis,
    );
    _barAnim = CurvedAnimation(
      parent: _barController,
      curve: Curves.easeOutCubic,
    );
    _barController.forward();
  }

  @override
  void didUpdateWidget(_CategoryRow old) {
    super.didUpdateWidget(old);
    if (old.category.percentage != widget.category.percentage) {
      _barController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = widget.category;

    return Semantics(
      button: true,
      label: '${cat.name}: ${widget.currencySymbol}${cat.totalAmount.toStringAsFixed(2)}, ${cat.percentage.toStringAsFixed(1)}%',
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          duration: AppDurations.fast,
          opacity: widget.isOtherSelected ? 0.4 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: 10,
            ),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cat.color.withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(cat.icon, size: 17, color: cat.color),
                ),
                const SizedBox(width: 12),
                // Name + bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${widget.currencySymbol}${_fmt(cat.totalAmount)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Percentage bar
                      AnimatedBuilder(
                        animation: _barAnim,
                        builder: (_, __) {
                          return Stack(
                            children: [
                              // Background track
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.outlineDark
                                      : AppColors.outline,
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusFull),
                                ),
                              ),
                              // Fill
                              FractionallySizedBox(
                                widthFactor:
                                    (cat.percentage / 100) * _barAnim.value,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: cat.color,
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusFull),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Percentage + chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${cat.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color:
                          isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(2);
  }
}
