import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/dashboard/data/home_layout_repository.dart';
import 'package:money_manager/features/dashboard/domain/models/home_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HomeLayoutRepository', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test(
      'returns the default-enabled set on first launch (never customised)',
      () async {
        final repo = HomeLayoutRepository();
        final enabled = await repo.getEnabledSections();
        expect(enabled, equals(HomeSection.defaultEnabledSet));
      },
    );

    test(
      'returns an empty set when the user has explicitly disabled everything',
      () async {
        final repo = HomeLayoutRepository();
        await repo.saveEnabledSections(<HomeSection>{});
        final enabled = await repo.getEnabledSections();
        expect(enabled, isEmpty);
      },
    );

    test('round-trips an arbitrary subset of sections', () async {
      final repo = HomeLayoutRepository();
      final desired = {
        HomeSection.spendingRing,
        HomeSection.goals,
        HomeSection.budgetHealth,
      };
      await repo.saveEnabledSections(desired);
      final reloaded = await repo.getEnabledSections();
      expect(reloaded, equals(desired));
    });

    test('saves use stable string ids, not enum ordinals', () async {
      final repo = HomeLayoutRepository();
      await repo.saveEnabledSections({
        HomeSection.insightsSummary,
        HomeSection.categorySpending,
      });
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getStringList('home_layout_enabled_ids'),
        containsAll(<String>[
          HomeSection.insightsSummary.id,
          HomeSection.categorySpending.id,
        ]),
      );
      expect(prefs.getBool('home_layout_customised'), isTrue);
    });

    test('resetToDefaults clears persistence and falls back to defaults',
        () async {
      final repo = HomeLayoutRepository();
      await repo.saveEnabledSections(<HomeSection>{HomeSection.goals});
      expect(await repo.getEnabledSections(), {HomeSection.goals});

      await repo.resetToDefaults();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('home_layout_customised'), isNull);
      expect(prefs.getStringList('home_layout_enabled_ids'), isNull);
      expect(
        await repo.getEnabledSections(),
        equals(HomeSection.defaultEnabledSet),
      );
    });

    test('unknown ids on disk are ignored gracefully (forward-compat)',
        () async {
      SharedPreferences.setMockInitialValues({
        'home_layout_customised': true,
        'home_layout_enabled_ids': <String>[
          HomeSection.quickStats.id,
          'a_section_that_was_removed',
        ],
      });
      final repo = HomeLayoutRepository();
      final enabled = await repo.getEnabledSections();
      expect(enabled, {HomeSection.quickStats});
    });
  });
}
