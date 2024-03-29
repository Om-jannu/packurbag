import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({Key? key}) : super(key: key);

  @override
  _TranslationPageState createState() => _TranslationPageState();
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
  final GoogleTranslator _translator = GoogleTranslator();
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
    String inputText = _inputController.text;
    if (inputText.isNotEmpty) {
      Translation translation = await _translator.translate(
        inputText,
        from: _sourceLanguage,
        to: _targetLanguage,
      );
      setState(() {
        _outputController.text = translation.text;
      });
      await _speak(translation.text, _targetLanguage);
    }
  }

  void _showLanguageBottomSheet(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Language',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filteredLanguages = _languages
                            .where((lang) => lang['name']!
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    }),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredLanguages.length,
                  itemBuilder: (context, index) {
                    final language = _filteredLanguages[index];
                    return ListTile(
                      title: Text(language['name']!),
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
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Translation'),
      ),
      floatingActionButton: AvatarGlow(
        animate: _speechToText.isListening,
        glowColor: Colors.blue,
        glowShape: BoxShape.circle,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          shape: CircleBorder(),
          onPressed:
              _speechToText.isNotListening ? _startListening : _stopListening,
          tooltip: 'Listen',
          child: Icon(_speechToText.isNotListening ? Icons.mic : Icons.mic_off),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showLanguageBottomSheet(context, 'source'),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white.withOpacity(0.8),
                      ),
                      child: Text(
                        _getLanguageName(_sourceLanguage),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: _toggleLanguages,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: FaIcon(
                        FontAwesomeIcons.arrowsRotate,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showLanguageBottomSheet(context, 'target'),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white.withOpacity(0.8),
                      ),
                      child: Text(
                        _getLanguageName(_targetLanguage),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
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
              decoration: InputDecoration(
                labelText: 'Enter Text to Translate',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _inputController.clear();
                    _outputController.clear();
                  },
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _translateText,
              child: const Text('Translate'),
            ),
            const SizedBox(height: 16),
            Visibility(
              visible: _outputController.text.isNotEmpty,
              child: TextField(
                controller: _outputController,
                decoration: const InputDecoration(
                  labelText: 'Translated Text',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                readOnly: true,
              ),
            ),
          ],
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
