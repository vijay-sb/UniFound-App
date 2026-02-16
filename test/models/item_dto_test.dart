import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/models/item_dto.dart';

void main() {
  group('ItemDto', () {
    test('should create an instance with required fields', () {
      final item = ItemDto(
        id: '1',
        category: 'Wallet',
        campusZone: 'Library',
        foundAt: DateTime(2026, 1, 15, 10, 30),
        status: 'REPORTED',
      );

      expect(item.id, '1');
      expect(item.category, 'Wallet');
      expect(item.campusZone, 'Library');
      expect(item.foundAt, DateTime(2026, 1, 15, 10, 30));
      expect(item.status, 'REPORTED');
    });

    test('fromJson should parse valid JSON correctly', () {
      final json = {
        'ID': 42,
        'Category': 'Keys',
        'CampusZone': 'AB 3',
        'FoundAt': {'Time': '2026-01-10T14:30:00Z'},
        'Status': 'VERIFIED',
      };

      final item = ItemDto.fromJson(json);

      expect(item.id, '42');
      expect(item.category, 'Keys');
      expect(item.campusZone, 'AB 3');
      expect(item.foundAt, DateTime.utc(2026, 1, 10, 14, 30));
      expect(item.status, 'VERIFIED');
    });

    test('fromJson should convert integer ID to string', () {
      final json = {
        'ID': 99,
        'Category': 'Phone',
        'CampusZone': 'Main Canteen',
        'FoundAt': {'Time': '2026-02-01T09:00:00Z'},
        'Status': 'AVAILABLE',
      };

      final item = ItemDto.fromJson(json);
      expect(item.id, isA<String>());
      expect(item.id, '99');
    });

    test('fromJson should handle string ID', () {
      final json = {
        'ID': 'abc-123',
        'Category': 'Laptop',
        'CampusZone': 'AB 1',
        'FoundAt': {'Time': '2026-02-05T12:00:00Z'},
        'Status': 'REPORTED',
      };

      final item = ItemDto.fromJson(json);
      expect(item.id, 'abc-123');
    });

    test('fromJson should correctly parse nested FoundAt time', () {
      final json = {
        'ID': 1,
        'Category': 'Umbrella',
        'CampusZone': 'Ground',
        'FoundAt': {'Time': '2026-06-15T08:45:30Z'},
        'Status': 'VERIFIED',
      };

      final item = ItemDto.fromJson(json);
      expect(item.foundAt.year, 2026);
      expect(item.foundAt.month, 6);
      expect(item.foundAt.day, 15);
      expect(item.foundAt.hour, 8);
      expect(item.foundAt.minute, 45);
    });

    test('fromJson should throw on missing required fields', () {
      final incompleteJson = {
        'ID': 1,
        'Category': 'Keys',
        // Missing CampusZone, FoundAt, Status
      };

      expect(
        () => ItemDto.fromJson(incompleteJson),
        throwsA(isA<Error>()),
      );
    });

    test('should support all known status values', () {
      for (final status in ['REPORTED', 'VERIFIED', 'AVAILABLE', 'CLAIMED']) {
        final item = ItemDto(
          id: '1',
          category: 'Test',
          campusZone: 'Test Zone',
          foundAt: DateTime.now(),
          status: status,
        );
        expect(item.status, status);
      }
    });
  });
}
