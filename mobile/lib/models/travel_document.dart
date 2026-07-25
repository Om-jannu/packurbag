enum TravelDocumentType { passport, visa, ticket, insurance, other }

/// Stored entirely on-device (see [DocumentsRepository]) — never synced to
/// the backend, since these can represent scans of sensitive documents like
/// passports.
class TravelDocument {
  const TravelDocument({
    required this.id,
    required this.tripId,
    required this.type,
    required this.title,
    this.notes = '',
    this.imagePath,
  });

  final String id;
  final String tripId;
  final TravelDocumentType type;
  final String title;
  final String notes;
  final String? imagePath;

  TravelDocument copyWith({
    String? title,
    String? notes,
    String? imagePath,
  }) {
    return TravelDocument(
      id: id,
      tripId: tripId,
      type: type,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'type': type.name,
        'title': title,
        'notes': notes,
        'imagePath': imagePath,
      };

  factory TravelDocument.fromJson(Map<String, dynamic> json) {
    return TravelDocument(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      type: TravelDocumentType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TravelDocumentType.other,
      ),
      title: json['title'] as String,
      notes: json['notes'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
    );
  }
}
