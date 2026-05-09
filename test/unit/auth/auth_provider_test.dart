import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/auth/data/auth_local_datasource.dart';
import 'package:money_manager/features/auth/domain/auth_state.dart';
import 'package:money_manager/features/auth/providers/auth_provider.dart';

class _MockAuthDatasource extends Mock implements AuthLocalDatasource {}

class _MockLocalAuth extends Mock implements LocalAuthentication {}

class _FakeAuthOptions extends Fake implements AuthenticationOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAuthOptions());
  });

  late _MockAuthDatasource ds;
  late _MockLocalAuth localAuth;
  late ProviderContainer container;

  void stubLockoutDefaults() {
    when(() => ds.getFailedPinAttempts()).thenAnswer((_) async => 0);
    when(() => ds.getPinLockoutLevel()).thenAnswer((_) async => 0);
    when(() => ds.getPinLockoutUntil()).thenAnswer((_) async => null);
    when(() => ds.setFailedPinAttempts(any())).thenAnswer((_) async {});
    when(() => ds.setPinLockoutLevel(any())).thenAnswer((_) async {});
    when(() => ds.setPinLockoutUntil(any())).thenAnswer((_) async {});
  }

  setUp(() {
    ds = _MockAuthDatasource();
    localAuth = _MockLocalAuth();
    container = ProviderContainer(
      overrides: [
        authDatasourceProvider.overrideWithValue(ds),
        localAuthProvider.overrideWithValue(localAuth),
      ],
    );
    stubLockoutDefaults();
  });

  tearDown(() {
    container.dispose();
  });

  test('build returns unauthenticated when onboarding not complete', () async {
    when(() => ds.isOnboardingDone()).thenAnswer((_) async => false);

    final status = await container.read(authProvider.future);
    expect(status, AuthStatus.unauthenticated);
    verifyNever(() => ds.hasPin());
  });

  test('build returns pinSetup when onboarding done but no pin', () async {
    when(() => ds.isOnboardingDone()).thenAnswer((_) async => true);
    when(() => ds.hasPin()).thenAnswer((_) async => false);

    final status = await container.read(authProvider.future);
    expect(status, AuthStatus.pinSetup);
  });

  test('build returns locked when onboarding done and pin exists', () async {
    when(() => ds.isOnboardingDone()).thenAnswer((_) async => true);
    when(() => ds.hasPin()).thenAnswer((_) async => true);

    final status = await container.read(authProvider.future);
    expect(status, AuthStatus.locked);
  });

  test('completeOnboarding sets status to pinSetup', () async {
    when(() => ds.isOnboardingDone()).thenAnswer((_) async => false);
    when(() => ds.setOnboardingDone()).thenAnswer((_) async {});
    await container.read(authProvider.future);

    await container.read(authProvider.notifier).completeOnboarding();

    expect(container.read(authProvider).value, AuthStatus.pinSetup);
    verify(() => ds.setOnboardingDone()).called(1);
  });

  test('setupPin saves pin and authenticates session', () async {
    when(() => ds.isOnboardingDone()).thenAnswer((_) async => true);
    when(() => ds.hasPin()).thenAnswer((_) async => false);
    when(() => ds.savePin('123456')).thenAnswer((_) async {});
    await container.read(authProvider.future);

    await container.read(authProvider.notifier).setupPin('123456');

    expect(container.read(authProvider).value, AuthStatus.authenticated);
    verify(() => ds.savePin('123456')).called(1);
    verify(() => ds.setFailedPinAttempts(0)).called(1);
    verify(() => ds.setPinLockoutLevel(0)).called(1);
    verify(() => ds.setPinLockoutUntil(null)).called(1);
  });

  test('unlockWithPin authenticates only when pin matches', () async {
    when(() => ds.isOnboardingDone()).thenAnswer((_) async => true);
    when(() => ds.hasPin()).thenAnswer((_) async => true);
    await container.read(authProvider.future);

    when(() => ds.verifyPin('000000')).thenAnswer((_) async => false);
    final bad = await container
        .read(authProvider.notifier)
        .unlockWithPin('000000');
    expect(bad, isFalse);
    expect(container.read(authProvider).value, AuthStatus.locked);

    when(() => ds.verifyPin('123456')).thenAnswer((_) async => true);
    final good = await container
        .read(authProvider.notifier)
        .unlockWithPin('123456');
    expect(good, isTrue);
    expect(container.read(authProvider).value, AuthStatus.authenticated);
  });

  test('lock sets status to locked', () async {
    when(() => ds.isOnboardingDone()).thenAnswer((_) async => true);
    when(() => ds.hasPin()).thenAnswer((_) async => true);
    await container.read(authProvider.future);

    container.read(authProvider.notifier).lock();
    expect(container.read(authProvider).value, AuthStatus.locked);
  });

  group('persistent PIN lockout', () {
    setUp(() {
      when(() => ds.isOnboardingDone()).thenAnswer((_) async => true);
      when(() => ds.hasPin()).thenAnswer((_) async => true);
    });

    test('arms a lockout after 5 failed attempts', () async {
      when(() => ds.verifyPin(any())).thenAnswer((_) async => false);

      var attempts = 0;
      when(() => ds.getFailedPinAttempts()).thenAnswer((_) async => attempts);
      when(() => ds.setFailedPinAttempts(any())).thenAnswer((invocation) async {
        attempts = invocation.positionalArguments.first as int;
      });

      var level = 0;
      when(() => ds.getPinLockoutLevel()).thenAnswer((_) async => level);
      when(() => ds.setPinLockoutLevel(any())).thenAnswer((invocation) async {
        level = invocation.positionalArguments.first as int;
      });

      DateTime? until;
      when(() => ds.getPinLockoutUntil()).thenAnswer((_) async => until);
      when(() => ds.setPinLockoutUntil(any())).thenAnswer((invocation) async {
        until = invocation.positionalArguments.first as DateTime?;
      });

      await container.read(authProvider.future);
      final notifier = container.read(authProvider.notifier);

      // First four bad attempts increment but do not lock.
      for (var i = 0; i < 4; i++) {
        final r = await notifier.verifyPinWithLockout('000000');
        expect(r.success, isFalse);
        expect(r.lockout.isLocked, isFalse);
      }
      expect(attempts, 4);

      // Fifth bad attempt triggers a level-1 lockout.
      final fifth = await notifier.verifyPinWithLockout('000000');
      expect(fifth.success, isFalse);
      expect(fifth.lockout.isLocked, isTrue);
      expect(fifth.lockout.lockoutLevel, 1);
      expect(attempts, 0); // counter resets per cycle
      expect(level, 1);
      expect(
        fifth.lockout.remaining.inSeconds,
        greaterThan(50),
      );
    });

    test('refuses verification while locked, without touching the hash', () async {
      when(() => ds.getPinLockoutUntil()).thenAnswer(
        (_) async => DateTime.now().add(const Duration(minutes: 1)),
      );
      when(() => ds.getFailedPinAttempts()).thenAnswer((_) async => 0);
      when(() => ds.getPinLockoutLevel()).thenAnswer((_) async => 1);

      await container.read(authProvider.future);
      final r = await container
          .read(authProvider.notifier)
          .verifyPinWithLockout('123456');

      expect(r.success, isFalse);
      expect(r.lockout.isLocked, isTrue);
      verifyNever(() => ds.verifyPin(any()));
    });

    test('successful unlock clears all persistent lockout state', () async {
      when(() => ds.verifyPin('123456')).thenAnswer((_) async => true);
      await container.read(authProvider.future);

      final r = await container
          .read(authProvider.notifier)
          .verifyPinWithLockout('123456');

      expect(r.success, isTrue);
      verify(() => ds.setFailedPinAttempts(0)).called(greaterThan(0));
      verify(() => ds.setPinLockoutLevel(0)).called(greaterThan(0));
      verify(() => ds.setPinLockoutUntil(null)).called(greaterThan(0));
    });

    test('biometric refuses to unlock while PIN is locked out', () async {
      when(() => ds.getBiometricEnabled()).thenAnswer((_) async => true);
      when(() => ds.getPinLockoutUntil()).thenAnswer(
        (_) async => DateTime.now().add(const Duration(minutes: 1)),
      );
      when(() => localAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);
      when(() => localAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => true);

      await container.read(authProvider.future);
      final ok = await container
          .read(authProvider.notifier)
          .unlockWithBiometric();

      expect(ok, isFalse);
      verifyNever(() => localAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          ));
    });
  });
}
