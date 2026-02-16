import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/widgets/handover_alert.dart';

void main() {
  group('HandoverAlert Widget', () {
    Future<void> pumpHandoverAlert(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/home': (_) => const Scaffold(body: Text('HOME')),
          },
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const HandoverAlert(),
                  ),
                  child: const Text('Show Alert'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap to show the dialog
      await tester.tap(find.text('Show Alert'));
      await tester.pumpAndSettle();
    }

    testWidgets('should display title', (tester) async {
      await pumpHandoverAlert(tester);
      expect(find.text('HANDOVER INSTRUCTIONS'), findsOneWidget);
    });

    testWidgets('should display instruction text', (tester) async {
      await pumpHandoverAlert(tester);
      expect(
        find.textContaining('Please hand over the found item'),
        findsOneWidget,
      );
    });

    testWidgets('should display admin rows for each zone', (tester) async {
      await pumpHandoverAlert(tester);

      expect(find.textContaining('Hostel'), findsAtLeastNWidgets(1));
      expect(find.textContaining('AB1'), findsOneWidget);
      expect(find.textContaining('AB3'), findsOneWidget);
      expect(find.textContaining('Library'), findsOneWidget);
      expect(find.textContaining('Grounds'), findsOneWidget);
    });

    testWidgets('should display admin names', (tester) async {
      await pumpHandoverAlert(tester);

      expect(find.textContaining('Respective Wardens'), findsOneWidget);
      expect(find.textContaining('Student Welfare Office'), findsOneWidget);
      expect(find.textContaining('CSE Dept. Office'), findsOneWidget);
      expect(find.textContaining('Librarian'), findsOneWidget);
      expect(find.textContaining('Physical Education Dept.'), findsOneWidget);
    });

    testWidgets('should display UNDERSTOOD button', (tester) async {
      await pumpHandoverAlert(tester);
      expect(find.text('UNDERSTOOD'), findsOneWidget);
    });

    testWidgets('should display note text', (tester) async {
      await pumpHandoverAlert(tester);
      expect(
        find.textContaining('Note:'),
        findsOneWidget,
      );
    });

    testWidgets('UNDERSTOOD button should navigate to /home', (tester) async {
      await pumpHandoverAlert(tester);

      await tester.tap(find.text('UNDERSTOOD'));
      await tester.pumpAndSettle();

      // Should navigate to /home
      expect(find.text('HOME'), findsOneWidget);
    });
  });
}
