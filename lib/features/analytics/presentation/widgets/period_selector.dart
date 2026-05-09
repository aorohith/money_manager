import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/providers/analytics_providers.dart';

class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(analyticsPeriodProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: AnalyticsPeriod.values.map((p) {
          final isSelected = p == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(analyticsPeriodProvider.notifier).state = p;
              },
              child: AnimatedContainer(
                duration: AppDurations.fast,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? isDark ? AppColors.brandLight : AppColors.brand
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                alignment: Alignment.center,
                child: Text(
                  _label(p),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(AnalyticsPeriod p) => switch (p) {
        AnalyticsPeriod.day => 'Day',
        AnalyticsPeriod.week => 'Week',
        AnalyticsPeriod.month => 'Month',
        AnalyticsPeriod.year => 'Year',
      };
}
