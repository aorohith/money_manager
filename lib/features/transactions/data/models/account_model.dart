import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'account_model.g.dart';

@collection
class AccountModel {
  AccountModel({
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    this.initialBalance = 0.0,
    this.actualBalance,
    this.isDefault = false,
  });

  Id id = Isar.autoIncrement;

  late String name;
  late int iconCodePoint;
  late int colorValue;
  late double initialBalance;
  double? actualBalance;
  late bool isDefault;

  DateTime updatedAt = DateTime.now();
  String? userId;

  @ignore
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  @ignore
  Color get color => Color(colorValue);
}
