import 'package:flutter_test/flutter_test.dart';
// Ensure this matches your pubspec.yaml name
import 'package:lost_found_app/main.dart'; 

void main() {
  testWidgets('App loads and shows login screen', (WidgetTester tester) async {
    // 1. Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // This tells Flutter to keep ticking the clock until all timers are done
    await tester.pumpAndSettle();

    // 2. Look for the Sign In button text instead of the header.
    // Since your UI now uses a logo image, we check for the button text.
    expect(find.text('Sign In'), findsOneWidget);

    // 3. Optional: Verify the email field label exists
    expect(find.text('University Email'), findsOneWidget);
  });
}