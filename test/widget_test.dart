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
          "/found-form": (_) => const FoundItemFormScreen(),
        },
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 1));
  }

  group('UniFound Tests', () {
    testWidgets('App should reach BlindFeedScreen', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester, const BlindFeedScreen());

      expect(find.byType(BlindFeedScreen), findsOneWidget);
    });

    testWidgets('FAB opens form screen', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester, const BlindFeedScreen());

      final fab = find.byIcon(Icons.add);
      expect(fab, findsOneWidget);

      await tester.tap(fab);

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(FoundItemFormScreen), findsOneWidget);
    });

    testWidgets('Form validation shows errors', (tester) async {
      setLargeDisplay(tester);
      await pumpScreen(tester, const FoundItemFormScreen());

      final submit = find.textContaining("SUBMIT");
      expect(submit, findsOneWidget);

      await tester.tap(submit);
      await tester.pump();

      expect(find.text("Required"), findsAtLeastNWidgets(1));
    });
  });
}
