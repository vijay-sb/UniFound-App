// import 'package:flutter_test/flutter_test.dart';
// // Ensure this matches your pubspec.yaml name
// import 'package:lost_found_app/main.dart';

// void main() {
//   testWidgets('App loads and shows login screen', (WidgetTester tester) async {
//     // 1. Build our app and trigger a frame.
//     await tester.pumpWidget(const MyApp());

//     // This handles the Intro Scan without timing out on the Pulse animation.
//     await tester.pump(const Duration(seconds: 5));

//     // 2. Look for the Sign In button text instead of the header.
//     // Since your UI now uses a logo image, we check for the button text.
//     expect(find.text('Sign In'), findsOneWidget);

//     // 3. Optional: Verify the email field label exists
//     expect(find.text('University Email'), findsOneWidget);
//   });

// }

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// CHANGE THESE to match your actual project name and paths
import 'package:lost_found_app/screens/blind_feed_screen.dart';

void main() {
  testWidgets('BlindFeedScreen UI and Search Test',
      (WidgetTester tester) async {
    // Build the widget (Passing null to apiService triggers Mock Data)
    await tester.pumpWidget(const MaterialApp(
      home: BlindFeedScreen(apiService: null),
    ));

    // 1. Verify Logo exists (Check for an Image widget)
    expect(find.byType(Image), findsWidgets);

    // 2. Verify Profile/Logout button exists
    expect(find.byIcon(Icons.person_outline), findsOneWidget);

    // 3. Verify Mock Data items are rendered
    // Note: Items are displayed in Uppercase in my code, so we search for 'WALLET'
    expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));

    final itemFinder = find.byWidgetPredicate(
      (widget) => widget is Text && widget.data?.toUpperCase() == 'WALLET'
    );
    
    expect(itemFinder, findsOneWidget);

    // 5. Test Search Functionality
    await tester.enterText(find.byType(TextField), 'Library');

    // Trigger the setState and the subsequent rebuild
    await tester.pumpAndSettle();

    // 'Wallet' is in 'Main Canteen', so it should be gone.
    // 'ID Card' is in 'Library', so it should remain.
    expect(find.text('WALLET'), findsNothing);
    expect(find.text('ID CARD'), findsOneWidget);

    // 6. Verify Button
    expect(find.text('I LOST THIS'), findsAtLeastNWidgets(1));
  });
}
