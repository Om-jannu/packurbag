import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/category.dart';

/// Example event class

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
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

  final DateTime dateTime = DateTime.parse(dateString);
  final DateFormat formatter = DateFormat(' dd MMMM yyyy,E');
  return formatter.format(dateTime);
}
