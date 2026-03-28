import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const Color brand = Color(0xFF00BFA5);
  static const Color brandLight = Color(0xFF52F0D4);
  static const Color brandDark = Color(0xFF008E76);

  // Income / Expense
  static const Color income = Color(0xFF1B8A4D);
  static const Color incomeLight = Color(0xFFE8F5E9);
  static const Color expense = Color(0xFFC0392B);
  static const Color expenseLight = Color(0xFFFFEBEE);

  // Neutral
  static const Color surface = Color(0xFFF9FAFB);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color outline = Color(0xFFE0E0E0);
  static const Color outlineDark = Color(0xFF3A3A3C);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textPrimaryDark = Color(0xFFF5F5F7);
  static const Color textSecondaryDark = Color(0xFF8E8E93);

  // Status
  static const Color success = Color(0xFF1B8A4D);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFC0392B);
  static const Color info = Color(0xFF2563EB);

  // Budget progress states
  static const Color budgetLow = Color(0xFF00BFA5);     // < 50%
  static const Color budgetMid = Color(0xFFF59E0B);     // 50–80%
  static const Color budgetHigh = Color(0xFFF97316);    // 80–100%
  static const Color budgetOver = Color(0xFFC0392B);    // > 100%

  // Category palette
  static const List<Color> categoryPalette = [
    Color(0xFFEF5350),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF673AB7),
    Color(0xFF3F51B5),
    Color(0xFF2196F3),
    Color(0xFF03A9F4),
    Color(0xFF00BCD4),
    Color(0xFF009688),
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
    Color(0xFFCDDC39),
    Color(0xFFFFEB3B),
    Color(0xFFFFC107),
    Color(0xFFFF9800),
    Color(0xFFFF5722),
  ];

  // Avatar tonal colors (7 tones)
  static const List<Color> avatarTones = [
    Color(0xFF00BFA5),
    Color(0xFF2563EB),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
    Color(0xFFF59E0B),
    Color(0xFF4CAF50),
    Color(0xFFFF5722),
  ];

  // Glassmorphism card overlay
  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x1AFFFFFF);
}
