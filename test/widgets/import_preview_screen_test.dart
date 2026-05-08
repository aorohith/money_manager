import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/import/data/models/import_preview_row.dart';
import 'package:money_manager/features/import/data/models/import_row.dart';
import 'package:money_manager/features/import/data/models/import_session.dart';
import 'package:money_manager/features/import/data/services/import_service.dart';
import 'package:money_manager/features/import/domain/providers/import_providers.dart';
import 'package:money_manager/features/import/domain/usecases/import_transactions_usecase.dart';
import 'package:money_manager/features/import/presentation/screens/import_preview_screen.dart';

import '../helpers/pump_app.dart';

class _MockImportService extends Mock implements ImportService {}

class _MockImportUseCase extends Mock implements ImportTransactionsUseCase {}

class _TestImportController extends ImportController {
  _TestImportController()
    : super(service: _MockImportService(), importUseCase: _MockImportUseCase());

  void seed(ImportFlowState value) {
    state = value;
  }
}

void main() {
  testWidgets('duplicate row toggle changes selected count', (tester) async {
    final row = ExpenseImportRow(
      rowNumber: 2,
      date: DateTime(2026, 5, 8),
      categoryName: 'Food',
      accountName: 'Main',
      amount: 100,
      currencyCode: 'INR',
    );
    final controller = _TestImportController()
      ..seed(
        ImportFlowState(
          session: ImportSession(
            batchId: 'batch_1',
            filePath: 'sample.xlsx',
            format: ImportFormat.excel,
            rows: [row],
          ),
          previewRows: [
            ImportPreviewRow(
              row: row,
              status: ImportPreviewStatus.duplicate,
              selected: false,
            ),
          ],
        ),
      );

    await tester.pumpApp(
      const ImportPreviewScreen(),
      overrides: [importControllerProvider.overrideWith((ref) => controller)],
    );

    expect(find.text('Import 0 rows'), findsOneWidget);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    expect(find.text('Import 1 rows'), findsOneWidget);
  });
}
