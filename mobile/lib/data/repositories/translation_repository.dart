import 'package:translator/translator.dart';

import '../app_exception.dart';

/// Wraps the `translator` package behind an interface. That package scrapes
/// Google Translate's public endpoint rather than using an official, paid
/// API — pub.dev's own listing calls it "educational purposes only" and
/// warns it can break at any time. Isolating it here means swapping to an
/// official API later only touches this one file.
class TranslationRepository {
  TranslationRepository() : _translator = GoogleTranslator();

  final GoogleTranslator _translator;

  Future<String> translate({
    required String text,
    required String fromLanguageCode,
    required String toLanguageCode,
  }) async {
    if (text.trim().isEmpty) return '';
    try {
      final translation = await _translator.translate(
        text,
        from: fromLanguageCode,
        to: toLanguageCode,
      );
      return translation.text;
    } catch (_) {
      throw const AppException(
          'Translation is temporarily unavailable. Please try again.');
    }
  }
}
