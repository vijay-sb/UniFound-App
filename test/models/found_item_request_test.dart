import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/models/found_item_request.dart';

void main() {
  group('FoundItemRequest', () {
    test('should create an instance with required fields', () {
      final request = FoundItemRequest(
        category: 'Wallet',
        campusZone: 'Library',
        foundAt: DateTime(2026, 1, 15, 10, 30),
      );

      expect(request.category, 'Wallet');
      expect(request.campusZone, 'Library');
      expect(request.foundAt, DateTime(2026, 1, 15, 10, 30));
      expect(request.imageUrl, isNull);
    });

    test('should accept optional imageUrl', () {
      final request = FoundItemRequest(
        category: 'Phone',
        campusZone: 'AB 3',
        foundAt: DateTime(2026, 2, 1),
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(request.imageUrl, 'https://example.com/image.jpg');
    });

    test('toJson should return correct map structure', () {
      final dt = DateTime(2026, 3, 10, 14, 30);
      final request = FoundItemRequest(
        category: 'Keys',
        campusZone: 'Main Canteen',
        foundAt: dt,
      );

      final json = request.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['category'], 'Keys');
      expect(json['campus_zone'], 'Main Canteen');
      expect(json['found_at'], dt.toUtc().toIso8601String());
    });

    test('toJson should use snake_case keys', () {
      final request = FoundItemRequest(
        category: 'Laptop',
        campusZone: 'AB 1',
        foundAt: DateTime.now(),
      );

      final json = request.toJson();

      expect(json.containsKey('category'), isTrue);
      expect(json.containsKey('campus_zone'), isTrue);
      expect(json.containsKey('found_at'), isTrue);
      // imageUrl is NOT included in toJson
      expect(json.containsKey('image_url'), isFalse);
    });

    test('toJson found_at should always be UTC ISO8601', () {
      final localTime = DateTime(2026, 7, 20, 15, 0); // local
      final request = FoundItemRequest(
        category: 'Watch',
        campusZone: 'Ground',
        foundAt: localTime,
      );

      final json = request.toJson();
      final foundAtStr = json['found_at'] as String;

      // Should end with Z indicating UTC
      expect(foundAtStr, endsWith('Z'));
      expect(DateTime.parse(foundAtStr).isUtc, isTrue);
    });

    test('toJson should not include imageUrl in output', () {
      final request = FoundItemRequest(
        category: 'Charger',
        campusZone: 'Hostel',
        foundAt: DateTime.now(),
        imageUrl: 'https://example.com/photo.png',
      );

      final json = request.toJson();
      expect(json.containsKey('image_url'), isFalse);
      expect(json.containsKey('imageUrl'), isFalse);
    });
  });
}
