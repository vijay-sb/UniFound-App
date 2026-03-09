class ClaimDto {
  final String id;
  final String itemId;
  final String status;
  final int? confidenceScore;
  final DateTime createdAt;
  final String category;
  final String campusZone;
  final String? pickupTokenId;
  final String? shortCode;

  ClaimDto({
    required this.id,
    required this.itemId,
    required this.status,
    required this.confidenceScore,
    required this.createdAt,
    required this.category,
    required this.campusZone,
    this.pickupTokenId,
    this.shortCode,
  });

  factory ClaimDto.fromJson(Map<String, dynamic> json) {
    int? score;
    if (json['ConfidenceScore'] != null) {
      final cs = json['ConfidenceScore'];
      if (cs is Map) {
        score = cs['Valid'] == true ? cs['Int32'] as int? : null;
      } else if (cs is int) {
        score = cs;
      }
    }

    // PickupTokenID comes as a NullUUID: {"UUID": "...", "Valid": true/false}
    String? tokenId;
    if (json['PickupTokenID'] != null) {
      final pt = json['PickupTokenID'];
      if (pt is Map && pt['Valid'] == true) {
        tokenId = pt['UUID']?.toString();
      } else if (pt is String) {
        tokenId = pt;
      }
    }

    return ClaimDto(
      id: json['ID'].toString(),
      itemId: json['ItemID'].toString(),
      status: json['Status'] ?? 'PENDING',
      confidenceScore: score,
      createdAt: DateTime.parse(json['CreatedAt']),
      category: json['Category'] ?? '',
      campusZone: json['CampusZone'] ?? '',
      pickupTokenId: tokenId,
      shortCode: json['ShortCode']?.toString(),
    );
  }
}
