import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/constants.dart';
import 'app_theme_extension.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final base = FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: AppColors.brand,
        primaryContainer: Color(0xFFB2F5EA),
        secondary: Color(0xFF1B8A4D),
        secondaryContainer: Color(0xFFE8F5E9),
        tertiary: Color(0xFF2563EB),
        tertiaryContainer: Color(0xFFDCEEFF),
        appBarColor: AppColors.brand,
        error: AppColors.error,
        errorContainer: AppColors.expenseLight,
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
        defaultRadius: AppSpacing.radiusLg,
        elevatedButtonRadius: AppSpacing.radiusFull,
        outlinedButtonRadius: AppSpacing.radiusFull,
        filledButtonRadius: AppSpacing.radiusFull,
        textButtonRadius: AppSpacing.radiusFull,
        inputDecoratorRadius: AppSpacing.radiusMd,
        cardRadius: AppSpacing.radiusLg,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );

    return base.copyWith(
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      extensions: [AppThemeExtension.light],
      appBarTheme: base.appBarTheme.copyWith(
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        shape: const CircleBorder(),
      ),
    );
  }

  static ThemeData get dark {
    final base = FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: AppColors.brand,
        primaryContainer: Color(0xFF005045),
        secondary: Color(0xFF4CAF82),
        secondaryContainer: Color(0xFF1B2E23),
        tertiary: Color(0xFF60A5FA),
        tertiaryContainer: Color(0xFF1E3A5F),
        appBarColor: AppColors.brandDark,
        error: Color(0xFFEF6B62),
        errorContainer: Color(0xFF2E1B1B),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        defaultRadius: AppSpacing.radiusLg,
        elevatedButtonRadius: AppSpacing.radiusFull,
        outlinedButtonRadius: AppSpacing.radiusFull,
        filledButtonRadius: AppSpacing.radiusFull,
        textButtonRadius: AppSpacing.radiusFull,
        inputDecoratorRadius: AppSpacing.radiusMd,
        cardRadius: AppSpacing.radiusLg,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );

    return base.copyWith(
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      extensions: [AppThemeExtension.dark],
      appBarTheme: base.appBarTheme.copyWith(
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        shape: const CircleBorder(),
      ),
    );
  }
}
