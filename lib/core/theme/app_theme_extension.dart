import 'package:flutter/material.dart';
import '../constants/constants.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.incomeColor,
    required this.incomeSurface,
    required this.expenseColor,
    required this.expenseSurface,
    required this.cardSurface,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.successColor,
    required this.warningColor,
  });

  final Color incomeColor;
  final Color incomeSurface;
  final Color expenseColor;
  final Color expenseSurface;
  final Color cardSurface;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color successColor;
  final Color warningColor;

  static const light = AppThemeExtension(
    incomeColor: AppColors.income,
    incomeSurface: AppColors.incomeLight,
    expenseColor: AppColors.expense,
    expenseSurface: AppColors.expenseLight,
    cardSurface: Color(0xFFFFFFFF),
    shimmerBase: Color(0xFFE0E0E0),
    shimmerHighlight: Color(0xFFF5F5F5),
    successColor: AppColors.success,
    warningColor: AppColors.warning,
  );

  static const dark = AppThemeExtension(
    incomeColor: Color(0xFF4CAF82),
    incomeSurface: Color(0xFF1B2E23),
    expenseColor: Color(0xFFEF6B62),
    expenseSurface: Color(0xFF2E1B1B),
    cardSurface: Color(0xFF2C2C2E),
    shimmerBase: Color(0xFF3A3A3C),
    shimmerHighlight: Color(0xFF4A4A4C),
    successColor: Color(0xFF4CAF82),
    warningColor: Color(0xFFFBBF24),
  );

  @override
  AppThemeExtension copyWith({
    Color? incomeColor,
    Color? incomeSurface,
    Color? expenseColor,
    Color? expenseSurface,
    Color? cardSurface,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? successColor,
    Color? warningColor,
  }) {
    return AppThemeExtension(
      incomeColor: incomeColor ?? this.incomeColor,
      incomeSurface: incomeSurface ?? this.incomeSurface,
      expenseColor: expenseColor ?? this.expenseColor,
      expenseSurface: expenseSurface ?? this.expenseSurface,
      cardSurface: cardSurface ?? this.cardSurface,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
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
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
    );
  }
}

extension AppThemeExtensionX on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}
