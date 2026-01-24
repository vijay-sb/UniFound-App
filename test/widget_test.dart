// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('App loads and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // 2. Ensure 'MyApp' matches the class name in your main.dart
    await tester.pumpWidget(const MyApp());

    // Verify that the Login Screen branding is present.
    expect(find.text('CAMPUS LOST & FOUND'), findsOneWidget);
    
    // Verify that the Sign In button exists.
    expect(find.text('Sign In'), findsOneWidget);
  });
}