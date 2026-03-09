import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/item_dto.dart';
import '../models/question_model.dart';
import '../models/claim_dto.dart';

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
      Uri.parse('$baseUrl/items/discover'),
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

  /* ───────────── MY REPORTED ITEMS ───────────── */

  Future<List<ItemDto>> fetchMyReportedItems() async {
    final String? token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/items/my'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => ItemDto.fromJson(item)).toList();
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized: Please login again.");
    } else {
      throw Exception("Server error while fetching your reports.");
    }
  }

  /* ───────────── VERIFICATION QUESTIONS ───────────── */

  /// Fetch the verification questions for an AVAILABLE item (no answers leaked).
  Future<List<QuestionModel>> fetchItemQuestions(String itemId) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/items/$itemId/questions'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to load questions');
    }

    final data = json.decode(response.body);
    final List questionsJson = data['questions'];
    return questionsJson.map((e) => QuestionModel.fromJson(e)).toList();
  }

  /* ───────────── CLAIM ITEM ───────────── */

  /// Create a claim for the item. Returns claim_id and questions with IDs.
  Future<Map<String, dynamic>> claimItem(String itemId) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/items/$itemId/claim'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 201) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to create claim');
    }

    return json.decode(response.body);
  }

  /* ───────────── SUBMIT CLAIM ANSWERS ───────────── */

  /// Submit answers for a claim. Returns confidence_score, status, and message.
  Future<Map<String, dynamic>> submitClaimAnswers(
    String claimId,
    List<Map<String, String>> answers,
  ) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/claims/$claimId/submit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'answers': answers}),
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to submit answers');
    }

    return json.decode(response.body);
  }

  /* ───────────── MY CLAIMS ───────────── */

  Future<List<ClaimDto>> fetchMyClaims() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/claims/my'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load claims');
    }

    final List data = json.decode(response.body);
    return data.map((e) => ClaimDto.fromJson(e)).toList();
  }
}
