import '../app_exception.dart';
import '../api_client.dart';

/// A single turn in an AI chat conversation, matching the chat-completion
/// `{role, content}` message shape the backend forwards verbatim to Groq.
class ChatMessage {
  static int _nextId = 0;

  /// Identifies this message across state updates (e.g. marking it failed,
  /// then retrying) — matching by [content] instead would break if the user
  /// ever sends the same text twice.
  final int id;
  final String role;
  final String content;
  final bool failed;

  ChatMessage({required this.role, required this.content, this.failed = false, int? id})
      : id = id ?? _nextId++;

  ChatMessage copyWith({bool? failed}) =>
      ChatMessage(id: id, role: role, content: content, failed: failed ?? this.failed);

  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  Map<String, dynamic> toStorageJson() => {'id': id, 'role': role, 'content': content};

  factory ChatMessage.fromStorageJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    // Restoring bypasses the auto-increment above, so a fresh app process
    // (where _nextId starts back at 0) would otherwise hand out ids that
    // collide with ones already in the restored history — pull the counter
    // past every id we load.
    if (id >= _nextId) _nextId = id + 1;
    return ChatMessage(id: id, role: json['role'] as String, content: json['content'] as String);
  }
}

class AiRepository {
  AiRepository(this._client);

  final ApiClient _client;

  /// Sends [message] plus prior [history] to the server-side Groq proxy,
  /// framed as a travel assistant. Passing [destination] (e.g. the active
  /// trip's destination) scopes the system prompt to that place; [tripContext]
  /// is an optional short summary (dates/budget/itinerary) for more
  /// personalized answers when a trip is selected.
  /// The API key never lives in the client — see server/src/routes/ai.routes.ts.
  Future<String> sendChatMessage({
    required String message,
    List<ChatMessage> history = const [],
    String? destination,
    String? tripContext,
  }) async {
    final response = await _client.post('/ai/chat', data: {
      'message': message,
      'history': history.map((m) => m.toJson()).toList(),
      'destination': ?destination,
      'tripContext': ?tripContext,
    });

    if (response['success'] != true) {
      throw AppException(
          response['message'] as String? ?? 'AI chat request failed');
    }
    return response['message'] as String? ?? '';
  }
}
