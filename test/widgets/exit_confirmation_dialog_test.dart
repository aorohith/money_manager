import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/widgets/exit_confirmation_dialog.dart';

import '../helpers/pump_app.dart';

void main() {
  group('ExitConfirmationDialog', () {
    testWidgets('renders title, message, cancel and exit actions', (
      tester,
    ) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => ExitConfirmationDialog.show(context),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Exit Money Manager?'), findsOneWidget);
      expect(
        find.text("You'll be taken out of the app. Your data stays saved."),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Exit'), findsOneWidget);
    });

    testWidgets('Cancel resolves to false', (tester) async {
      bool? captured;
      await tester.pumpApp(
        Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                captured = await ExitConfirmationDialog.show(context);
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(captured, isFalse);
    });

    testWidgets('Exit resolves to true', (tester) async {
      bool? captured;
      await tester.pumpApp(
        Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                captured = await ExitConfirmationDialog.show(context);
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      expect(captured, isTrue);
    });

    testWidgets(
      'dismissing via barrier without choosing returns false',
      (tester) async {
        bool? captured;
        await tester.pumpApp(
          Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  captured = await ExitConfirmationDialog.show(context);
                },
                child: const Text('open'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        // Tap outside the dialog to dismiss via the modal barrier.
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(captured, isFalse);
      },
    );
  });
}
