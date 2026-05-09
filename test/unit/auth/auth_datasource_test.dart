import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/core/security/pin_hasher.dart';
import 'package:money_manager/features/auth/data/auth_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage mockSecure;
  late AuthLocalDatasource datasource;
  late PinHasher hasher;

  setUp(() {
    mockSecure = _MockSecureStorage();
    hasher = const PinHasher();
    datasource = AuthLocalDatasource(
      secureStorage: mockSecure,
      pinHasher: hasher,
    );
    SharedPreferences.setMockInitialValues({});
  });

  group('PIN operations', () {
    test('savePin writes a PBKDF2-encoded value, never plaintext', () async {
      String? captured;
      when(
        () => mockSecure.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((invocation) async {
        captured = invocation.namedArguments[const Symbol('value')] as String?;
      });

      await datasource.savePin('123456');

      expect(captured, isNotNull);
      expect(captured!.startsWith('pbkdf2\$'), isTrue);
      expect(captured!.contains('123456'), isFalse);
      expect(hasher.verify('123456', captured!), isTrue);
    });

    test('hasPin reflects presence in secure storage', () async {
      when(() => mockSecure.read(key: 'app_pin')).thenAnswer((_) async => null);
      expect(await datasource.hasPin(), isFalse);

      when(() => mockSecure.read(key: 'app_pin'))
          .thenAnswer((_) async => 'pbkdf2\$1\$AA==\$BB==');
      expect(await datasource.hasPin(), isTrue);
    });

    test('verifyPin matches the hashed value', () async {
      final stored = hasher.hash('123456');
      when(() => mockSecure.read(key: 'app_pin'))
          .thenAnswer((_) async => stored);

      expect(await datasource.verifyPin('123456'), isTrue);
      expect(await datasource.verifyPin('000000'), isFalse);
    });

    test('verifyPin migrates legacy plaintext PINs to hashed form', () async {
      var stored = '123456'; // legacy plaintext
      when(() => mockSecure.read(key: 'app_pin'))
          .thenAnswer((_) async => stored);
      when(
        () => mockSecure.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((invocation) async {
        stored = invocation.namedArguments[const Symbol('value')] as String;
      });

      expect(await datasource.verifyPin('123456'), isTrue);
      expect(stored.startsWith('pbkdf2\$'), isTrue);
      verify(() =>
              mockSecure.write(key: 'app_pin', value: any(named: 'value')))
          .called(1);
    });

    test('verifyPin returns false when nothing is stored', () async {
      when(() => mockSecure.read(key: 'app_pin')).thenAnswer((_) async => null);
      expect(await datasource.verifyPin('123456'), isFalse);
    });

    test('clearPin deletes the secret and clears lockout state', () async {
      when(() => mockSecure.delete(key: 'app_pin')).thenAnswer((_) async {});
      SharedPreferences.setMockInitialValues({
        'pin_failed_attempts': 3,
        'pin_lockout_level': 1,
        'pin_lockout_until_ms': DateTime.now().millisecondsSinceEpoch,
      });

      await datasource.clearPin();

      verify(() => mockSecure.delete(key: 'app_pin')).called(1);
      expect(await datasource.getFailedPinAttempts(), 0);
      expect(await datasource.getPinLockoutLevel(), 0);
      expect(await datasource.getPinLockoutUntil(), isNull);
    });

    test('clearAllData only deletes secrets this datasource owns', () async {
      when(() => mockSecure.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      await datasource.clearAllData();

      verify(() => mockSecure.delete(key: 'app_pin')).called(1);
      verifyNever(() => mockSecure.deleteAll());
    });
  });

  group('PIN lockout state', () {
    test('round-trips failed-attempt counter', () async {
      expect(await datasource.getFailedPinAttempts(), 0);
      await datasource.setFailedPinAttempts(3);
      expect(await datasource.getFailedPinAttempts(), 3);
    });

    test('round-trips lockout level', () async {
      await datasource.setPinLockoutLevel(2);
      expect(await datasource.getPinLockoutLevel(), 2);
    });

    test('round-trips lockoutUntil and clears it on null', () async {
      final until = DateTime.utc(2026, 6, 1, 10, 30);
      await datasource.setPinLockoutUntil(until);
      final stored = await datasource.getPinLockoutUntil();
      // SharedPreferences round-trips through epoch ms; the returned value is
      // the same instant but expressed in local time.
      expect(stored, isNotNull);
      expect(stored!.isAtSameMomentAs(until), isTrue);
      await datasource.setPinLockoutUntil(null);
      expect(await datasource.getPinLockoutUntil(), isNull);
    });
  });

  group('Onboarding flag', () {
    test('isOnboardingDone returns false by default', () async {
      expect(await datasource.isOnboardingDone(), isFalse);
    });

    test('isOnboardingDone returns true after setOnboardingDone', () async {
      await datasource.setOnboardingDone();
      expect(await datasource.isOnboardingDone(), isTrue);
    });
  });

  group('Profile', () {
    test('getProfileName returns empty string by default', () async {
      expect(await datasource.getProfileName(), '');
    });

    test('saveProfile persists name and color', () async {
      await datasource.saveProfile(name: 'Alice', colorValue: 0xFF00BFA5);
      expect(await datasource.getProfileName(), 'Alice');
      expect(await datasource.getProfileColor(), 0xFF00BFA5);
    });
  });

  group('Currency', () {
    test('getCurrencyCode returns USD by default', () async {
      expect(await datasource.getCurrencyCode(), 'USD');
    });

    test('saveCurrency persists code and symbol', () async {
      await datasource.saveCurrency(code: 'EUR', symbol: '€');
      expect(await datasource.getCurrencyCode(), 'EUR');
      expect(await datasource.getCurrencySymbol(), '€');
    });
  });
}
