import '../app_exception.dart';
import '../api_client.dart';

class PackingRepository {
  PackingRepository(this._client);

  final ApiClient _client;

  String _base(String userId, String tripId) => '/trips/$userId/$tripId/packing';

  Future<void> addItem({
    required String userId,
    required String tripId,
    required String text,
    String category = 'General',
  }) async {
    final response = await _client.post(_base(userId, tripId), data: {
      'text': text,
      'category': category,
    });
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error adding packing item');
    }
  }

  /// Bulk-adds items from a packing template.
  Future<void> addItems({
    required String userId,
    required String tripId,
    required List<(String text, String category)> items,
  }) async {
    final response = await _client.post(_base(userId, tripId), data: [
      for (final (text, category) in items) {'text': text, 'category': category},
    ]);
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error adding packing items');
    }
  }

  Future<void> deleteItem({
    required String userId,
    required String tripId,
    required String itemId,
  }) async {
    final response = await _client.delete('${_base(userId, tripId)}/$itemId');
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error deleting packing item');
    }
  }

  Future<void> setPacked({
    required String userId,
    required String tripId,
    required String itemId,
    required bool packed,
  }) async {
    final response =
        await _client.put('${_base(userId, tripId)}/$itemId/packedStatus', data: {
      'packed': packed,
    });
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error updating packing item');
    }
  }
}
