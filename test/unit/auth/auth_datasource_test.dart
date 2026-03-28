import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/auth/data/auth_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage mockSecure;
  late AuthLocalDatasource datasource;

  setUp(() {
    mockSecure = _MockSecureStorage();
    datasource = AuthLocalDatasource(secureStorage: mockSecure);
    SharedPreferences.setMockInitialValues({});
  });

  group('PIN operations', () {
    test('savePin writes to secure storage', () async {
      when(() => mockSecure.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});
      await datasource.savePin('123456');
      verify(() => mockSecure.write(key: 'app_pin', value: '123456')).called(1);
    });

    test('hasPin returns false when no pin stored', () async {
      when(() => mockSecure.read(key: 'app_pin')).thenAnswer((_) async => null);
      expect(await datasource.hasPin(), isFalse);
    });

    test('hasPin returns true when pin stored', () async {
      when(() => mockSecure.read(key: 'app_pin'))
          .thenAnswer((_) async => '123456');
      expect(await datasource.hasPin(), isTrue);
    });

    test('verifyPin returns true for matching PIN', () async {
      when(() => mockSecure.read(key: 'app_pin'))
          .thenAnswer((_) async => '123456');
      expect(await datasource.verifyPin('123456'), isTrue);
    });

    test('verifyPin returns false for wrong PIN', () async {
      when(() => mockSecure.read(key: 'app_pin'))
          .thenAnswer((_) async => '123456');
      expect(await datasource.verifyPin('000000'), isFalse);
    });

    test('clearPin deletes from secure storage', () async {
      when(() => mockSecure.delete(key: 'app_pin')).thenAnswer((_) async {});
      await datasource.clearPin();
      verify(() => mockSecure.delete(key: 'app_pin')).called(1);
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
