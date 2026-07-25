import '../app_exception.dart';
import '../api_client.dart';
import '../../models/trip.dart';

class TripRepository {
  TripRepository(this._client);

  final ApiClient _client;

  Future<List<Trip>> fetchTrips(String userId) async {
    final response = await _client.get('/trips/$userId');
    final data = response['data'];
    if (data is! List) return [];
    return data.map((json) => Trip.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> addTrip({
    required String userId,
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String notes = '',
    String coverColor = 'FF6B4A',
    double? budgetAmount,
    String budgetCurrency = 'INR',
  }) async {
    final response = await _client.post('/trips/$userId', data: {
      'title': title,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'notes': notes,
      'coverColor': coverColor,
      'budgetAmount': budgetAmount,
      'budgetCurrency': budgetCurrency,
    });
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error adding trip');
    }
  }

  Future<void> updateTrip({
    required String userId,
    required String tripId,
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String notes = '',
    String coverColor = 'FF6B4A',
    double? budgetAmount,
    String budgetCurrency = 'INR',
  }) async {
    final response = await _client.put('/trips/$userId/$tripId', data: {
      'title': title,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'notes': notes,
      'coverColor': coverColor,
      'budgetAmount': budgetAmount,
      'budgetCurrency': budgetCurrency,
    });
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error updating trip');
    }
  }

  Future<void> deleteTrip({required String userId, required String tripId}) async {
    final response = await _client.delete('/trips/$userId/$tripId');
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error deleting trip');
    }
  }
}
