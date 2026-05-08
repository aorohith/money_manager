import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

/// Singleton wrapper around the Isar database.
///
/// Lifecycle:
/// 1. Call [IsarService.open] once at app startup (typically in `main.dart`)
///    before any repository or provider accesses the database.
/// 2. Override [isarProvider] with the returned [Isar] instance so that all
///    Riverpod consumers can read it via `ref.read(isarProvider)`.
class IsarService {
  IsarService._();

  static Isar? _instance;

  /// Opens (or returns the already-open) Isar database with the given schemas.
  ///
  /// Idempotent: safe to call multiple times; a second call returns the
  /// existing open instance without reopening.
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

  /// Returns the open [Isar] instance.
  ///
  /// Throws a [StateError] — not an assert — so the guard is enforced in
  /// **both** debug and release builds. Asserts are stripped by the compiler
  /// in release mode, which would silently produce a null-dereference crash
  /// instead of a clear error message.
  static Isar get instance {
    if (_instance == null || !_instance!.isOpen) {
      throw StateError(
        'IsarService.open() must be called before accessing instance.',
      );
    }
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
