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

/// Capitalizes the first letter of each word, so freeform input like
/// "new york trip" is shown as "New York Trip" wherever it's displayed.
String capitalizeWords(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed.split(RegExp(r'\s+')).map((word) {
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}

