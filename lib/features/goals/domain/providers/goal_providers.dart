import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/isar_service.dart';
import '../../data/models/goal_model.dart';
import '../../data/repositories/goal_repository.dart';

// ── Repository ───────────────────────────────────────────────────────────────

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final isar = ref.read(isarProvider);
  return GoalRepositoryImpl(isar);
});

// ── Stream of all goals ──────────────────────────────────────────────────────

final goalListProvider = StreamProvider<List<GoalModel>>((ref) {
  final repo = ref.read(goalRepositoryProvider);
  return repo.watchAll();
});

// ── Single goal by ID ────────────────────────────────────────────────────────

final goalDetailProvider =
    FutureProvider.family<GoalModel?, int>((ref, id) {
  final repo = ref.read(goalRepositoryProvider);
  return repo.getById(id);
});

// ── Use cases ────────────────────────────────────────────────────────────────

final addGoalUseCaseProvider = Provider<Future<int> Function(GoalModel)>((ref) {
  final repo = ref.read(goalRepositoryProvider);
  return (goal) => repo.add(goal);
});

final updateGoalUseCaseProvider =
    Provider<Future<void> Function(GoalModel)>((ref) {
  final repo = ref.read(goalRepositoryProvider);
  return (goal) => repo.update(goal);
});

final deleteGoalUseCaseProvider =
    Provider<Future<void> Function(int)>((ref) {
  final repo = ref.read(goalRepositoryProvider);
  return (id) => repo.delete(id);
});

final addContributionUseCaseProvider =
    Provider<Future<void> Function(int, double)>((ref) {
  final repo = ref.read(goalRepositoryProvider);
  return (goalId, amount) => repo.addContribution(goalId, amount);
});
