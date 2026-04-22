import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/constants/constants.dart';
import 'package:money_manager/core/theme/app_theme_extension.dart';

/// Wraps [widget] with MaterialApp + ProviderScope so widgets that use
/// Theme or Riverpod providers can be pumped in isolation.
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brand),
            extensions: [AppThemeExtension.light],
          ),
          home: widget,
        ),
      ),
    );
  }
}
