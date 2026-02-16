import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/constants.dart';

void main() {
  group('Constants', () {
    test('baseUrl should be a valid HTTP URL', () {
      expect(baseUrl, startsWith('http'));
      expect(Uri.tryParse(baseUrl), isNotNull);
    });

    test('loginEndpoint should start with /', () {
      expect(loginEndpoint, startsWith('/'));
    });

    test('logoutEndpoint should start with /', () {
      expect(logoutEndpoint, startsWith('/'));
    });

    test('jwtKey should be a non-empty string', () {
      expect(jwtKey, isNotEmpty);
    });

    test('endpoints should not contain the base URL', () {
      // Endpoints are relative, not absolute
      expect(loginEndpoint, isNot(contains('http')));
      expect(logoutEndpoint, isNot(contains('http')));
    });

    test('baseUrl + endpoints should form valid URLs', () {
      final loginUrl = Uri.tryParse('$baseUrl$loginEndpoint');
      final logoutUrl = Uri.tryParse('$baseUrl$logoutEndpoint');

      expect(loginUrl, isNotNull);
      expect(logoutUrl, isNotNull);
    });
  });
}
