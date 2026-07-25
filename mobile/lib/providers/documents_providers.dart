import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/travel_document.dart';
import 'repository_providers.dart';

/// Local-only travel documents for a trip. Keyed by (userId, tripId).
final documentsProvider = FutureProvider.family<List<TravelDocument>,
    ({String userId, String tripId})>((ref, ids) {
  return ref
      .watch(documentsRepositoryProvider)
      .fetchDocuments(userId: ids.userId, tripId: ids.tripId);
});
