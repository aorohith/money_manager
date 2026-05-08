import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/auth/data/auth_local_datasource.dart';
import 'package:money_manager/features/auth/domain/auth_state.dart';
import 'package:money_manager/features/auth/providers/auth_provider.dart';

class _MockAuthDatasource extends Mock implements AuthLocalDatasource {}

void main() {
  late _MockAuthDatasource ds;
  late ProviderContainer container;

  setUp(() {
    ds = _MockAuthDatasource();
    container = ProviderContainer(
      overrides: [authDatasourceProvider.overrideWithValue(ds)],
    );
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
}
