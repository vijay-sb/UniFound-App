import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/item_dto.dart';

class ItemApiService {
  final String baseUrl;
  final Future<String?> Function() getToken;

  ItemApiService({
    required this.baseUrl,
    required this.getToken,
  });

  Future<List<ItemDto>> fetchDiscoverItems() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/items/discover'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load items');
    }

    final List data = json.decode(response.body);
    return data.map((e) => ItemDto.fromJson(e)).toList();
  }

  Future<void> reportFoundItem(Map<String, dynamic> itemData) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/items/found'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(itemData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      // Decode error message from backend if available
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to report item');
    }
  }

  Future<Map<String, dynamic>> getUploadUrl() async {
    final token = await getToken();

    if (token == null) {
      throw Exception("User not authenticated");
    }

    final res = await http.post(
      Uri.parse('$baseUrl/api/uploads/found-item'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to get upload url");
    }

    return json.decode(res.body);
  }

  Future<void> uploadImageToMinio(String url, Uint8List bytes) async {
    final res = await http.put(
      Uri.parse(url),
      headers: {
        "Content-Type": "image/jpeg",
      },
      body: bytes,
    );

    if (res.statusCode != 200) {
      throw Exception("Upload failed");
    }
  }
}
