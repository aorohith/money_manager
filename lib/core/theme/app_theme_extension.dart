import 'package:flutter/material.dart';
import '../constants/constants.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.incomeColor,
    required this.incomeSurface,
    required this.expenseColor,
    required this.expenseSurface,
    required this.cardSurface,
    required this.cardBorder,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.successColor,
    required this.warningColor,
    required this.gradientPrimary,
  });

  final Color incomeColor;
  final Color incomeSurface;
  final Color expenseColor;
  final Color expenseSurface;
  final Color cardSurface;
  final Color cardBorder;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color successColor;
  final Color warningColor;
  final LinearGradient gradientPrimary;

  static final light = AppThemeExtension(
    incomeColor: AppColors.income,
    incomeSurface: AppColors.incomeLight,
    expenseColor: AppColors.expense,
    expenseSurface: AppColors.expenseLight,
    cardSurface: AppColors.surface,
    cardBorder: AppColors.outline,
    shimmerBase: const Color(0xFFE2E8F0),
    shimmerHighlight: const Color(0xFFF8FAFC),
    successColor: AppColors.success,
    warningColor: AppColors.warning,
    gradientPrimary: const LinearGradient(
      colors: [AppColors.gradientStart, AppColors.gradientEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static final dark = AppThemeExtension(
    incomeColor: AppColors.incomeChip,
    incomeSurface: AppColors.incomeDark,
    expenseColor: AppColors.expenseChip,
    expenseSurface: AppColors.expenseDark,
    cardSurface: AppColors.surfaceDark,
    cardBorder: AppColors.outlineDark,
    shimmerBase: const Color(0xFF1A2540),
    shimmerHighlight: const Color(0xFF243058),
    successColor: AppColors.incomeChip,
    warningColor: const Color(0xFFFBBF24),
    gradientPrimary: const LinearGradient(
      colors: [Color(0xFF0052FF), Color(0xFF1A3A7A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  @override
  AppThemeExtension copyWith({
    Color? incomeColor,
    Color? incomeSurface,
    Color? expenseColor,
    Color? expenseSurface,
    Color? cardSurface,
    Color? cardBorder,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? successColor,
    Color? warningColor,
    LinearGradient? gradientPrimary,
  }) {
    return AppThemeExtension(
      incomeColor: incomeColor ?? this.incomeColor,
      incomeSurface: incomeSurface ?? this.incomeSurface,
      expenseColor: expenseColor ?? this.expenseColor,
      expenseSurface: expenseSurface ?? this.expenseSurface,
      cardSurface: cardSurface ?? this.cardSurface,
      cardBorder: cardBorder ?? this.cardBorder,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      gradientPrimary: gradientPrimary ?? this.gradientPrimary,
    );
  }

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other == null) return this;
    return AppThemeExtension(
      incomeColor: Color.lerp(incomeColor, other.incomeColor, t)!,
      incomeSurface: Color.lerp(incomeSurface, other.incomeSurface, t)!,
      expenseColor: Color.lerp(expenseColor, other.expenseColor, t)!,
      expenseSurface: Color.lerp(expenseSurface, other.expenseSurface, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight:
          Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      gradientPrimary: LinearGradient.lerp(
          gradientPrimary, other.gradientPrimary, t)!,
    );
  }
}

extension AppThemeExtensionX on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}
