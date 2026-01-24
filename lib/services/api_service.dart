import 'dart:convert';
import 'package:http/http.dart' as http;  // ✅ FIXED
import 'package:flutter_secure_storage/flutter_secure_storage.dart';  // ✅ FIXED
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
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Login failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> saveToken(String token) async => await _storage.write(key: jwtKey, value: token);
  Future<void> deleteToken() async => await _storage.delete(key: jwtKey);
}
