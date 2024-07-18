import 'package:get_storage/get_storage.dart';

class AppStorage {
  // ignore: prefer_function_declarations_over_variables
  final storageBox = () => GetStorage(StorageKey.kAppStorageKey);

  Future<void> initStorage() async {
    await GetStorage.init(StorageKey.kAppStorageKey);
  }

  Future<void> appLogout() async {
    await storageBox().remove(StorageKey.kAppStorageKey);

    return;
  }

  dynamic read(String key) {
    return storageBox().read(key);
  }

  Future<void> _write(String key, value) async {
    return await storageBox().write(key, value);
  }

  bool getBool(String key) {
    return read(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _write(key, value);
    return;
  }

  Future<void> setInt(String key, int value) async {
    await _write(key, value);
    return;
  }

  Future<void> setString(String key, String value) async {
    await _write(key, value);
    return;
  }
}

class StorageKey {
  static const String kAppStorageKey = 'AppStorageKey';
}
