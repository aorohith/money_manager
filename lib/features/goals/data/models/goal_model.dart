import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'goal_model.g.dart';

@collection
class GoalModel {
  GoalModel({
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.iconCodePoint = 0xe569, // savings icon
    this.colorValue = 0xFF0052FF,
    this.notes,
    this.isCompleted = false,
  });

  Id id = Isar.autoIncrement;

  late String name;
  late double targetAmount;
  late double currentAmount;
  DateTime? deadline;
  late int iconCodePoint;
  late int colorValue;
  String? notes;
  late bool isCompleted;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  String? userId;

  @ignore
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  @ignore
  Color get color => Color(colorValue);

  @ignore
  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;

  @ignore
  double get remaining => (targetAmount - currentAmount).clamp(0, double.infinity);
}
