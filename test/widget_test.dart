import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/core/database/isar_service.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    final isar = await IsarService.open(<CollectionSchema<dynamic>>[]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [isarProvider.overrideWithValue(isar)],
        child: const App(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
