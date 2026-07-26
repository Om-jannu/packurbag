import '../app_exception.dart';
import '../api_client.dart';

/// Proxies translation through the backend's Groq-backed `/translate` route
/// — replaces the old direct dependency on the `translator` package, which
/// scraped Google Translate's public web endpoint rather than calling a
/// real API and could break at any time. The API key never lives in the
/// client — see server/src/routes/translate.routes.ts.
class TranslationRepository {
  TranslationRepository(this._client);

  final ApiClient _client;

  Future<String> translate({
    required String text,
    required String fromLanguageCode,
    required String toLanguageCode,
  }) async {
    if (text.trim().isEmpty) return '';

    final response = await _client.post('/translate', data: {
      'text': text,
      'from': fromLanguageCode,
      'to': toLanguageCode,
    });

    if (response['success'] != true) {
      throw AppException(
          response['message'] as String? ?? 'Translation is temporarily unavailable. Please try again.');
    }
    return response['translated'] as String? ?? '';
  }
}
