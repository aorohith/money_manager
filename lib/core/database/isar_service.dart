import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  IsarService._();

  static Isar? _instance;

  static Future<Isar> open(List<CollectionSchema<dynamic>> schemas) async {
    if (_instance != null && _instance!.isOpen) return _instance!;

    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      schemas,
      directory: dir.path,
      name: 'money_manager',
    );
    return _instance!;
  }

  static Isar get instance {
    assert(
      _instance != null && _instance!.isOpen,
      'IsarService.open() must be called before accessing instance.',
    );
    return _instance!;
  }
}

/// Provider that exposes the open [Isar] instance.
/// Must be overridden in main.dart after [IsarService.open] resolves.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'isarProvider must be overridden with the opened Isar instance.',
  );
});
