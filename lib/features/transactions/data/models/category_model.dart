import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:money_manager/core/utils/material_icon_resolver.dart';

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

  DateTime updatedAt = DateTime.now();
  String? userId;

  @ignore
  IconData get icon => MaterialIconResolver.fromCodePoint(iconCodePoint);

  @ignore
  Color get color => Color(colorValue);
}
