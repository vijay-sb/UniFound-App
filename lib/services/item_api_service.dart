import 'dart:convert';
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
}
