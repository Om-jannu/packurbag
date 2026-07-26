import '../app_exception.dart';
import '../api_client.dart';

/// A single turn in an AI chat conversation, matching the chat-completion
/// `{role, content}` message shape the backend forwards verbatim to Groq.
class ChatMessage {
  final String role;
  final String content;

  const ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class AiRepository {
  AiRepository(this._client);

  final ApiClient _client;

  /// Sends [message] plus prior [history] to the server-side Groq proxy,
  /// framed as a travel assistant. Passing [destination] (e.g. the active
  /// trip's destination) scopes the system prompt to that place.
  /// The API key never lives in the client — see server/src/routes/ai.routes.ts.
  Future<String> sendChatMessage({
    required String message,
    List<ChatMessage> history = const [],
    String? destination,
  }) async {
    final response = await _client.post('/ai/chat', data: {
      'message': message,
      'history': history.map((m) => m.toJson()).toList(),
      'destination': ?destination,
    });

    if (response['success'] != true) {
      throw AppException(
          response['message'] as String? ?? 'AI chat request failed');
    }
    return response['message'] as String? ?? '';
  }
}
