import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/security/pin_hasher.dart';

const _kPinKey = 'app_pin';
const _kOnboardingDone = 'onboarding_done';
const _kProfileName = 'profile_name';
const _kProfileColor = 'profile_color';
const _kCurrencyCode = 'currency_code';
const _kCurrencySymbol = 'currency_symbol';
const _kPinFailedAttempts = 'pin_failed_attempts';
const _kPinLockoutLevel = 'pin_lockout_level';
const _kPinLockoutUntilMs = 'pin_lockout_until_ms';

/// Keys this datasource owns inside [FlutterSecureStorage]. Enumerating them
/// avoids `deleteAll()` blowing away unrelated secrets that other code paths
/// may add later.
const _ownedSecureKeys = <String>{_kPinKey};

/// Hardened iOS/macOS keychain accessibility for the PIN: stay on this device
/// only and require the device to have been unlocked at least once. Prevents
/// the PIN from being silently restored to a different device through iCloud
/// Keychain.
const _iosOptions = IOSOptions(
  accessibility: KeychainAccessibility.first_unlock_this_device,
  synchronizable: false,
);
const _macosOptions = MacOsOptions(
  accessibility: KeychainAccessibility.first_unlock_this_device,
  synchronizable: false,
);

class AuthLocalDatasource {
  AuthLocalDatasource({
    FlutterSecureStorage? secureStorage,
    PinHasher? pinHasher,
  }) : _secure = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: _iosOptions,
              mOptions: _macosOptions,
            ),
        _hasher = pinHasher ?? const PinHasher();

  final FlutterSecureStorage _secure;
  final PinHasher _hasher;

  // ── PIN ─────────────────────────────────────────────────────────────────

  /// Hashes [pin] with PBKDF2 and persists the encoded value.
  Future<void> savePin(String pin) async {
    final encoded = _hasher.hash(pin);
    await _secure.write(key: _kPinKey, value: encoded);
  }

  Future<String?> getPin() => _secure.read(key: _kPinKey);

  Future<bool> hasPin() async => (await _secure.read(key: _kPinKey)) != null;

  Future<void> clearPin() async {
    await _secure.delete(key: _kPinKey);
    await _resetPinSecurityState();
  }

  /// Verifies [pin] against the stored hash. If a legacy plaintext PIN is on
  /// disk (created before PBKDF2 was introduced), it is accepted once and
  /// transparently re-saved in hashed form.
  Future<bool> verifyPin(String pin) async {
    final stored = await _secure.read(key: _kPinKey);
    if (stored == null) return false;
    final ok = _hasher.verify(pin, stored);
    if (ok && !_hasher.isHashed(stored)) {
      await savePin(pin);
    }
    return ok;
  }

  // ── PIN brute-force protection (persistent) ─────────────────────────────

  Future<int> getFailedPinAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kPinFailedAttempts) ?? 0;
  }

  Future<void> setFailedPinAttempts(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPinFailedAttempts, value);
  }

  Future<int> getPinLockoutLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kPinLockoutLevel) ?? 0;
  }

  Future<void> setPinLockoutLevel(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPinLockoutLevel, value);
  }

  Future<DateTime?> getPinLockoutUntil() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_kPinLockoutUntilMs);
    if (ms == null || ms == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setPinLockoutUntil(DateTime? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_kPinLockoutUntilMs);
    } else {
      await prefs.setInt(_kPinLockoutUntilMs, value.millisecondsSinceEpoch);
    }
  }

  Future<void> _resetPinSecurityState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPinFailedAttempts);
    await prefs.remove(_kPinLockoutLevel);
    await prefs.remove(_kPinLockoutUntilMs);
  }

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
    for (final key in _ownedSecureKeys) {
      await _secure.delete(key: key);
    }
  }
}
