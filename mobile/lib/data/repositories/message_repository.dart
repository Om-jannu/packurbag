import '../app_exception.dart';
import '../api_client.dart';
import '../../models/traveler_message.dart';

class MessageRepository {
  MessageRepository(this._client);

  final ApiClient _client;

  Future<List<TravelerMessage>> fetchConversation({
    required String userId,
    required String otherUserId,
  }) async {
    final response = await _client.get('/messages/$userId/$otherUserId');
    final data = response['data'];
    if (data is! List) return [];
    return data
        .map((json) => TravelerMessage.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final response = await _client.post('/messages', data: {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
    });
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error sending message');
    }
  }
}
