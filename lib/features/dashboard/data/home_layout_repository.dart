import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/home_section.dart';

/// Persists the user's home-screen customisation as a list of stable
/// [HomeSection.id] strings in [SharedPreferences].
///
/// The stored marker [_kCustomisedFlag] tells us whether the user has ever
/// touched the layout — without it we can't distinguish "user disabled
/// everything" from "first launch, fall back to defaults".
class HomeLayoutRepository {
  HomeLayoutRepository({SharedPreferences? prefs}) : _prefsOverride = prefs;

  static const _kEnabledIds = 'home_layout_enabled_ids';
  static const _kCustomisedFlag = 'home_layout_customised';

  final SharedPreferences? _prefsOverride;

  Future<SharedPreferences> get _prefs async =>
      _prefsOverride ?? await SharedPreferences.getInstance();

  /// Returns the set of sections the user wants on their dashboard.
  ///
  /// Defaults to [HomeSection.defaultEnabledSet] until the user customises
  /// the layout for the first time.
  Future<Set<HomeSection>> getEnabledSections() async {
    final prefs = await _prefs;
    final customised = prefs.getBool(_kCustomisedFlag) ?? false;
    if (!customised) return HomeSection.defaultEnabledSet;
    final ids = prefs.getStringList(_kEnabledIds) ?? const <String>[];
    final resolved = <HomeSection>{};
    for (final id in ids) {
      final section = HomeSection.fromId(id);
      if (section != null) resolved.add(section);
    }
    return resolved;
  }

  /// Persists the [enabled] set, marking the layout as customised so that
  /// future reads no longer fall back to defaults.
  Future<void> saveEnabledSections(Set<HomeSection> enabled) async {
    final prefs = await _prefs;
    await prefs.setStringList(
      _kEnabledIds,
      enabled.map((s) => s.id).toList(growable: false),
    );
    await prefs.setBool(_kCustomisedFlag, true);
  }

  /// Wipes the user's customisation, restoring the default layout.
  Future<void> resetToDefaults() async {
    final prefs = await _prefs;
    await prefs.remove(_kEnabledIds);
    await prefs.remove(_kCustomisedFlag);
  }
}
