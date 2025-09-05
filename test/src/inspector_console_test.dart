import 'package:digia_inspector/digia_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InspectorConsole', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      final controller = InspectorController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorConsole(
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Inspect'), findsOneWidget);
    });

    testWidgets('shows correct tabs', (WidgetTester tester) async {
      final controller = InspectorController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorConsole(
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Network'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);
      expect(find.text('State'), findsOneWidget);
    });

    testWidgets('shows clear logs button', (WidgetTester tester) async {
      final controller = InspectorController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorConsole(
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear_all), findsOneWidget);
    });
  });
}
