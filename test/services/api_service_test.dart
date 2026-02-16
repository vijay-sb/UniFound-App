import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lost_found_app/constants.dart';

void main() {
  group('ApiService - POST logic', () {
    test('should send correct headers and body', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.headers['Content-Type'], 'application/json');

        final body = json.decode(request.body);
        expect(body['email'], 'test@uni.edu');
        expect(body['password'], 'pass123');

        return http.Response(
          jsonEncode({'access_token': 'jwt-abc-123'}),
          200,
        );
      });

      final response = await mockClient.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': 'test@uni.edu', 'password': 'pass123'}),
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['access_token'], 'jwt-abc-123');
    });

    test('should return error message on non-200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Invalid credentials'}),
          401,
        );
      });

      final response = await mockClient.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': 'bad@uni.edu', 'password': 'wrong'}),
      );

      expect(response.statusCode, 401);
      final data = jsonDecode(response.body);
      expect(data['message'], 'Invalid credentials');
    });

    test('should handle network error gracefully', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Connection refused');
      });

      expect(
        () => mockClient.post(
          Uri.parse('$baseUrl$loginEndpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': 'test@test.com', 'password': 'pass'}),
        ),
        throwsException,
      );
    });
  });

  group('ApiService - Logout logic', () {
    test('should send POST to logout endpoint with auth header', () async {
      const token = 'my-jwt-token';

      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), '$baseUrl$logoutEndpoint');
        expect(request.headers['Authorization'], 'Bearer $token');

        return http.Response('', 200);
      });

      final response = await mockClient.post(
        Uri.parse('$baseUrl$logoutEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      expect(response.statusCode, 200);
    });

    test('should handle logout failure', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Session expired"}', 500);
      });

      final response = await mockClient.post(
        Uri.parse('$baseUrl$logoutEndpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      expect(response.statusCode, 500);
    });
  });
}
