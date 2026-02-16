import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/models/login_request.dart';

void main() {
  group('LoginRequest', () {
    test('should create an instance with required fields', () {
      final request = LoginRequest(
        email: 'user@university.edu',
        password: 'securePass123',
      );

      expect(request.email, 'user@university.edu');
      expect(request.password, 'securePass123');
    });

    test('toJson should return correct map', () {
      final request = LoginRequest(
        email: 'student@campus.edu',
        password: 'myPassword',
      );

      final json = request.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['email'], 'student@campus.edu');
      expect(json['password'], 'myPassword');
    });

    test('toJson should contain exactly two keys', () {
      final request = LoginRequest(
        email: 'test@test.com',
        password: 'pass',
      );

      final json = request.toJson();
      expect(json.keys.length, 2);
      expect(json.keys, containsAll(['email', 'password']));
    });

    test('should preserve special characters in password', () {
      final request = LoginRequest(
        email: 'user@uni.edu',
        password: 'P@ss!w0rd#\$%^&*()',
      );

      final json = request.toJson();
      expect(json['password'], 'P@ss!w0rd#\$%^&*()');
    });

    test('should handle empty email and password', () {
      final request = LoginRequest(
        email: '',
        password: '',
      );

      expect(request.email, '');
      expect(request.password, '');

      final json = request.toJson();
      expect(json['email'], '');
      expect(json['password'], '');
    });
  });
}
