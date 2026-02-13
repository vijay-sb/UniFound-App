import 'package:flutter_test/flutter_test.dart';

/// Simulates the same validation logic used in FoundItemFormScreen
String? validateField(String value) {
  if (value.trim().isEmpty) {
    return "Required";
  }
  return null;
}

void main() {
  group('Form validation unit tests', () {
    test('Empty field should return Required', () {
      final result = validateField("");
      expect(result, "Required");
    });

    test('Non-empty field should return null', () {
      final result = validateField("Phone");
      expect(result, null);
    });
  });
}