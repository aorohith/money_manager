import 'package:daily_planner/theme/theme.dart';
import 'package:flutter/material.dart';

class ThemeColor {
  ThemeData getThemeData({required bool isDark}) {
    return ThemeData(
        useMaterial3: false,
        primaryColor: ThemeColors.primaryColor,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: ThemeColors.secondaryColor),
        scaffoldBackgroundColor: ThemeColors.backgroundColor,
        fontFamily: FontFamily.fontFamilyName,
        canvasColor: ThemeColors.backgroundColor,
        iconTheme: const IconThemeData(color: ThemeColors.fontColor),
        inputDecorationTheme: getInputDecorationTheme(isDark: isDark),
        sliderTheme: const SliderThemeData(
          thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 5, disabledThumbRadius: 5),
        ),
        appBarTheme:
            const AppBarTheme(backgroundColor: ThemeColors.primaryColor),
        radioTheme: RadioThemeData(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            fillColor: MaterialStateColor.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return ThemeColors.warningColor;
              }
              return ThemeColors.fontColor;
            })),
        // textTheme: GoogleFonts.getTextTheme(FontFamily.fontFamilyName),
        scrollbarTheme: const ScrollbarThemeData().copyWith(
          thumbColor: MaterialStateProperty.all(Colors.black.withOpacity(0.24)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStatePropertyAll<OutlinedBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
            ),
            backgroundColor:
                MaterialStateProperty.all<Color>(ThemeColors.primaryColor),
            foregroundColor:
                MaterialStateProperty.all<Color>(ThemeColors.whiteColor),
            padding: const MaterialStatePropertyAll<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            elevation: MaterialStateProperty.all<double>(0),
            enableFeedback: true,
          ),
        ),
        tabBarTheme: TabBarTheme(
          unselectedLabelColor: ThemeColors.whiteColor.withOpacity(0.7),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: ThemeColors.whiteColor,
          indicatorColor: ThemeColors.whiteColor,
          // indicator: const CustomTabIndicator(color: ThemeColors.whiteColor),
          unselectedLabelStyle: AppFontStyle.bodyMedium
              ?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
          labelStyle: AppFontStyle.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
        ));
  }

  InputDecorationTheme getInputDecorationTheme({
    required bool isDark,
  }) {
    return InputDecorationTheme(
      contentPadding: const EdgeInsets.all(14),
      errorMaxLines: 2,
      filled: true,
      fillColor: ThemeColors.fontColor,
      disabledBorder: getTextFieldBorder(isDark: isDark),
      errorBorder: getTextFieldBorder(isDark: isDark).copyWith(
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: getTextFieldBorder(isDark: isDark),
      isDense: true,
      focusedBorder: getTextFieldBorder(isDark: isDark),
      border: getTextFieldBorder(isDark: isDark),
      errorStyle: getErrorStyle(isDark: isDark),
      hintStyle: getHintText(isDark: isDark),
      labelStyle: getHintText(isDark: isDark),
      focusColor: ThemeColors.fontColor,
      alignLabelWithHint: false,
    );
  }

  OutlineInputBorder getTextFieldBorder({
    required bool isDark,
  }) {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: ThemeColors.fontColor, width: 1),
      borderRadius: BorderRadius.circular(8),
      gapPadding: 0,
    );
  }

  TextStyle getHintText({
    required bool isDark,
  }) {
    return const TextStyle(
      color: ThemeColors.fontColor,
    );
  }

  TextStyle getErrorStyle({
    required bool isDark,
  }) {
    return const TextStyle(color: Colors.grey);
  }
}
