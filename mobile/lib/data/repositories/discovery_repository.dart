import '../app_exception.dart';
import '../api_client.dart';
import '../../models/nearby_traveler.dart';

class DiscoveryRepository {
  DiscoveryRepository(this._client);

  final ApiClient _client;

  Future<void> updateLocation({
    required String userId,
    double? lat,
    double? lng,
    bool? isDiscoverable,
  }) async {
    final response = await _client.put('/users/location', data: {
      'lat': ?lat,
      'lng': ?lng,
      'isDiscoverable': ?isDiscoverable,
    });
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error updating location');
    }
  }

  /// Returns an empty list (not an error) when the user hasn't turned on
  /// discoverability yet — the backend replies with `success: false` and an
  /// explanatory message in that case rather than a hard error.
  Future<List<NearbyTraveler>> fetchNearbyTravelers({
    required String userId,
    double radiusKm = 50,
  }) async {
    final response = await _client.get('/travelers/nearby', query: {
      'radiusKm': radiusKm,
    });
    final data = response['data'];
    if (response['success'] != true || data is! List) return [];
    return data
        .map((json) => NearbyTraveler.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
