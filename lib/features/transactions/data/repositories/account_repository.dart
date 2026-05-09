import 'package:isar/isar.dart';

import '../models/account_model.dart';

abstract class AccountRepository {
  Stream<List<AccountModel>> watchAll();
  Future<List<AccountModel>> getAll();
  Future<AccountModel?> getById(int id);
  Future<int> add(AccountModel account);
  Future<void> update(AccountModel account);
  Future<void> delete(int id);
}

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._isar);
  final Isar _isar;

  @override
  Stream<List<AccountModel>> watchAll() =>
      _isar.accountModels.where().watch(fireImmediately: true);

  @override
  Future<List<AccountModel>> getAll() =>
      _isar.accountModels.where().findAll();

  @override
  Future<AccountModel?> getById(int id) =>
      _isar.accountModels.get(id);

  @override
  Future<int> add(AccountModel account) async {
    account.updatedAt = DateTime.now();
    return _isar.writeTxn(() => _isar.accountModels.put(account));
  }

  @override
  Future<void> update(AccountModel account) {
    account.updatedAt = DateTime.now();
    return _isar.writeTxn(() => _isar.accountModels.put(account));
  }

  @override
  Future<void> delete(int id) =>
      _isar.writeTxn(() => _isar.accountModels.delete(id));
}
