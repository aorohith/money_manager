import 'package:isar/isar.dart';

import '../models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getAll();
  Future<CategoryModel?> getById(int id);
  Future<int> add(CategoryModel category);
  Future<void> update(CategoryModel category);
  Future<void> delete(int id);
  Stream<List<CategoryModel>> watchAll();
}

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._isar);
  final Isar _isar;

  @override
  Future<List<CategoryModel>> getAll() =>
      _isar.categoryModels.where().findAll();

  @override
  Future<CategoryModel?> getById(int id) =>
      _isar.categoryModels.get(id);

  @override
  Future<int> add(CategoryModel category) async {
    int id = 0;
    await _isar.writeTxn(() async {
      id = await _isar.categoryModels.put(category);
    });
    return id;
  }

  @override
  Future<void> update(CategoryModel category) async {
    await _isar.writeTxn(() async => _isar.categoryModels.put(category));
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() async => _isar.categoryModels.delete(id));
  }

  @override
  Stream<List<CategoryModel>> watchAll() =>
      _isar.categoryModels.where().watch(fireImmediately: true);
}
