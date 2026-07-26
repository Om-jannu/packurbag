import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../models/trip.dart';
import '../theme/app_theme.dart';
import 'category_color.dart';

bool _isSameDate(DateTime? a, DateTime b) {
  return a != null && a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Compact, branded month calendar — a custom replacement for the generic
/// TableCalendar widget, with days that light up in the color of whichever
/// trip covers them and a single filled indicator for the selected day.
class TripCalendarCard extends StatelessWidget {
  const TripCalendarCard({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.tripsOnDay,
    required this.onDaySelected,
    required this.onMonthChanged,
  });

  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final List<Trip> Function(DateTime day) tripsOnDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday - 1; // Monday-start week

    final activeDay = selectedDay ?? focusedMonth;
    final dayTrips = tripsOnDay(activeDay);

    return Container(
      decoration: AppTheme.flatCard(context),
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(LucideIcons.chevronLeft, color: AppTheme.textPrimary(context)),
                onPressed: () =>
                    onMonthChanged(DateTime(focusedMonth.year, focusedMonth.month - 1)),
              ),
              Text(
                DateFormat('MMMM yyyy').format(focusedMonth),
                style: AppTextStyles.label(color: AppTheme.textPrimary(context)),
              ),
              IconButton(
                icon: Icon(LucideIcons.chevronRight, color: AppTheme.textPrimary(context)),
                onPressed: () =>
                    onMonthChanged(DateTime(focusedMonth.year, focusedMonth.month + 1)),
              ),
            ],
          ),
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: AppTextStyles.micro(color: AppTheme.textMuted(context, opacity: 0.4)),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
              for (var day = 1; day <= daysInMonth; day++) _buildDay(context, day),
            ],
          ),
          if (dayTrips.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final trip in dayTrips)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: parseCategoryColor(trip.coverColor),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        trip.title.isNotEmpty ? trip.title[0] : '?',
                        style: AppTextStyles.micro(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trip.title, style: AppTextStyles.label(color: AppTheme.textPrimary(context))),
                          Text(trip.destination, style: AppTextStyles.micro(color: AppTheme.textMuted(context, opacity: 0.4))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDay(BuildContext context, int day) {
    final date = DateTime(focusedMonth.year, focusedMonth.month, day);
    final trips = tripsOnDay(date);
    final isSelected = _isSameDate(selectedDay, date);
    final tripColor = trips.isEmpty ? null : parseCategoryColor(trips.first.coverColor);
    final highlighted = isSelected || tripColor != null;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onDaySelected(date),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppTheme.accentStrong(context) : tripColor,
            border: isSelected && tripColor != null
                ? Border.all(color: tripColor, width: 2)
                : null,
          ),
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 12,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppTheme.onAccentStrong(context)
                  : highlighted
                      ? Colors.white
                      : AppTheme.textMuted(context, opacity: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
