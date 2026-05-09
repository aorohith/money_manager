import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/home_layout_repository.dart';
import '../models/home_section.dart';

final homeLayoutRepositoryProvider = Provider<HomeLayoutRepository>(
  (_) => HomeLayoutRepository(),
);

/// Exposes the user's customised set of enabled dashboard sections and
/// mutators that persist changes through [HomeLayoutRepository].
final homeLayoutProvider =
    AsyncNotifierProvider<HomeLayoutNotifier, Set<HomeSection>>(
  HomeLayoutNotifier.new,
);

class HomeLayoutNotifier extends AsyncNotifier<Set<HomeSection>> {
  late HomeLayoutRepository _repo;

  @override
  Future<Set<HomeSection>> build() async {
    _repo = ref.read(homeLayoutRepositoryProvider);
    return _repo.getEnabledSections();
  }

  /// Toggles [section] on or off and persists the result. Returns the
  /// updated set so callers can `await` the round-trip if they need to.
  Future<void> setEnabled(HomeSection section, bool enabled) async {
    final current = state.valueOrNull ?? HomeSection.defaultEnabledSet;
    final next = {...current};
    if (enabled) {
      next.add(section);
    } else {
      next.remove(section);
    }
    if (setEquals(next, current)) return;
    state = AsyncData(next);
    await _repo.saveEnabledSections(next);
  }

  /// Restores the default layout for new users and clears the persisted
  /// customisation flag.
  Future<void> resetToDefaults() async {
    final defaults = HomeSection.defaultEnabledSet;
    state = AsyncData(defaults);
    await _repo.resetToDefaults();
  }
}
