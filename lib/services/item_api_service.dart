import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/item_dto.dart';

class ItemApiService {
  final String baseUrl;
  final Future<String?> Function() getToken;

  ItemApiService({
    required this.baseUrl,
    required this.getToken,
  });

  /* ───────────── DISCOVER ───────────── */

  Future<List<ItemDto>> fetchDiscoverItems() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/items/discover'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load items');
    }

    final List data = json.decode(response.body);
    return data.map((e) => ItemDto.fromJson(e)).toList();
  }

  /* ───────────── REPORT ITEM ───────────── */

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
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to report item');
    }
  }

  Future<String> uploadImageViaBackend(Uint8List bytes) async {
    final token = await getToken();

    final request = http.MultipartRequest(
      "POST",
      Uri.parse('$baseUrl/api/uploads/found-item'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        "file",
        bytes,
        filename: "found_item.jpg",
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception("Upload failed: $responseBody");
    }

    final decoded = json.decode(responseBody);
    return decoded["image_key"]; // this is the UploadThing URL
  }


  /* ───────────── GET UPLOAD URL ───────────── */

  // Future<Map<String, dynamic>> getUploadUrl() async {
  //   final token = await getToken();

  //   if (token == null) {
  //     throw Exception("User not authenticated");
  //   }

  //   final res = await http.post(
  //     Uri.parse('$baseUrl/api/uploads/found-item'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //     },
  //   );

  //   if (res.statusCode != 200) {
  //     throw Exception("Failed to get upload url");
  //   }

  //   return json.decode(res.body);
  // }

  /* ───────────── MINIO UPLOAD (CRITICAL) ───────────── */

// ...existing code...
// ...existing code...
// ...existing code...
  // Future<void> uploadImageToMinio(String uploadUrl, Uint8List bytes) async {
  //   // Use the exact presigned URL returned by the backend (do NOT change host)
  //   final uri = Uri.parse(uploadUrl);

  //   // IMPORTANT: do not add headers that weren't part of the signature.
  //   final response = await http.put(uri, body: bytes);

  //   if (response.statusCode != 200 && response.statusCode != 204) {
  //     throw Exception(
  //       "Image upload failed (${response.statusCode}): ${response.body}",
  //     );
  //   }
  // }
// ...existing code...
// ...existing code...
// ...existing code...

  /* ───────────── HOSTNAME FIX ───────────── */

}

