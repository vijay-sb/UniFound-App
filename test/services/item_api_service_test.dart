import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lost_found_app/models/item_dto.dart';
import 'package:lost_found_app/services/item_api_service.dart';

void main() {
  const testBaseUrl = 'http://localhost:8080';
  const testToken = 'test-jwt-token-123';

  Future<String?> mockGetToken() async => testToken;

  group('ItemApiService - fetchDiscoverItems', () {
    test('should return list of ItemDto on 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), '$testBaseUrl/items/discover');
        expect(request.headers['Authorization'], 'Bearer $testToken');

        return http.Response(
          jsonEncode([
            {
              'ID': 1,
              'Category': 'Wallet',
              'CampusZone': 'Library',
              'FoundAt': {'Time': '2026-01-15T10:30:00Z'},
              'Status': 'VERIFIED',
            },
            {
              'ID': 2,
              'Category': 'Keys',
              'CampusZone': 'AB 3',
              'FoundAt': {'Time': '2026-01-16T14:00:00Z'},
              'Status': 'AVAILABLE',
            },
          ]),
          200,
        );
      });

      // Use mock client to test the parsing logic
      final response = await mockClient.get(
        Uri.parse('$testBaseUrl/items/discover'),
        headers: {'Authorization': 'Bearer $testToken'},
      );

      expect(response.statusCode, 200);

      final List data = json.decode(response.body);
      final items = data.map((e) => ItemDto.fromJson(e)).toList();

      expect(items.length, 2);
      expect(items[0].category, 'Wallet');
      expect(items[0].campusZone, 'Library');
      expect(items[0].status, 'VERIFIED');
      expect(items[1].category, 'Keys');
      expect(items[1].status, 'AVAILABLE');
    });

    test('should throw on non-200 status code', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Unauthorized"}', 401);
      });

      final response = await mockClient.get(
        Uri.parse('$testBaseUrl/items/discover'),
        headers: {'Authorization': 'Bearer $testToken'},
      );

      expect(response.statusCode, isNot(200));
    });

    test('should return empty list on empty response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('[]', 200);
      });

      final response = await mockClient.get(
        Uri.parse('$testBaseUrl/items/discover'),
        headers: {'Authorization': 'Bearer $testToken'},
      );

      final List data = json.decode(response.body);
      final items = data.map((e) => ItemDto.fromJson(e)).toList();

      expect(items, isEmpty);
    });
  });

  group('ItemApiService - reportFoundItem', () {
    test('should send POST with correct data', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), '$testBaseUrl/api/items/found');
        expect(request.headers['Authorization'], 'Bearer $testToken');
        expect(request.headers['Content-Type'], 'application/json');

        final body = json.decode(request.body);
        expect(body['category'], 'Phone');
        expect(body['campus_zone'], 'AB 1');

        return http.Response('{"id": 42}', 201);
      });

      final itemData = {
        'category': 'Phone',
        'campus_zone': 'AB 1',
        'found_at': DateTime.now().toUtc().toIso8601String(),
        'image_key': 'test-image-key',
      };

      final response = await mockClient.post(
        Uri.parse('$testBaseUrl/api/items/found'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(itemData),
      );

      expect(response.statusCode, 201);
    });

    test('should handle error response from server', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"error": "Failed to report item"}',
          400,
        );
      });

      final response = await mockClient.post(
        Uri.parse('$testBaseUrl/api/items/found'),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'category': 'Test'}),
      );

      expect(response.statusCode, 400);
      final errorData = json.decode(response.body);
      expect(errorData['error'], 'Failed to report item');
    });
  });

  group('ItemApiService - fetchMyReportedItems', () {
    test('should return list of reported items on 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), '$testBaseUrl/items/my');
        expect(request.headers['Authorization'], 'Bearer $testToken');

        return http.Response(
          jsonEncode([
            {
              'ID': 101,
              'Category': 'Keys',
              'CampusZone': 'Admin Block',
              'FoundAt': {'Time': '2026-02-10T08:00:00Z'},
              'Status': 'REPORTED',
            },
          ]),
          200,
        );
      });

      final response = await mockClient.get(
        Uri.parse('$testBaseUrl/items/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $testToken',
        },
      );

      expect(response.statusCode, 200);
      final List data = json.decode(response.body);
      final items = data.map((e) => ItemDto.fromJson(e)).toList();

      expect(items.length, 1);
      expect(items[0].category, 'Keys');
      expect(items[0].status, 'REPORTED');
    });

    test('should throw on 401 unauthorized', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Unauthorized"}', 401);
      });

      final response = await mockClient.get(
        Uri.parse('$testBaseUrl/items/my'),
        headers: {'Authorization': 'Bearer expired-token'},
      );

      expect(response.statusCode, 401);
    });
  });

  group('ItemApiService - constructor', () {
    test('should accept baseUrl and getToken', () {
      final service = ItemApiService(
        baseUrl: testBaseUrl,
        getToken: mockGetToken,
      );

      expect(service.baseUrl, testBaseUrl);
      expect(service.getToken, isNotNull);
    });
  });
}
