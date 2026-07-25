import '../app_exception.dart';
import '../api_client.dart';

/// Itinerary items are nested inside a [Trip], fetched via [TripRepository].
/// This repository only handles mutations, each followed by re-fetching the
/// owning trip.
class ItineraryRepository {
  ItineraryRepository(this._client);

  final ApiClient _client;

  String _base(String userId, String tripId) => '/trips/$userId/$tripId/itinerary';

  Future<void> addItem({
    required String userId,
    required String tripId,
    required String text,
    required DateTime date,
    int priority = 0,
    String location = '',
  }) async {
    final response = await _client.post(_base(userId, tripId), data: {
      'text': text,
      'date': date.toIso8601String(),
      'priority': priority,
      'location': location,
    });
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error adding itinerary item');
    }
  }

  Future<void> updateItem({
    required String userId,
    required String tripId,
    required String itemId,
    required String text,
    required DateTime date,
    required int priority,
    required String location,
  }) async {
    final response = await _client.put('${_base(userId, tripId)}/$itemId', data: {
      'text': text,
      'date': date.toIso8601String(),
      'priority': priority,
      'location': location,
    });
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error updating itinerary item');
    }
  }

  Future<void> deleteItem({
    required String userId,
    required String tripId,
    required String itemId,
  }) async {
    final response = await _client.delete('${_base(userId, tripId)}/$itemId');
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error deleting itinerary item');
    }
  }

  Future<void> setCompleted({
    required String userId,
    required String tripId,
    required String itemId,
    required bool completed,
  }) async {
    final response = await _client
        .put('${_base(userId, tripId)}/$itemId/completedStatus', data: {
      'completed': completed,
    });
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error updating itinerary item');
    }
  }
}
