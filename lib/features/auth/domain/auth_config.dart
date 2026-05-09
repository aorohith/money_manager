/// Single source of truth for auth-flow tunables.
///
/// Centralised here so PIN length / copy never drift between the setup,
/// lock, and change-PIN surfaces (which previously each redeclared the
/// same `_pinLength` constant and the same "N-digit PIN" strings).
abstract final class AuthConfig {
  /// Number of digits in the app PIN. Update here only.
  static const int pinLength = 4;

  /// Human-readable PIN length, e.g. "4-digit".
  static String get pinLengthLabel => '$pinLength-digit';
}
