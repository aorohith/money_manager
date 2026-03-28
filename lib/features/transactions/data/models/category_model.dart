import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  CategoryModel({
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.isIncome,
    this.isDefault = false,
  });

  Id id = Isar.autoIncrement;

  late String name;
  late int iconCodePoint;
  late int colorValue;
  late bool isIncome;
  late bool isDefault;

  @ignore
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  @ignore
  Color get color => Color(colorValue);
}
