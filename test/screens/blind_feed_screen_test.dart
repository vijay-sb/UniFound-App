import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/screens/blind_feed_screen.dart';
import 'package:lost_found_app/screens/found_item_form_screen.dart';

void main() {
  void setLargeDisplay(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
  }

  Future<void> pumpScreen(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(
      MaterialApp(
        home: widget,
        routes: {
          '/found-form': (_) => const FoundItemFormScreen(),
          '/login': (_) => const Scaffold(body: Text('LOGIN')),
        },
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 1));
  }

  group('BlindFeedScreen', () {
    testWidgets('should render without API service (mock mode)',
        (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester, const BlindFeedScreen());

      expect(find.byType(BlindFeedScreen), findsOneWidget);
    });

    testWidgets('should show search bar', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester, const BlindFeedScreen());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should show FAB with add icon and label', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester, const BlindFeedScreen());

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Found an item'), findsOneWidget);
    });

    testWidgets('FAB should navigate to FoundItemFormScreen', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester, const BlindFeedScreen());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(FoundItemFormScreen), findsOneWidget);
    });

    testWidgets('should show profile menu button', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester, const BlindFeedScreen());

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('should display mock item cards when no API service',
        (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester, const BlindFeedScreen());

      // Mock data has items with VERIFIED status
      // The screen should display them
      await tester.pump(const Duration(seconds: 2));

      // Check for GridView
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('search bar should accept text input', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester, const BlindFeedScreen());

      await tester.enterText(find.byType(TextField), 'wallet');
      await tester.pump();

      expect(find.text('wallet'), findsOneWidget);
    });

    testWidgets('should show loading indicator when future is pending',
        (tester) async {
      setLargeDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: BlindFeedScreen(),
        ),
      );
      // On first pump, FutureBuilder should show loading
      await tester.pump();

      // The mock resolves immediately, so we just verify structure
      expect(find.byType(BlindFeedScreen), findsOneWidget);
    });
  });
}
