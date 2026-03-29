import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Sprint 1: no data models yet — Isar schemas are added in Sprint 3.
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
