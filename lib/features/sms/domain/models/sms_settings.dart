/// Plain Dart value object for SMS auto-detection settings.
/// Persisted via SharedPreferences (no Isar collection needed).
class SmsSettings {
  const SmsSettings({
    this.enabled = true,
    this.autoAddMode = SmsAutoAddMode.askAlways,
    this.confidenceThreshold = 75,
    this.detectSubscriptions = true,
    this.detectRefunds = true,
  });

  final bool enabled;
  final SmsAutoAddMode autoAddMode;

  /// 0–100. If categorization confidence is below this, the user is prompted.
  final int confidenceThreshold;

  final bool detectSubscriptions;
  final bool detectRefunds;

  SmsSettings copyWith({
    bool? enabled,
    SmsAutoAddMode? autoAddMode,
    int? confidenceThreshold,
    bool? detectSubscriptions,
    bool? detectRefunds,
  }) {
    return SmsSettings(
      enabled: enabled ?? this.enabled,
      autoAddMode: autoAddMode ?? this.autoAddMode,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      detectSubscriptions: detectSubscriptions ?? this.detectSubscriptions,
      detectRefunds: detectRefunds ?? this.detectRefunds,
    );
  }

  // ── SharedPreferences keys ───────────────────────────────────────────────
  static const _kEnabled = 'sms_enabled';
  static const _kMode = 'sms_auto_add_mode';
  static const _kThreshold = 'sms_confidence_threshold';
  static const _kSubscriptions = 'sms_detect_subscriptions';
  static const _kRefunds = 'sms_detect_refunds';

  Map<String, dynamic> toPrefs() => {
        _kEnabled: enabled,
        _kMode: autoAddMode.index,
        _kThreshold: confidenceThreshold,
        _kSubscriptions: detectSubscriptions,
        _kRefunds: detectRefunds,
      };

  factory SmsSettings.fromPrefs(Map<String, dynamic> prefs) => SmsSettings(
        enabled: prefs[_kEnabled] as bool? ?? true,
        autoAddMode: SmsAutoAddMode
            .values[prefs[_kMode] as int? ?? 0],
        confidenceThreshold: prefs[_kThreshold] as int? ?? 75,
        detectSubscriptions: prefs[_kSubscriptions] as bool? ?? true,
        detectRefunds: prefs[_kRefunds] as bool? ?? true,
      );
}

enum SmsAutoAddMode {
  /// Show confirmation for every detected transaction.
  askAlways,

  /// Silently save if a user rule exists; ask for new merchants.
  autoAddKnown,

  /// Save everything silently (power-user mode).
  silentAll,
}

extension SmsAutoAddModeLabel on SmsAutoAddMode {
  String get label => switch (this) {
        SmsAutoAddMode.askAlways => 'Ask always',
        SmsAutoAddMode.autoAddKnown => 'Auto-add known merchants',
        SmsAutoAddMode.silentAll => 'Silent (auto-add all)',
      };

  String get description => switch (this) {
        SmsAutoAddMode.askAlways =>
          'Review every detected transaction before saving',
        SmsAutoAddMode.autoAddKnown =>
          'Silently save merchants you\'ve confirmed before; ask for new ones',
        SmsAutoAddMode.silentAll =>
          'Automatically save all detected transactions without prompting',
      };
}
