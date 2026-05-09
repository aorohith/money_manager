import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/auth/data/auth_local_datasource.dart';
import 'package:money_manager/features/auth/presentation/pin_lock_screen.dart';
import 'package:money_manager/features/auth/providers/auth_provider.dart';

class _MockAuthDatasource extends Mock implements AuthLocalDatasource {}

class _MockLocalAuth extends Mock implements LocalAuthentication {}

void main() {
  late _MockAuthDatasource ds;
  late _MockLocalAuth auth;

  setUp(() {
    ds = _MockAuthDatasource();
    auth = _MockLocalAuth();
    when(() => ds.isOnboardingDone()).thenAnswer((_) async => true);
    when(() => ds.hasPin()).thenAnswer((_) async => true);
    when(() => ds.getBiometricEnabled()).thenAnswer((_) async => false);
    when(() => ds.getFailedPinAttempts()).thenAnswer((_) async => 0);
    when(() => ds.getPinLockoutLevel()).thenAnswer((_) async => 0);
    when(() => auth.getAvailableBiometrics()).thenAnswer((_) async => []);
  });

  Future<void> pumpLockScreen(
    WidgetTester tester, {
    DateTime? lockoutUntil,
  }) async {
    when(() => ds.getPinLockoutUntil())
        .thenAnswer((_) async => lockoutUntil);

    // The PIN pad assumes phone-sized vertical space; the default test
    // viewport is too short for the keypad to render without overflow.
    await tester.binding.setSurfaceSize(const Size(420, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authDatasourceProvider.overrideWithValue(ds),
          localAuthProvider.overrideWithValue(auth),
        ],
        child: const MaterialApp(home: PinLockScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the PIN pad when no lockout is active', (tester) async {
    await pumpLockScreen(tester);
    expect(find.text('Enter your PIN'), findsOneWidget);
    expect(find.textContaining('Too many attempts'), findsNothing);
  });

  testWidgets('renders the lockout countdown when locked', (tester) async {
    await pumpLockScreen(
      tester,
      lockoutUntil: DateTime.now().add(const Duration(seconds: 30)),
    );

    // Pumping settles the FutureProvider; the countdown text must appear.
    expect(find.textContaining('Too many attempts'), findsOneWidget);
  });
}
