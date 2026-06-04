import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/sms/presentation/widgets/sms_message_reference.dart';

import '../helpers/pump_app.dart';

void main() {
  const sampleMessage =
      'INR 250.50 debited via UPI to Swiggy on 10-05. Avl Bal INR 1200.00';

  testWidgets('expandable reference hides body until tapped', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        body: SmsMessageReference(
          rawText: sampleMessage,
          expandable: true,
          initiallyExpanded: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull,
        reason: 'initial render must not overflow');
    expect(find.text('Original message'), findsOneWidget);
    expect(find.byKey(const Key('sms_message_reference_body')), findsNothing);

    await tester.tap(find.text('Original message'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sms_message_reference_body')), findsOneWidget);
    expect(find.textContaining('debited via UPI'), findsOneWidget);
    expect(tester.takeException(), isNull,
        reason: 'expanded message must not overflow');
  });

  testWidgets('non-expandable reference shows full message', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        body: SmsMessageReference(
          rawText: sampleMessage,
          senderAddress: 'com.hdfc.bank',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('com.hdfc.bank'), findsOneWidget);
    expect(find.textContaining('debited via UPI'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty rawText renders nothing', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        body: SmsMessageReference(rawText: '   '),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Original message'), findsNothing);
  });
}
