import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/screens/found_item_form_screen.dart';

void main() {
  void setLargeDisplay(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const FoundItemFormScreen(),
        routes: {
          '/home': (_) => const Scaffold(body: Text('HOME')),
        },
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 1));
  }

  group('FoundItemFormScreen', () {
    testWidgets('should render the form screen', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester);

      expect(find.byType(FoundItemFormScreen), findsOneWidget);
    });

    testWidgets('should display REPORT FOUND ITEM header', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester);

      expect(find.text('REPORT FOUND ITEM'), findsOneWidget);
    });

    testWidgets('should show image upload area', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester);

      expect(find.text('UPLOAD IMAGE'), findsOneWidget);
      expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);
    });

    testWidgets('should show category dropdown', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester);

      expect(find.text('Select Category'), findsOneWidget);
      expect(find.byIcon(Icons.category_outlined), findsOneWidget);
    });

    testWidgets('should show location dropdown', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester);

      expect(find.text('Select Location'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    });

    testWidgets('should show date/time picker', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester);

      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('should show submit button', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester);

      expect(find.textContaining('SUBMIT'), findsOneWidget);
    });

    testWidgets('form validation should show errors on empty submit',
        (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester);

      // Tap submit without filling form
      final submitButton = find.textContaining('SUBMIT');
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Should show validation errors or snackbar
      expect(
        find.byType(SnackBar).evaluate().isNotEmpty ||
            find.text('Required').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should display category options in dropdown', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester);

      // Tap category dropdown to open
      await tester.tap(find.text('Select Category'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Check for some category options
      expect(find.text('Wallet'), findsAtLeastNWidgets(1));
      expect(find.text('ID Card'), findsAtLeastNWidgets(1));
      expect(find.text('Keys'), findsAtLeastNWidgets(1));
      expect(find.text('Others'), findsAtLeastNWidgets(1));
    });
  });
}
