import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPinKey = 'app_pin';
const _kOnboardingDone = 'onboarding_done';
const _kProfileName = 'profile_name';
const _kProfileColor = 'profile_color';
const _kCurrencyCode = 'currency_code';
const _kCurrencySymbol = 'currency_symbol';

class AuthLocalDatasource {
  AuthLocalDatasource({
    FlutterSecureStorage? secureStorage,
  }) : _secure = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _secure;

  // ── PIN ─────────────────────────────────────────────────────────────────

  Future<void> savePin(String pin) => _secure.write(key: _kPinKey, value: pin);

  Future<String?> getPin() => _secure.read(key: _kPinKey);

  Future<bool> hasPin() async => (await _secure.read(key: _kPinKey)) != null;

  Future<void> clearPin() => _secure.delete(key: _kPinKey);

  Future<bool> verifyPin(String pin) async =>
      (await _secure.read(key: _kPinKey)) == pin;

  // ── Onboarding ───────────────────────────────────────────────────────────

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingDone) ?? false;
  }

  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDone, true);
  }

  // ── Profile ──────────────────────────────────────────────────────────────

  Future<void> saveProfile({
    required String name,
    required int colorValue,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfileName, name);
    await prefs.setInt(_kProfileColor, colorValue);
  }

  Future<String> getProfileName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kProfileName) ?? '';
  }

  Future<int> getProfileColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kProfileColor) ?? 0xFF00BFA5;
  }

  // ── Currency ─────────────────────────────────────────────────────────────

  Future<void> saveCurrency({
    required String code,
    required String symbol,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrencyCode, code);
    await prefs.setString(_kCurrencySymbol, symbol);
  }

  Future<String> getCurrencyCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kCurrencyCode) ?? 'USD';
  }

  Future<String> getCurrencySymbol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kCurrencySymbol) ?? '\$';
  }

  // ── Theme ───────────────────────────────────────────────────────────────

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('theme_mode') ?? 'system';
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode);
  }

  // ── Biometric preference ────────────────────────────────────────────────

  Future<bool> getBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  Future<void> saveBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
  }

  // ── Clear all data ──────────────────────────────────────────────────────

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secure.deleteAll();
  }
}
