import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand / Primary ─────────────────────────────────────────────────────────
  // Electric Blue — Coinbase/Revolut tier fintech
  static const Color brand = Color(0xFF0052FF);
  static const Color brandLight = Color(0xFF4D7CFF);
  static const Color brandDark = Color(0xFF0040CC);

  // Gradient pair for hero surfaces
  static const Color gradientStart = Color(0xFF0052FF);
  static const Color gradientEnd = Color(0xFF1E3A8A);

  // ── Semantic ─────────────────────────────────────────────────────────────────
  static const Color income = Color(0xFF059669);   // Emerald
  static const Color incomeLight = Color(0xFFECFDF5);
  static const Color incomeDark = Color(0xFF064E3B);
  static const Color incomeChip = Color(0xFF10B981);

  static const Color expense = Color(0xFFEF4444);  // Red
  static const Color expenseLight = Color(0xFFFEF2F2);
  static const Color expenseDark = Color(0xFF7F1D1D);
  static const Color expenseChip = Color(0xFFF87171);

  // ── Neutral / Surface ────────────────────────────────────────────────────────
  // Light
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineStrong = Color(0xFFCBD5E1);

  // Dark
  static const Color backgroundDark = Color(0xFF080D1A);   // Deep navy
  static const Color surfaceDark = Color(0xFF0F1629);       // Card surface
  static const Color surfaceElevatedDark = Color(0xFF172040); // Elevated card
  static const Color outlineDark = Color(0xFF1E2D4F);
  static const Color outlineStrongDark = Color(0xFF2A3F6A);

  // ── Text ─────────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF475569);

  // ── Status ───────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF0052FF);
  static const Color infoLight = Color(0xFFEFF6FF);

  // ── Budget progress states ────────────────────────────────────────────────────
  static const Color budgetLow = Color(0xFF059669);
  static const Color budgetMid = Color(0xFFF59E0B);
  static const Color budgetHigh = Color(0xFFF97316);
  static const Color budgetOver = Color(0xFFEF4444);

  // ── Category palette ─────────────────────────────────────────────────────────
  // Curated, balanced, accessible set — no neons
  static const List<Color> categoryPalette = [
    Color(0xFF0052FF), // Blue
    Color(0xFF059669), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF10B981), // Teal
    Color(0xFFF97316), // Orange
    Color(0xFF6366F1), // Indigo
    Color(0xFF14B8A6), // Teal-2
    Color(0xFFA78BFA), // Purple light
    Color(0xFFFBBF24), // Yellow
    Color(0xFF34D399), // Green light
    Color(0xFF60A5FA), // Blue light
    Color(0xFFF472B6), // Pink light
  ];

  // ── Avatar tonal colors ───────────────────────────────────────────────────────
  static const List<Color> avatarTones = [
    Color(0xFF0052FF),
    Color(0xFF059669),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFF59E0B),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
  ];

  // ── Glassmorphism ─────────────────────────────────────────────────────────────
  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x0DFFFFFF);
}
