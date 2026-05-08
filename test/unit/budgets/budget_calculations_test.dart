import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/budgets/data/models/budget_model.dart';
import 'package:money_manager/features/budgets/data/repositories/budget_repository.dart';
import 'package:money_manager/features/budgets/domain/usecases/budget_usecases.dart';

// Helper to build a BudgetProgress with a given scenario
BudgetProgress makeProgress({
  double limit = 500,
  double rollover = 0,
  double spent = 0,
  int daysInPeriod = 30,
  int daysElapsed = 15,
  int? categoryId,
}) {
  final budget = BudgetModel(
    limitAmount: limit,
    period: BudgetPeriod.monthly,
    month: 202503,
    categoryId: categoryId,
  )..rolloverAmount = rollover;

  return BudgetProgress(
    budget: budget,
    spent: spent,
    daysInPeriod: daysInPeriod,
    daysElapsed: daysElapsed,
  );
}

void main() {
  group('BudgetProgress — effectiveLimit', () {
    test('no rollover: effectiveLimit == limitAmount', () {
      final p = makeProgress(limit: 500, rollover: 0);
      expect(p.effectiveLimit, 500);
    });

    test('with rollover: effectiveLimit == limitAmount + rolloverAmount', () {
      final p = makeProgress(limit: 500, rollover: 100);
      expect(p.effectiveLimit, 600);
    });

    test('zero rollover does not change limit', () {
      final p = makeProgress(limit: 200, rollover: 0);
      expect(p.effectiveLimit, 200);
    });
  });

  group('BudgetProgress — remaining & isOver', () {
    test('remaining = effectiveLimit - spent (positive)', () {
      final p = makeProgress(limit: 500, spent: 300);
      expect(p.remaining, closeTo(200, 0.001));
      expect(p.isOver, isFalse);
    });

    test('remaining is negative when over budget', () {
      final p = makeProgress(limit: 500, spent: 550);
      expect(p.remaining, closeTo(-50, 0.001));
      expect(p.isOver, isTrue);
    });

    test('remaining is zero at exact limit', () {
      final p = makeProgress(limit: 500, spent: 500);
      expect(p.remaining, 0);
      expect(p.isOver, isFalse);
    });

    test('rollover extends remaining', () {
      // $500 budget + $100 rollover = $600 effective; spent $550
      final p = makeProgress(limit: 500, rollover: 100, spent: 550);
      expect(p.remaining, closeTo(50, 0.001));
      expect(p.isOver, isFalse);
    });
  });

  group('BudgetProgress — percentage', () {
    test('50% when half spent', () {
      final p = makeProgress(limit: 500, spent: 250);
      expect(p.percentage, closeTo(0.5, 0.001));
    });

    test('0% when nothing spent', () {
      final p = makeProgress(limit: 500, spent: 0);
      expect(p.percentage, 0);
    });

    test('100% when exactly at limit', () {
      final p = makeProgress(limit: 500, spent: 500);
      expect(p.percentage, closeTo(1.0, 0.001));
    });

    test('over 100% possible (> 1.0)', () {
      final p = makeProgress(limit: 500, spent: 600);
      expect(p.percentage, closeTo(1.2, 0.001));
    });

    test('percentage is 0 when effectiveLimit is 0', () {
      final p = makeProgress(limit: 0, rollover: 0, spent: 0);
      expect(p.percentage, 0);
    });
  });

  group('BudgetProgress — colorState', () {
    test('< 50% → onTrack', () {
      final p = makeProgress(limit: 500, spent: 200); // 40%
      expect(p.colorState, BudgetColorState.onTrack);
    });

    test('50% exactly → moderate', () {
      final p = makeProgress(limit: 500, spent: 250); // 50%
      expect(p.colorState, BudgetColorState.moderate);
    });

    test('75% → moderate', () {
      final p = makeProgress(limit: 500, spent: 375); // 75%
      expect(p.colorState, BudgetColorState.moderate);
    });

    test('80% exactly → runningLow', () {
      final p = makeProgress(limit: 500, spent: 400); // 80%
      expect(p.colorState, BudgetColorState.runningLow);
    });

    test('95% → runningLow', () {
      final p = makeProgress(limit: 500, spent: 475); // 95%
      expect(p.colorState, BudgetColorState.runningLow);
    });

    test('100% exactly → runningLow (isOver requires strict > limit)', () {
      final p = makeProgress(limit: 500, spent: 500); // 100%
      expect(p.colorState, BudgetColorState.runningLow);
    });

    test('110% → over', () {
      final p = makeProgress(limit: 500, spent: 550); // 110%
      expect(p.colorState, BudgetColorState.over);
    });
  });

  group('BudgetProgress — dailyAllowance', () {
    test('remaining spread over days left', () {
      // $500 limit, $200 spent → $300 remaining; day 15 of 30 → 15 days left
      final p = makeProgress(
        limit: 500,
        spent: 200,
        daysInPeriod: 30,
        daysElapsed: 15,
      );
      // 300 / 15 = 20
      expect(p.dailyAllowance, closeTo(20.0, 0.001));
    });

    test('0 when no days left', () {
      final p = makeProgress(
        limit: 500,
        spent: 200,
        daysInPeriod: 30,
        daysElapsed: 30,
      );
      expect(p.dailyAllowance, 0);
    });

    test('negative when over budget with days remaining', () {
      // $500 limit, $600 spent → -$100 remaining; 15 days left
      final p = makeProgress(
        limit: 500,
        spent: 600,
        daysInPeriod: 30,
        daysElapsed: 15,
      );
      expect(p.dailyAllowance, closeTo(-100 / 15, 0.001));
    });

    test('full remaining when day 0', () {
      // day 1 of 30 elapsed, full remaining
      final p = makeProgress(
        limit: 600,
        spent: 0,
        daysInPeriod: 30,
        daysElapsed: 1,
      );
      // 600 / 29 ≈ 20.69
      expect(p.dailyAllowance, closeTo(600 / 29, 0.01));
    });
  });

  group('BudgetProgress — projectedMonthEnd', () {
    test('linear projection: 0 elapsed → 0', () {
      final p = makeProgress(
        limit: 500,
        spent: 300,
        daysInPeriod: 30,
        daysElapsed: 0,
      );
      expect(p.projectedMonthEnd, 0);
    });

    test('linear projection mid-month', () {
      // $300 spent in 15 days → $300/15 * 30 = $600 projected
      final p = makeProgress(
        limit: 500,
        spent: 300,
        daysInPeriod: 30,
        daysElapsed: 15,
      );
      expect(p.projectedMonthEnd, closeTo(600, 0.001));
    });

    test('on-track projection equals limit when exactly paced', () {
      // $250 spent in 15 days → $250/15 * 30 = $500 (matches limit)
      final p = makeProgress(
        limit: 500,
        spent: 250,
        daysInPeriod: 30,
        daysElapsed: 15,
      );
      expect(p.projectedMonthEnd, closeTo(500, 0.001));
    });

    test('end of month: projected equals spent', () {
      final p = makeProgress(
        limit: 500,
        spent: 450,
        daysInPeriod: 30,
        daysElapsed: 30,
      );
      expect(p.projectedMonthEnd, closeTo(450, 0.001));
    });
  });

  group('BudgetProgress — statusLabel', () {
    test('on track label', () {
      final p = makeProgress(limit: 500, spent: 100); // 20%
      expect(p.statusLabel, contains('On track'));
    });

    test('moderate spend label', () {
      final p = makeProgress(limit: 500, spent: 300); // 60%
      expect(p.statusLabel, contains('Moderate'));
    });

    test('running low label', () {
      final p = makeProgress(limit: 500, spent: 420); // 84%
      expect(p.statusLabel, contains('Running low'));
    });

    test('over budget shows amount', () {
      final p = makeProgress(limit: 500, spent: 600); // $100 over
      expect(p.statusLabel, contains('Over by'));
      expect(p.statusLabel, contains('100'));
    });
  });

  group('computeRollover', () {
    test('positive unspent carries over', () {
      expect(computeRollover(previousLimit: 500, previousSpent: 400), 100);
    });

    test('no rollover when overspent', () {
      expect(computeRollover(previousLimit: 500, previousSpent: 600), 0);
    });

    test('no rollover when exactly at limit', () {
      expect(computeRollover(previousLimit: 500, previousSpent: 500), 0);
    });

    test('full rollover when nothing spent', () {
      expect(computeRollover(previousLimit: 300, previousSpent: 0), 300);
    });
  });

  group('Edge cases', () {
    test('zero budget, zero spend: no division errors', () {
      final p = makeProgress(limit: 0, rollover: 0, spent: 0);
      expect(p.percentage, 0);
      expect(p.remaining, 0);
      expect(p.isOver, isFalse);
    });

    test('category budget uses categoryId', () {
      final p = makeProgress(limit: 200, spent: 50, categoryId: 7);
      expect(p.budget.categoryId, 7);
      expect(p.percentage, closeTo(0.25, 0.001));
    });

    test('overall budget has null categoryId', () {
      final p = makeProgress(limit: 1000, spent: 500);
      expect(p.budget.categoryId, isNull);
    });

    test('large values do not overflow', () {
      final p = makeProgress(limit: 1000000, spent: 999999);
      expect(p.remaining, closeTo(1, 0.001));
      expect(p.percentage, closeTo(0.999999, 0.000001));
    });
  });
}
