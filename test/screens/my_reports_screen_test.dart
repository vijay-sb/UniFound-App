import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/screens/my_reports_screen.dart';

void main() {
  void setLargeDisplay(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MyReportsScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 1));
  }

  group('MyReportsScreen', () {
    testWidgets('should render without API service (mock mode)',
        (tester) async {
      setLargeDisplay(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await pumpScreen(tester);

      expect(find.byType(MyReportsScreen), findsOneWidget);
    });

    testWidgets('should display MY REPORTS title', (tester) async {
      setLargeDisplay(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await pumpScreen(tester);

      expect(find.text('MY REPORTS'), findsOneWidget);
    });

    testWidgets('should show search bar', (tester) async {
      setLargeDisplay(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await pumpScreen(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should show back button', (tester) async {
      setLargeDisplay(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await pumpScreen(tester);

      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('should show mock report cards in mock mode', (tester) async {
      setLargeDisplay(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await pumpScreen(tester);

      // Mock data has one item with category 'Keys'
      await tester.pump(const Duration(seconds: 2));

      expect(find.textContaining('KEYS'), findsOneWidget);
    });

    testWidgets('should show REPORTED status tag', (tester) async {
      setLargeDisplay(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await pumpScreen(tester);

      await tester.pump(const Duration(seconds: 2));

      expect(find.text('REPORTED'), findsOneWidget);
    });

    testWidgets('should show location info', (tester) async {
      setLargeDisplay(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await pumpScreen(tester);

      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Admin Block'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsAtLeastNWidgets(1));
    });

    testWidgets('should show date info', (tester) async {
      setLargeDisplay(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await pumpScreen(tester);

      await tester.pump(const Duration(seconds: 2));

      expect(find.textContaining('Reported on:'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsAtLeastNWidgets(1));
    });

    testWidgets('search bar should filter results', (tester) async {
      setLargeDisplay(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await pumpScreen(tester);

      await tester.pump(const Duration(seconds: 2));

      // Enter search query that doesn't match
      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.pump(const Duration(seconds: 1));

      // Should show empty state
      expect(find.textContaining('haven\'t reported'), findsOneWidget);
    });

    testWidgets('search should find matching items', (tester) async {
      setLargeDisplay(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await pumpScreen(tester);

      await tester.pump(const Duration(seconds: 2));

      // Search for 'keys' which matches the mock data
      await tester.enterText(find.byType(TextField), 'keys');
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('KEYS'), findsOneWidget);
    });
  });
}
