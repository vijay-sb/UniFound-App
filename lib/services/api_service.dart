// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants.dart';

class ApiService {
  final http.Client _client = http.Client();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      // Decode response body
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        // Return error message from backend if available
        throw Exception(responseData['message'] ?? 'Request failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Call logout endpoint. Returns true if backend responded 200.
  Future<bool> logout() async {
    try {
      final token = await getToken();
      final response = await _client.post(
        Uri.parse('$baseUrl$logoutEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> saveToken(String token) async => await _storage.write(key: jwtKey, value: token);
  Future<String?> getToken() async => await _storage.read(key: jwtKey);
  Future<void> deleteToken() async => await _storage.delete(key: jwtKey);
}