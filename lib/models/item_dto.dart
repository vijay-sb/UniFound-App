class ItemDto {
  final String id;
  final String category;
  final String campusZone;
  final DateTime foundAt;
  final String status; // Added this to match SQL query

  ItemDto({
    required this.id,
    required this.category,
    required this.campusZone,
    required this.foundAt,
    required this.status, // Added to constructor
  });

  factory ItemDto.fromJson(Map<String, dynamic> json) {
    return ItemDto(
      id: json['ID'].toString(), // Ensure it's a string even if DB returns int
      category: json['Category'],
      campusZone: json['CampusZone'],
      foundAt: DateTime.parse(json['FoundAt']['Time']),
      status: json['Status'], // Map the status from your SQL result
    );
  }
}