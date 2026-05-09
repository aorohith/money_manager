import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/dashboard/data/home_layout_repository.dart';
import 'package:money_manager/features/dashboard/domain/models/home_section.dart';
import 'package:money_manager/features/dashboard/domain/providers/home_layout_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('homeLayoutProvider', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    ProviderContainer makeContainer() {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      return container;
    }

    test(
      'first read returns defaults when nothing is persisted',
      () async {
        final container = makeContainer();
        final enabled = await container.read(homeLayoutProvider.future);
        expect(enabled, equals(HomeSection.defaultEnabledSet));
      },
    );

    test('setEnabled(true) adds a section and persists it', () async {
      final container = makeContainer();
      await container.read(homeLayoutProvider.future);

      await container
          .read(homeLayoutProvider.notifier)
          .setEnabled(HomeSection.goals, true);

      expect(
        container.read(homeLayoutProvider).valueOrNull,
        contains(HomeSection.goals),
      );

      // Verify persistence by reading through a fresh repository instance.
      final reloaded = await HomeLayoutRepository().getEnabledSections();
      expect(reloaded, contains(HomeSection.goals));
    });

    test('setEnabled(false) removes a default-on section', () async {
      final container = makeContainer();
      await container.read(homeLayoutProvider.future);

      await container
          .read(homeLayoutProvider.notifier)
          .setEnabled(HomeSection.categorySpending, false);

      expect(
        container.read(homeLayoutProvider).valueOrNull,
        isNot(contains(HomeSection.categorySpending)),
      );

      final reloaded = await HomeLayoutRepository().getEnabledSections();
      expect(reloaded, isNot(contains(HomeSection.categorySpending)));
    });

    test('setEnabled is a no-op when state would not change', () async {
      final container = makeContainer();
      await container.read(homeLayoutProvider.future);
      // categorySpending is on by default.
      final before = container.read(homeLayoutProvider).valueOrNull;

      await container
          .read(homeLayoutProvider.notifier)
          .setEnabled(HomeSection.categorySpending, true);

      final after = container.read(homeLayoutProvider).valueOrNull;
      expect(after, equals(before));
    });

    test('resetToDefaults restores defaults and clears persistence',
        () async {
      final container = makeContainer();
      await container.read(homeLayoutProvider.future);
      final notifier = container.read(homeLayoutProvider.notifier);
      await notifier.setEnabled(HomeSection.goals, true);
      await notifier.setEnabled(HomeSection.spendingRing, true);

      await notifier.resetToDefaults();

      expect(
        container.read(homeLayoutProvider).valueOrNull,
        equals(HomeSection.defaultEnabledSet),
      );
      // Repository should have been wiped, so a fresh instance also sees
      // defaults.
      final reloaded = await HomeLayoutRepository().getEnabledSections();
      expect(reloaded, equals(HomeSection.defaultEnabledSet));
    });
  });
}
