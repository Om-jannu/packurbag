import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nearby_traveler.dart';
import '../models/traveler_message.dart';
import 'repository_providers.dart';

/// Nearby discoverable travelers for the current user. Screens refresh via
/// `ref.invalidate(nearbyTravelersProvider(userId))` (e.g. a pull-to-refresh
/// or a periodic timer while the screen is open).
final nearbyTravelersProvider =
    FutureProvider.family<List<NearbyTraveler>, String>((ref, userId) {
  return ref.watch(discoveryRepositoryProvider).fetchNearbyTravelers(userId: userId);
});

/// A 1:1 conversation, keyed by the *other* user's id. Polled on a timer by
/// the chat screen while open (see TravelerChatScreen) rather than a
/// websocket, to stay consistent with the rest of the app's plain-REST data
/// layer.
final conversationProvider =
    FutureProvider.family<List<TravelerMessage>, ({String userId, String otherUserId})>(
        (ref, ids) {
  return ref
      .watch(messageRepositoryProvider)
      .fetchConversation(userId: ids.userId, otherUserId: ids.otherUserId);
});
