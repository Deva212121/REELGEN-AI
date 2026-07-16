import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reelgen_ai/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('REELGEN AI — Integration Tests', () {
    testWidgets('App launches successfully', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check if app launched
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Login screen has REELGEN AI text', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('REELGEN AI'), findsOneWidget);
    });

    testWidgets('Login screen has SIGN IN button', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('SIGN IN'), findsOneWidget);
    });
  });
}