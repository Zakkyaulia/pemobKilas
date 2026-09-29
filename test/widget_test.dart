// Basic smoke test for the KILAS app.

import 'package:flutter_test/flutter_test.dart';

import 'package:pemob_kilas/main.dart';

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    // Build the KILAS app and trigger a frame.
    await tester.pumpWidget(const KilasApp());

    // Verify that the KILAS heading is displayed.
    expect(find.text('KILAS'), findsOneWidget);

    // Verify that the login button is displayed.
    expect(find.text('Masuk saja'), findsOneWidget);

    // Verify that the method toggle options are displayed.
    expect(find.text('Email'), findsNWidgets(2));
    expect(find.text('NIM'), findsOneWidget);
  });
}
