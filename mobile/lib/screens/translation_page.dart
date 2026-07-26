import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../data/api_client.dart';
import '../data/app_exception.dart';
import '../data/repositories/translation_repository.dart';
import '../theme/app_theme.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'de', 'name': 'German'},
    {'code': 'ar', 'name': 'Arabic'},
    {'code': 'it', 'name': 'Italian'},
    {'code': 'ja', 'name': 'Japanese'},
    {'code': 'ko', 'name': 'Korean'},
    {'code': 'pt', 'name': 'Portuguese'},
    {'code': 'ru', 'name': 'Russian'},
    {'code': 'hi', 'name': 'Hindi'},
    {'code': 'bn', 'name': 'Bengali'},
    {'code': 'tr', 'name': 'Turkish'},
    {'code': 'nl', 'name': 'Dutch'},
    {'code': 'vi', 'name': 'Vietnamese'},
    {'code': 'th', 'name': 'Thai'},
    {'code': 'id', 'name': 'Indonesian'},
    {'code': 'sv', 'name': 'Swedish'},
    {'code': 'fi', 'name': 'Finnish'},
    {'code': 'no', 'name': 'Norwegian'},
    {'code': 'da', 'name': 'Danish'},
    {'code': 'pl', 'name': 'Polish'},
    {'code': 'el', 'name': 'Greek'},
    {'code': 'hu', 'name': 'Hungarian'},
    {'code': 'cs', 'name': 'Czech'},
    {'code': 'ro', 'name': 'Romanian'},
    {'code': 'he', 'name': 'Hebrew'},
    {'code': 'sk', 'name': 'Slovak'},
    {'code': 'uk', 'name': 'Ukrainian'},
    {'code': 'ms', 'name': 'Malay'},
    {'code': 'fil', 'name': 'Filipino (Tagalog)'},
    {'code': 'af', 'name': 'Afrikaans'},
    {'code': 'bg', 'name': 'Bulgarian'},
    {'code': 'ca', 'name': 'Catalan'},
    {'code': 'hr', 'name': 'Croatian'},
    {'code': 'et', 'name': 'Estonian'},
    {'code': 'sw', 'name': 'Swahili'},
    {'code': 'lt', 'name': 'Lithuanian'},
    {'code': 'lv', 'name': 'Latvian'},
    {'code': 'sr', 'name': 'Serbian'},
    {'code': 'sl', 'name': 'Slovenian'},
    {'code': 'iw', 'name': 'Yiddish'},
    {'code': 'fa', 'name': 'Persian'},
    {'code': 'sq', 'name': 'Albanian'},
    {'code': 'am', 'name': 'Amharic'},
    {'code': 'hy', 'name': 'Armenian'},
    {'code': 'az', 'name': 'Azerbaijani'},
    {'code': 'eu', 'name': 'Basque'},
    {'code': 'be', 'name': 'Belarusian'},
    {'code': 'bs', 'name': 'Bosnian'},
    {'code': 'ceb', 'name': 'Cebuano'},
    {'code': 'ny', 'name': 'Chichewa'},
    {'code': 'co', 'name': 'Corsican'},
    {'code': 'cy', 'name': 'Welsh'},
    {'code': 'eo', 'name': 'Esperanto'},
    {'code': 'fy', 'name': 'Frisian'},
    {'code': 'gl', 'name': 'Galician'},
    {'code': 'ka', 'name': 'Georgian'},
    {'code': 'gu', 'name': 'Gujarati'},
    {'code': 'ht', 'name': 'Haitian Creole'},
    {'code': 'ha', 'name': 'Hausa'},
    {'code': 'haw', 'name': 'Hawaiian'},
    {'code': 'ig', 'name': 'Igbo'},
    {'code': 'ga', 'name': 'Irish'},
    {'code': 'jw', 'name': 'Javanese'},
    {'code': 'kn', 'name': 'Kannada'},
    {'code': 'kk', 'name': 'Kazakh'},
    {'code': 'km', 'name': 'Khmer'},
    {'code': 'ku', 'name': 'Kurdish (Kurmanji)'},
    {'code': 'ky', 'name': 'Kyrgyz'},
    {'code': 'lo', 'name': 'Lao'},
    {'code': 'la', 'name': 'Latin'},
    {'code': 'lb', 'name': 'Luxembourgish'},
    {'code': 'mk', 'name': 'Macedonian'},
    {'code': 'mg', 'name': 'Malagasy'},
    {'code': 'ml', 'name': 'Malayalam'},
    {'code': 'mt', 'name': 'Maltese'},
    {'code': 'mi', 'name': 'Maori'},
    {'code': 'mr', 'name': 'Marathi'},
    {'code': 'mn', 'name': 'Mongolian'},
    {'code': 'my', 'name': 'Myanmar (Burmese)'},
    {'code': 'ne', 'name': 'Nepali'},
    {'code': 'ps', 'name': 'Pashto'},
    {'code': 'pa', 'name': 'Punjabi'},
    {'code': 'sm', 'name': 'Samoan'},
    {'code': 'gd', 'name': 'Scots Gaelic'},
    {'code': 'st', 'name': 'Sesotho'},
    {'code': 'sn', 'name': 'Shona'},
    {'code': 'sd', 'name': 'Sindhi'},
    {'code': 'si', 'name': 'Sinhala'},
    {'code': 'so', 'name': 'Somali'},
    {'code': 'su', 'name': 'Sundanese'},
    {'code': 'tg', 'name': 'Tajik'},
    {'code': 'ta', 'name': 'Tamil'},
    {'code': 'tt', 'name': 'Tatar'},
    {'code': 'te', 'name': 'Telugu'},
    {'code': 'to', 'name': 'Tongan'},
    {'code': 'tk', 'name': 'Turkmen'},
    {'code': 'ug', 'name': 'Uighur'},
    {'code': 'ur', 'name': 'Urdu'},
    {'code': 'uz', 'name': 'Uzbek'},
    {'code': 'xh', 'name': 'Xhosa'},
    {'code': 'yo', 'name': 'Yoruba'},
    {'code': 'zu', 'name': 'Zulu'},
  ];

  String _getLanguageName(String languageCode) {
    final language = _languages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => {'name': languageCode},
    );
    return language['name']!;
  }

  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TranslationRepository _translationRepository =
      TranslationRepository(ApiClient.instance);
  String _sourceLanguage = 'en'; // Default source language
  String _targetLanguage = 'fr'; // Default target language
  List<Map<String, String>> _filteredLanguages = [];
  String _lastWords = '';
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _filteredLanguages = _languages;
  }

  Future<void> _speak(String text, String language) async {
    await flutterTts.setLanguage(language);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  void _toggleLanguages() {
    setState(() {
      final String temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
  }

  void _translateText() async {
    FocusScope.of(context).unfocus();
    final inputText = _inputController.text;
    if (inputText.isEmpty) return;
    try {
      final translated = await _translationRepository.translate(
        text: inputText,
        fromLanguageCode: _sourceLanguage,
        toLanguageCode: _targetLanguage,
      );
      setState(() => _outputController.text = translated);
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  void _showLanguageBottomSheet(BuildContext context, String type) {
    _filteredLanguages = _languages;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Choose a language',
                          style: AppTextStyles.bodyBold(color: AppTheme.textPrimary(context)),
                        ),
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.x, color: AppTheme.textMuted(context, opacity: 0.4)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceInput(context),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: AppTextStyles.body(color: AppTheme.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText: 'Search language',
                        hintStyle: AppTextStyles.body(color: AppTheme.textMuted(context)),
                        prefixIcon: Icon(LucideIcons.search, color: AppTheme.textMuted(context)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        setSheetState(() {
                          _filteredLanguages = _languages
                              .where((lang) => lang['name']!
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredLanguages.length,
                      itemBuilder: (context, index) {
                        final language = _filteredLanguages[index];
                        return ListTile(
                          title: Text(
                            language['name']!,
                            style: AppTextStyles.body(color: AppTheme.textPrimary(context)),
                          ),
                          onTap: () {
                            setState(() {
                              if (type == 'source') {
                                _sourceLanguage = language['code']!;
                                // Set the appropriate keyboard type based on the selected language
                                _inputController.clear(); // Clear the input field
                              } else {
                                _targetLanguage = language['code']!;
                              }
                            });
                            _searchController.clear();
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              ),
            );
          },
        );
      },
    );
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        pauseFor: const Duration(seconds: 3),
      ),
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _inputController.text = _lastWords;
    });
    // The engine finalizes a result once it detects the user has stopped
    // speaking (per pauseFor above) — that's the natural trigger to
    // translate automatically, instead of requiring a separate tap.
    if (result.finalResult && _lastWords.isNotEmpty) {
      _translateText();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderMuted(context))),
              ),
              child: Row(
                children: [
                  Text(
                    'Language Translation',
                    style: AppTextStyles.appBarTitle(color: AppTheme.textPrimary(context)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showLanguageBottomSheet(context, 'source'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                color: AppTheme.accent(context).withValues(alpha: 0.1),
                              ),
                              child: Text(
                                _getLanguageName(_sourceLanguage),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.label(
                                  color: AppTheme.accent(context),
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Material(
                            color: AppTheme.surfaceInput(context),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _toggleLanguages,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  LucideIcons.arrowLeftRight,
                                  size: 18,
                                  color: AppTheme.accent(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showLanguageBottomSheet(context, 'target'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                color: AppTheme.accent(context).withValues(alpha: 0.1),
                              ),
                              child: Text(
                                _getLanguageName(_targetLanguage),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.label(
                                  color: AppTheme.accent(context),
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _inputController,
                      style: AppTextStyles.body(color: AppTheme.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText: 'Enter text to translate',
                        hintStyle: AppTextStyles.body(color: AppTheme.textMuted(context)),
                        filled: false,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: BorderSide(color: AppTheme.borderMuted(context)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: BorderSide(color: AppTheme.borderMuted(context)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: BorderSide(color: AppTheme.accent(context)),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(LucideIcons.x, color: AppTheme.textMuted(context)),
                          onPressed: () {
                            setState(() {
                              _inputController.clear();
                              _outputController.clear();
                            });
                          },
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _translateText,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentStrong(context),
                        foregroundColor: AppTheme.onAccentStrong(context),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        ),
                      ),
                      child: Text('Translate',
                          style: AppTextStyles.bodyBold(color: AppTheme.onAccentStrong(context))),
                    ),
                    if (_outputController.text.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        decoration: AppTheme.flatCard(context),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TRANSLATED TEXT',
                                  style: AppTextStyles.tag(color: AppTheme.textMuted(context, opacity: 0.4)),
                                ),
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(LucideIcons.volume2, size: 18, color: AppTheme.accent(context)),
                                    tooltip: 'Speak translation',
                                    onPressed: () =>
                                        _speak(_outputController.text, _targetLanguage),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _outputController.text,
                              style: AppTextStyles.body(color: AppTheme.textPrimary(context)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AvatarGlow(
        animate: _speechToText.isListening,
        glowColor: AppTheme.accentStrong(context).withValues(alpha: 0.4),
        glowShape: BoxShape.circle,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: AppTheme.accentStrong(context),
          foregroundColor: AppTheme.onAccentStrong(context),
          onPressed: !_speechEnabled
              ? null
              : _speechToText.isNotListening
                  ? _startListening
                  : _stopListening,
          tooltip: _speechEnabled ? 'Listen' : 'Speech recognition unavailable',
          child: Icon(_speechToText.isNotListening ? LucideIcons.mic : LucideIcons.micOff),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}
