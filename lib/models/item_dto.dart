class ItemDto {
  final String id;
  final String category;
  final String campusZone;
  final DateTime foundAt;

  ItemDto({
    required this.id,
    required this.category,
    required this.campusZone,
    required this.foundAt,
  });

  factory ItemDto.fromJson(Map<String, dynamic> json) {
    return ItemDto(
      id: json['id'],
      category: json['category'],
      campusZone: json['campus_zone'],
      foundAt: DateTime.parse(json['found_at']),
    );
  }
}
