class FoundItemRequest {
  final String category;
  final String campusZone;
  final DateTime foundAt;
  final String? imageUrl; // For initial dev, though real uploads use Multipart

  FoundItemRequest({
    required this.category,
    required this.campusZone,
    required this.foundAt,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'campus_zone': campusZone,
      'found_at': foundAt.toUtc().toIso8601String(),
      // 'image_url' is usually handled separately in Multipart requests
    };
  }
}