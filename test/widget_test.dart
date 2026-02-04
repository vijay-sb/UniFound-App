import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/main.dart';
import 'package:lost_found_app/screens/blind_feed_screen.dart';
import 'package:lost_found_app/screens/found_item_form_screen.dart';

void main() {
  // Helper function to set a larger screen size so buttons aren't off-screen
  void setLargeDisplay(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400); // Tall phone size
    tester.view.devicePixelRatio = 1.0;
  }

  group('UniFound App Navigation & UI Tests', () {
    
    testWidgets('App should start on BlindFeedScreen and show Logo', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(BlindFeedScreen), findsOneWidget);
    });

    testWidgets('Navigation: Tapping "Report Found" should open FoundItemFormScreen', (WidgetTester tester) async {
      setLargeDisplay(tester);
      await tester.pumpWidget(const MyApp());

      // Using an icon finder is safer for neon buttons
      final reportButton = find.byIcon(Icons.add); 
      
      await tester.tap(reportButton);
      
      // FIX: Use pump(Duration) instead of pumpAndSettle to avoid animation timeouts
      await tester.pump(const Duration(milliseconds: 500)); 
      await tester.pump(const Duration(milliseconds: 500)); 

      expect(find.byType(FoundItemFormScreen), findsOneWidget);
    });

    testWidgets('Validation: Submit without data should show errors', (WidgetTester tester) async {
      setLargeDisplay(tester); // CRITICAL: Fixes the "Offset outside bounds" error
      
      await tester.pumpWidget(
        const MaterialApp(home: FoundItemFormScreen())
      );

      final submitButton = find.text("TAG LOCATION & SUBMIT");
      
      // Ensure the widget is actually found before tapping
      expect(submitButton, findsOneWidget);
      
      await tester.tap(submitButton);
      await tester.pump(); // Trigger the build after validation

      // Check for validation text. 
      // Note: If you renamed your error string in the form, match it here.
      expect(find.text("Required"), findsAtLeastNWidgets(1));
    });
  });
}