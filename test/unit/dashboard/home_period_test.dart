import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/dashboard/domain/models/home_section.dart';
import 'package:money_manager/features/dashboard/domain/providers/dashboard_providers.dart';
import 'package:money_manager/features/dashboard/domain/providers/home_layout_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('homePeriodRange', () {
    // Wednesday 15 April 2026, 10:30
    final reference = DateTime(2026, 4, 15, 10, 30);

    test('day → start of today through end of today', () {
      final (from, to) = homePeriodRange(HomePeriod.day, now: reference);
      expect(from, DateTime(2026, 4, 15));
      expect(to.add(const Duration(microseconds: 1)), DateTime(2026, 4, 16));
    });

    test('week → Monday 00:00 through end of Sunday', () {
      final (from, to) = homePeriodRange(HomePeriod.week, now: reference);
      expect(from, DateTime(2026, 4, 13));
      expect(to.add(const Duration(microseconds: 1)), DateTime(2026, 4, 20));
    });

    test('month → 1st of month through end of month', () {
      final (from, to) = homePeriodRange(HomePeriod.month, now: reference);
      expect(from, DateTime(2026, 4, 1));
      expect(to.add(const Duration(microseconds: 1)), DateTime(2026, 5, 1));
    });

    test('year → Jan 1 through end of December', () {
      final (from, to) = homePeriodRange(HomePeriod.year, now: reference);
      expect(from, DateTime(2026, 1, 1));
      expect(to.add(const Duration(microseconds: 1)), DateTime(2027, 1, 1));
    });
  });

  group('homePeriodLabel', () {
    final reference = DateTime(2026, 4, 15);

    test('returns human strings for each period', () {
      expect(homePeriodLabel(HomePeriod.day, now: reference), 'Today');
      expect(homePeriodLabel(HomePeriod.week, now: reference), 'This week');
      expect(homePeriodLabel(HomePeriod.month, now: reference), 'Apr 2026');
      expect(homePeriodLabel(HomePeriod.year, now: reference), '2026');
    });
  });

  group('effectiveDashboardPeriodProvider', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    ProviderContainer makeContainer() {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      return container;
    }

    test('returns user selection when periodSelector is enabled', () async {
      final container = makeContainer();
      // Wait for the home layout to resolve to defaults (which include
      // periodSelector = enabled).
      await container.read(homeLayoutProvider.future);
      container.read(dashboardPeriodProvider.notifier).state =
          HomePeriod.week;

      expect(
        container.read(effectiveDashboardPeriodProvider),
        HomePeriod.week,
      );
    });

    test(
      'falls back to month when the user has hidden the period selector',
      () async {
        final container = makeContainer();
        await container.read(homeLayoutProvider.future);
        container.read(dashboardPeriodProvider.notifier).state =
            HomePeriod.day;

        await container
            .read(homeLayoutProvider.notifier)
            .setEnabled(HomeSection.periodSelector, false);

        expect(
          container.read(effectiveDashboardPeriodProvider),
          HomePeriod.month,
        );
      },
    );
  });
}
