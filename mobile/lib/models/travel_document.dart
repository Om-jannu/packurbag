/// A per-trip photo entry (e.g. "Day 1", "Day 2") — stored entirely on-device
/// (see [DocumentsRepository]) and never synced to the backend.
class TravelDocument {
  const TravelDocument({
    required this.id,
    required this.tripId,
    required this.title,
    this.notes = '',
    this.imagePaths = const [],
  });

  final String id;
  final String tripId;
  final String title;
  final String notes;
  final List<String> imagePaths;

  TravelDocument copyWith({
    String? title,
    String? notes,
    List<String>? imagePaths,
  }) {
    return TravelDocument(
      id: id,
      tripId: tripId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'title': title,
        'notes': notes,
        'imagePaths': imagePaths,
      };

  factory TravelDocument.fromJson(Map<String, dynamic> json) {
    // Entries saved before this became a multi-photo gallery had a single
    // nullable `imagePath` string instead of `imagePaths` — fold that into
    // a one-element list rather than losing the photo.
    final rawPaths = json['imagePaths'] as List<dynamic>?;
    final legacyPath = json['imagePath'] as String?;
    final imagePaths = rawPaths != null
        ? rawPaths.cast<String>()
        : (legacyPath != null ? [legacyPath] : const <String>[]);

    return TravelDocument(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String? ?? '',
      imagePaths: imagePaths,
    );
  }
}
