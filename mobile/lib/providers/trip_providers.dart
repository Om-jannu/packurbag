import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/trip.dart';
import 'repository_providers.dart';

/// All trips for a user, each already containing its nested itinerary,
/// packing list, and expenses — the backend embeds them on the trip
/// subdocument, so there's a single source of truth here. Itinerary/packing/
/// expense mutations call their own repository, then `ref.invalidate(tripsProvider(userId))`
/// to refresh.
final tripsProvider = FutureProvider.family<List<Trip>, String>((ref, userId) {
  return ref.watch(tripRepositoryProvider).fetchTrips(userId);
});
