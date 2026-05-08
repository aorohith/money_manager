import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_factories.dart';

void main() {
  group('GoalModel.progress', () {
    test('0 current → 0.0 progress', () {
      final goal = makeGoal(targetAmount: 1000, currentAmount: 0);
      expect(goal.progress, 0.0);
    });

    test('half saved → 0.5 progress', () {
      final goal = makeGoal(targetAmount: 1000, currentAmount: 500);
      expect(goal.progress, 0.5);
    });

    test('fully saved → 1.0 progress (clamped at 1)', () {
      final goal = makeGoal(targetAmount: 1000, currentAmount: 1000);
      expect(goal.progress, 1.0);
    });

    test('over-saved → clamped to 1.0', () {
      final goal = makeGoal(targetAmount: 1000, currentAmount: 1500);
      expect(goal.progress, 1.0);
    });

    test('zero target → 0.0 (no divide-by-zero)', () {
      final goal = makeGoal(targetAmount: 0, currentAmount: 500);
      expect(goal.progress, 0.0);
    });

    test(
      'negative current → 0.0 (clamped via remaining, progress rounds down)',
      () {
        // progress = (-100/1000).clamp(0,1) = 0
        final goal = makeGoal(targetAmount: 1000, currentAmount: -100);
        expect(goal.progress, 0.0);
      },
    );
  });

  group('GoalModel.remaining', () {
    test('0 saved → remaining equals target', () {
      final goal = makeGoal(targetAmount: 1000, currentAmount: 0);
      expect(goal.remaining, 1000.0);
    });

    test('partial saved → correct remaining', () {
      final goal = makeGoal(targetAmount: 1000, currentAmount: 300);
      expect(goal.remaining, 700.0);
    });

    test('fully saved → remaining is 0', () {
      final goal = makeGoal(targetAmount: 1000, currentAmount: 1000);
      expect(goal.remaining, 0.0);
    });

    test('over-saved → remaining clamped to 0', () {
      final goal = makeGoal(targetAmount: 1000, currentAmount: 1200);
      expect(goal.remaining, 0.0);
    });
  });

  group('GoalModel fields', () {
    test('isCompleted defaults to false', () {
      final goal = makeGoal();
      expect(goal.isCompleted, isFalse);
    });

    test('deadline is optional (null by default)', () {
      final goal = makeGoal();
      expect(goal.deadline, isNull);
    });

    test('notes is optional', () {
      final goal = makeGoal();
      expect(goal.notes, isNull);
    });

    test('notes can be set', () {
      final goal = makeGoal(notes: 'For vacation');
      expect(goal.notes, 'For vacation');
    });

    test('deadline can be set', () {
      final deadline = DateTime(2025, 12, 31);
      final goal = makeGoal(deadline: deadline);
      expect(goal.deadline, deadline);
    });

    test('large target amount is preserved', () {
      final goal = makeGoal(targetAmount: 999999.99);
      expect(goal.targetAmount, 999999.99);
    });

    test('progress with fractional values is accurate', () {
      final goal = makeGoal(targetAmount: 3, currentAmount: 1);
      expect(goal.progress, closeTo(0.333, 0.001));
    });
  });
}
