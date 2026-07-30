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

  /// [fromLanguageName]/[toLanguageName] are human-readable names (e.g.
  /// "French"), not ISO codes — the app's language list mixes real ISO
  /// 639-1 codes with 639-2/3 codes for languages that don't have a 639-1
  /// code at all, so asking the model to work from a name sidesteps having
  /// to claim a code standard it can't actually guarantee (see the prompt
  /// in server/src/routes/translate.routes.ts).
  Future<String> translate({
    required String text,
    required String fromLanguageName,
    required String toLanguageName,
  }) async {
    if (text.trim().isEmpty) return '';

    final response = await _client.post('/translate', data: {
      'text': text,
      'from': fromLanguageName,
      'to': toLanguageName,
    });

    if (response['success'] != true) {
      throw AppException(
          response['message'] as String? ?? 'Translation is temporarily unavailable. Please try again.');
    }
    return response['translated'] as String? ?? '';
  }
}
