import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Example event class

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

// Map priority numbers to corresponding text labels
final Map<int, String> priorityLabels = {
  0: 'Trivial',
  1: 'low',
  2: 'Neutral',
  3: 'High',
  4: 'Critical',
};
String formattedDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '';

  final DateTime dateTime = DateTime.parse(dateString).toLocal();
  final DateFormat formatter = DateFormat(' dd MMMM yyyy,E');
  return formatter.format(dateTime);
}

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
