import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/theme/theme.dart';
import 'package:money_manager/features/auth/domain/auth_state.dart';
import 'package:money_manager/features/auth/providers/auth_provider.dart';

void main() {
  testWidgets('MaterialApp renders with light theme', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith(() => _FakeAuthNotifier())],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('MaterialApp renders with dark theme', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith(() => _FakeAuthNotifier())],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  Future<AuthStatus> build() async => AuthStatus.unauthenticated;
}
