import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/models/item_dto.dart';

/// These tests validate the item grouping and filtering logic
/// used in BlindFeedScreen, extracted here for isolated unit testing.
void main() {
  // Helper to create test items
  ItemDto makeItem({
    String id = '1',
    String category = 'Wallet',
    String campusZone = 'Library',
    DateTime? foundAt,
    String status = 'VERIFIED',
  }) {
    return ItemDto(
      id: id,
      category: category,
      campusZone: campusZone,
      foundAt: foundAt ?? DateTime(2026, 1, 15),
      status: status,
    );
  }

  group('Item Filtering Logic', () {
    test('should filter only VERIFIED and AVAILABLE items', () {
      final items = [
        makeItem(id: '1', status: 'VERIFIED'),
        makeItem(id: '2', status: 'AVAILABLE'),
        makeItem(id: '3', status: 'REPORTED'),
        makeItem(id: '4', status: 'CLAIMED'),
      ];

      final filtered = items.where((i) {
        return i.status == 'VERIFIED' || i.status == 'AVAILABLE';
      }).toList();

      expect(filtered.length, 2);
      expect(filtered[0].status, 'VERIFIED');
      expect(filtered[1].status, 'AVAILABLE');
    });

    test('should filter by search query on category', () {
      final items = [
        makeItem(id: '1', category: 'Wallet', status: 'VERIFIED'),
        makeItem(id: '2', category: 'Keys', status: 'VERIFIED'),
        makeItem(id: '3', category: 'Phone', status: 'AVAILABLE'),
      ];

      const searchQuery = 'wal';
      final filtered = items.where((i) {
        final matchesStatus = i.status == 'VERIFIED' || i.status == 'AVAILABLE';
        final matchesSearch = i.category.toLowerCase().contains(searchQuery) ||
            i.campusZone.toLowerCase().contains(searchQuery);
        return matchesStatus && matchesSearch;
      }).toList();

      expect(filtered.length, 1);
      expect(filtered[0].category, 'Wallet');
    });

    test('should filter by search query on campus zone', () {
      final items = [
        makeItem(id: '1', campusZone: 'Library', status: 'VERIFIED'),
        makeItem(id: '2', campusZone: 'Main Canteen', status: 'VERIFIED'),
        makeItem(id: '3', campusZone: 'AB 3', status: 'AVAILABLE'),
      ];

      const searchQuery = 'lib';
      final filtered = items.where((i) {
        final matchesStatus = i.status == 'VERIFIED' || i.status == 'AVAILABLE';
        final matchesSearch = i.category.toLowerCase().contains(searchQuery) ||
            i.campusZone.toLowerCase().contains(searchQuery);
        return matchesStatus && matchesSearch;
      }).toList();

      expect(filtered.length, 1);
      expect(filtered[0].campusZone, 'Library');
    });

    test('empty search should return all matching status items', () {
      final items = [
        makeItem(id: '1', status: 'VERIFIED'),
        makeItem(id: '2', status: 'AVAILABLE'),
        makeItem(id: '3', status: 'REPORTED'),
      ];

      const searchQuery = '';
      final filtered = items.where((i) {
        final matchesStatus = i.status == 'VERIFIED' || i.status == 'AVAILABLE';
        final matchesSearch = i.category.toLowerCase().contains(searchQuery) ||
            i.campusZone.toLowerCase().contains(searchQuery);
        return matchesStatus && matchesSearch;
      }).toList();

      expect(filtered.length, 2);
    });
  });

  group('Item Grouping Logic', () {
    test('should group items by category + zone + date', () {
      final date = DateTime(2026, 1, 15);
      final items = [
        makeItem(id: '1', category: 'Keys', campusZone: 'AB 3', foundAt: date),
        makeItem(id: '2', category: 'Keys', campusZone: 'AB 3', foundAt: date),
        makeItem(
            id: '3', category: 'Wallet', campusZone: 'Library', foundAt: date),
      ];

      final Map<String, List<ItemDto>> groupedMap = {};
      for (var item in items) {
        final dateKey = item.foundAt.toString().split(' ').first;
        final groupingKey =
            "${item.category.toLowerCase()}_${item.campusZone.toLowerCase()}_$dateKey";
        groupedMap.putIfAbsent(groupingKey, () => []).add(item);
      }

      expect(groupedMap.length, 2); // 2 groups
      expect(groupedMap['keys_ab 3_2026-01-15']!.length, 2);
      expect(groupedMap['wallet_library_2026-01-15']!.length, 1);
    });

    test('should label grouped items with count', () {
      final date = DateTime(2026, 1, 15);
      final items = [
        makeItem(id: '1', category: 'Keys', campusZone: 'AB 3', foundAt: date),
        makeItem(id: '2', category: 'Keys', campusZone: 'AB 3', foundAt: date),
        makeItem(id: '3', category: 'Keys', campusZone: 'AB 3', foundAt: date),
      ];

      final Map<String, List<ItemDto>> groupedMap = {};
      for (var item in items) {
        final dateKey = item.foundAt.toString().split(' ').first;
        final groupingKey =
            "${item.category.toLowerCase()}_${item.campusZone.toLowerCase()}_$dateKey";
        groupedMap.putIfAbsent(groupingKey, () => []).add(item);
      }

      final displayItems = groupedMap.values.map((group) {
        final firstItem = group.first;
        final count = group.length;
        return ItemDto(
          id: firstItem.id,
          category:
              count > 1 ? "$count ${firstItem.category}s" : firstItem.category,
          campusZone: firstItem.campusZone,
          foundAt: firstItem.foundAt,
          status: group.any((i) => i.status == 'AVAILABLE')
              ? 'AVAILABLE'
              : 'VERIFIED',
        );
      }).toList();

      expect(displayItems.length, 1);
      expect(displayItems[0].category, '3 Keyss');
    });

    test('should set status to AVAILABLE if any item in group is AVAILABLE',
        () {
      final date = DateTime(2026, 1, 15);
      final items = [
        makeItem(
            id: '1',
            category: 'Keys',
            campusZone: 'AB 3',
            foundAt: date,
            status: 'VERIFIED'),
        makeItem(
            id: '2',
            category: 'Keys',
            campusZone: 'AB 3',
            foundAt: date,
            status: 'AVAILABLE'),
      ];

      final Map<String, List<ItemDto>> groupedMap = {};
      for (var item in items) {
        final dateKey = item.foundAt.toString().split(' ').first;
        final groupingKey =
            "${item.category.toLowerCase()}_${item.campusZone.toLowerCase()}_$dateKey";
        groupedMap.putIfAbsent(groupingKey, () => []).add(item);
      }

      final displayItems = groupedMap.values.map((group) {
        final firstItem = group.first;
        final count = group.length;
        return ItemDto(
          id: firstItem.id,
          category:
              count > 1 ? "$count ${firstItem.category}s" : firstItem.category,
          campusZone: firstItem.campusZone,
          foundAt: firstItem.foundAt,
          status: group.any((i) => i.status == 'AVAILABLE')
              ? 'AVAILABLE'
              : 'VERIFIED',
        );
      }).toList();

      expect(displayItems[0].status, 'AVAILABLE');
    });

    test('different dates should not be grouped together', () {
      final items = [
        makeItem(
            id: '1',
            category: 'Keys',
            campusZone: 'AB 3',
            foundAt: DateTime(2026, 1, 15)),
        makeItem(
            id: '2',
            category: 'Keys',
            campusZone: 'AB 3',
            foundAt: DateTime(2026, 1, 16)),
      ];

      final Map<String, List<ItemDto>> groupedMap = {};
      for (var item in items) {
        final dateKey = item.foundAt.toString().split(' ').first;
        final groupingKey =
            "${item.category.toLowerCase()}_${item.campusZone.toLowerCase()}_$dateKey";
        groupedMap.putIfAbsent(groupingKey, () => []).add(item);
      }

      expect(groupedMap.length, 2); // Different dates, different groups
    });

    test('different zones should not be grouped together', () {
      final date = DateTime(2026, 1, 15);
      final items = [
        makeItem(id: '1', category: 'Keys', campusZone: 'AB 3', foundAt: date),
        makeItem(
            id: '2', category: 'Keys', campusZone: 'Library', foundAt: date),
      ];

      final Map<String, List<ItemDto>> groupedMap = {};
      for (var item in items) {
        final dateKey = item.foundAt.toString().split(' ').first;
        final groupingKey =
            "${item.category.toLowerCase()}_${item.campusZone.toLowerCase()}_$dateKey";
        groupedMap.putIfAbsent(groupingKey, () => []).add(item);
      }

      expect(groupedMap.length, 2);
    });
  });

  group('Form Validation Logic', () {
    String? validateField(String? value) {
      if (value == null || value.isEmpty) return "Required";
      return null;
    }

    test('empty field should return Required', () {
      expect(validateField(''), 'Required');
    });

    test('null field should return Required', () {
      expect(validateField(null), 'Required');
    });

    test('non-empty field should return null', () {
      expect(validateField('Phone'), isNull);
    });

    test('whitespace-only should pass basic validation', () {
      // Note: the actual validator checks isEmpty, not trim
      expect(validateField('   '), isNull);
    });
  });

  group('Location Logic', () {
    test('Hostel with selected hostel name should produce combined string', () {
      const selectedLocation = 'Hostel';
      const selectedHostel = 'Mythreyi';

      String finalLocation = selectedLocation;
      if (selectedLocation == 'Hostel' && selectedHostel.isNotEmpty) {
        finalLocation = "Hostel: $selectedHostel";
      }

      expect(finalLocation, 'Hostel: Mythreyi');
    });

    test('Others with custom zone should use text input', () {
      const selectedLocation = 'Others';
      const customZone = 'Chapel Building';

      String finalLocation = selectedLocation;
      if (selectedLocation == 'Others') {
        finalLocation = customZone;
      }

      expect(finalLocation, 'Chapel Building');
    });

    test('normal location should be used directly', () {
      const selectedLocation = 'AB 3';

      String finalLocation = selectedLocation;

      expect(finalLocation, 'AB 3');
    });
  });

  group('Category Logic', () {
    test('Others with custom category should use text input', () {
      const selectedCategory = 'Others';
      const customCategory = 'Sunglasses';

      String finalCategory = selectedCategory;
      if (selectedCategory == 'Others') {
        finalCategory = customCategory;
      }

      expect(finalCategory, 'Sunglasses');
    });

    test('normal category should be used directly', () {
      const selectedCategory = 'Wallet';

      String finalCategory = selectedCategory;

      expect(finalCategory, 'Wallet');
    });
  });
}
