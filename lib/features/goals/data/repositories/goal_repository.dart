import 'package:isar/isar.dart';

import '../models/goal_model.dart';

abstract class GoalRepository {
  Stream<List<GoalModel>> watchAll();
  Future<List<GoalModel>> getAll();
  Future<GoalModel?> getById(int id);
  Future<int> add(GoalModel goal);
  Future<void> update(GoalModel goal);
  Future<void> delete(int id);
  Future<void> addContribution(int goalId, double amount);
}

class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._isar);
  final Isar _isar;

  @override
  Stream<List<GoalModel>> watchAll() {
    return _isar.goalModels
        .where()
        .watch(fireImmediately: true)
        .map((goals) {
      goals.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });
      return goals;
    });
  }

  @override
  Future<List<GoalModel>> getAll() =>
      _isar.goalModels.where().findAll();

  @override
  Future<GoalModel?> getById(int id) =>
      _isar.goalModels.get(id);

  @override
  Future<int> add(GoalModel goal) {
    goal.updatedAt = DateTime.now();
    return _isar.writeTxn(() => _isar.goalModels.put(goal));
  }

  @override
  Future<void> update(GoalModel goal) {
    goal.updatedAt = DateTime.now();
    return _isar.writeTxn(() => _isar.goalModels.put(goal));
  }

  @override
  Future<void> delete(int id) =>
      _isar.writeTxn(() => _isar.goalModels.delete(id));

  @override
  Future<void> addContribution(int goalId, double amount) async {
    await _isar.writeTxn(() async {
      final goal = await _isar.goalModels.get(goalId);
      if (goal == null) return;
      goal.currentAmount += amount;
      if (goal.currentAmount >= goal.targetAmount) {
        goal.isCompleted = true;
      }
      goal.updatedAt = DateTime.now();
      await _isar.goalModels.put(goal);
    });
  }
}
