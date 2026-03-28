import 'package:isar/isar.dart';

part 'account_model.g.dart';

@collection
class AccountModel {
  AccountModel({
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    this.initialBalance = 0.0,
    this.isDefault = false,
  });

  Id id = Isar.autoIncrement;

  late String name;
  late int iconCodePoint;
  late int colorValue;
  late double initialBalance;
  late bool isDefault;
}
