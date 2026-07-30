import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../data/repositories/weather_repository.dart';
import '../models/itinerary_item.dart';
import '../models/trip.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/trip_providers.dart';
import '../theme/app_theme.dart';
import '../utils/sos_navigation.dart';
import '../widgets/category_color.dart';
import '../widgets/empty_state.dart';
import '../widgets/home_dashboard_shimmer.dart';
import '../widgets/trip_calendar_card.dart';
import '../widgets/trip_form_sheet.dart';

final _weatherByCityProvider = FutureProvider.family<Weather, String>((
  ref,
  city,
) {
  return ref.watch(weatherRepositoryProvider).fetchWeatherByCity(city);
});

final _inrRatesProvider = FutureProvider<Map<String, double>>((ref) {
  return ref.watch(currencyRepositoryProvider).fetchUsdBaseRates();
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Trip? _nextTrip(List<Trip> trips) {
    final now = DateTime.now();
    final upcoming = trips.where((t) => !t.endDate.isBefore(now)).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  List<Trip> _tripsOnDay(List<Trip> trips, DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return trips.where((t) {
      final start = DateTime(
        t.startDate.year,
        t.startDate.month,
        t.startDate.day,
      );
      final end = DateTime(t.endDate.year, t.endDate.month, t.endDate.day);
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();
  }

  List<({Trip trip, ItineraryItem item})> _upcomingItinerary(List<Trip> trips) {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    final entries = <({Trip trip, ItineraryItem item})>[];
    for (final trip in trips) {
      for (final item in trip.itinerary) {
        if (!item.completed &&
            !item.date.isBefore(now) &&
            item.date.isBefore(weekFromNow)) {
          entries.add((trip: trip, item: item));
        }
      }
    }
    entries.sort((a, b) => a.item.date.compareTo(b.item.date));
    return entries.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider).value?.id;
    final tripsAsync = userId == null ? null : ref.watch(tripsProvider(userId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderMuted(context)),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Image.asset(
                      'assets/packurbag-logo.png',
                      width: 26,
                      height: 26,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Packurbag',
                    style: AppTextStyles.appBarTitle(
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tripsAsync == null
                  ? const SizedBox.shrink()
                  : tripsAsync.when(
                      loading: () => const HomeDashboardShimmer(),
                      error: (error, _) => Center(child: Text('$error')),
                      data: (trips) {
                        final nextTrip = _nextTrip(trips);
                        final upcomingItinerary = _upcomingItinerary(trips);
                        final ongoingCount = trips
                            .where(
                              (t) =>
                                  _tripsOnDay([t], DateTime.now()).isNotEmpty,
                            )
                            .length;

                        return ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (nextTrip == null)
                              EmptyState(
                                icon: LucideIcons.briefcase,
                                title: 'No upcoming trips',
                                message:
                                    'Plan your next adventure to see it here.',
                                action: FilledButton.icon(
                                  onPressed: () => showTripFormSheet(
                                    context,
                                    userId: userId!,
                                  ),
                                  icon: const Icon(LucideIcons.plus),
                                  label: const Text('Plan a trip'),
                                ),
                              )
                            else ...[
                              _CountdownCard(trip: nextTrip),
                              const SizedBox(height: 12),
                              _WeatherCard(destination: nextTrip.destination),
                              const SizedBox(height: 12),
                              _CurrencySnippetCard(
                                targetCurrency: nextTrip.budgetCurrency,
                              ),
                            ],
                            const SizedBox(height: 20),
                            _QuickStatsRow(
                              tripCount: trips.length,
                              ongoingCount: ongoingCount,
                              nextTrip: nextTrip,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Trip calendar',
                              style: AppTextStyles.sectionTitle(
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TripCalendarCard(
                              focusedMonth: _focusedDay,
                              selectedDay: _selectedDay,
                              tripsOnDay: (day) => _tripsOnDay(trips, day),
                              onDaySelected: (day) => setState(() {
                                _selectedDay = day;
                                _focusedDay = day;
                              }),
                              onMonthChanged: (month) =>
                                  setState(() => _focusedDay = month),
                            ),
                            if (upcomingItinerary.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Text(
                                'Coming up this week',
                                style: AppTextStyles.sectionTitle(
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: AppTheme.flatCard(context),
                                clipBehavior: Clip.antiAlias,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: Column(
                                    children: [
                                      for (final entry in upcomingItinerary)
                                        ListTile(
                                          leading: Icon(
                                            LucideIcons.calendarClock,
                                            color: parseCategoryColor(
                                              entry.trip.coverColor,
                                            ),
                                          ),
                                          title: Text(
                                            entry.item.text,
                                            style: AppTextStyles.label(
                                              color: AppTheme.textPrimary(
                                                context,
                                              ),
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${entry.trip.title} · ${DateFormat('E, d MMM').format(entry.item.date)}',
                                            style: AppTextStyles.micro(
                                              color: AppTheme.textMuted(
                                                context,
                                                opacity: 0.4,
                                              ),
                                            ),
                                          ),
                                          onTap: () => context.push(
                                            '/trips/detail',
                                            extra: entry.trip,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Text(
                              'Quick actions',
                              style: AppTextStyles.sectionTitle(
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const _QuickActionsRow(),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final color = parseCategoryColor(trip.coverColor);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isOngoing =
        !now.isBefore(trip.startDate) && !now.isAfter(trip.endDate);
    final daysUntil = trip.startDate.difference(today).inDays;

    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: () => context.push('/trips/detail', extra: trip),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (isOngoing ? "You're in ${trip.destination}!" : 'Next up')
                    .toUpperCase(),
                style: AppTextStyles.tag(color: color),
              ),
              const SizedBox(height: 6),
              Text(
                trip.title,
                style: AppTextStyles.appBarTitle(
                  color: AppTheme.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(LucideIcons.mapPin, size: 15, color: color),
                  const SizedBox(width: 4),
                  Text(
                    trip.destination,
                    style: AppTextStyles.label(
                      color: AppTheme.textMuted(context, opacity: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isOngoing
                    ? 'Enjoy your trip!'
                    : 'In $daysUntil day${daysUntil == 1 ? '' : 's'}',
                style: AppTextStyles.bodyBold(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherCard extends ConsumerWidget {
  const _WeatherCard({required this.destination});
  final String destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(_weatherByCityProvider(destination));

    return Container(
      decoration: AppTheme.flatCard(context),
      padding: const EdgeInsets.all(14),
      child: weatherAsync.when(
        loading: () {
          final colorScheme = Theme.of(context).colorScheme;
          return Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerHigh,
            highlightColor: colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        error: (error, _) => Row(
          children: [
            Icon(LucideIcons.cloudOff, color: AppTheme.textMuted(context)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Weather unavailable for $destination',
                style: AppTextStyles.label(color: AppTheme.textMuted(context)),
              ),
            ),
          ],
        ),
        data: (weather) => Row(
          children: [
            Image.network(
              weather.iconUrl,
              width: 34,
              height: 34,
              errorBuilder: (_, _, _) {
                return Icon(
                  LucideIcons.cloudSun,
                  size: 26,
                  color: AppTheme.amber,
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.tempCelsius.round()}°C in ${weather.cityName}',
                    style: AppTextStyles.label(
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  Text(
                    weather.description,
                    style: AppTextStyles.micro(
                      color: AppTheme.textMuted(context, opacity: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencySnippetCard extends ConsumerWidget {
  const _CurrencySnippetCard({required this.targetCurrency});
  final String targetCurrency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (targetCurrency == 'INR') return const SizedBox.shrink();
    final ratesAsync = ref.watch(_inrRatesProvider);

    return Container(
      decoration: AppTheme.flatCard(context),
      padding: const EdgeInsets.all(14),
      child: ratesAsync.when(
        loading: () {
          final colorScheme = Theme.of(context).colorScheme;
          return Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerHigh,
            highlightColor: colorScheme.surfaceContainerHighest,
            child: Container(
              width: 160,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        },
        error: (error, _) => Text(
          'Currency rates unavailable',
          style: AppTextStyles.label(color: AppTheme.textMuted(context)),
        ),
        data: (rates) {
          if (!rates.containsKey('INR') || !rates.containsKey(targetCurrency)) {
            return const SizedBox.shrink();
          }
          final converted = ref
              .read(currencyRepositoryProvider)
              .convert(
                amount: 1,
                from: 'INR',
                to: targetCurrency,
                usdBaseRates: rates,
              );
          return Row(
            children: [
              Text('💱', style: AppTextStyles.appBarTitle()),
              const SizedBox(width: 10),
              Text(
                '1 INR ≈ ${converted.toStringAsFixed(4)} $targetCurrency',
                style: AppTextStyles.label(
                  color: AppTheme.textPrimary(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({
    required this.tripCount,
    required this.ongoingCount,
    required this.nextTrip,
  });

  final int tripCount;
  final int ongoingCount;
  final Trip? nextTrip;

  @override
  Widget build(BuildContext context) {
    final packed = nextTrip?.packingItems.where((i) => i.packed).length ?? 0;
    final totalPacking = nextTrip?.packingItems.length ?? 0;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: LucideIcons.briefcase,
            label: 'Trips',
            value: '$tripCount',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: LucideIcons.plane,
            label: 'Ongoing',
            value: '$ongoingCount',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: LucideIcons.luggage,
            label: 'Packed',
            value: totalPacking == 0 ? '—' : '$packed/$totalPacking',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.flatCard(context),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppTheme.accent(context)),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.appBarTitle(
              color: AppTheme.textPrimary(context),
            ),
          ),
          Text(
            label,
            style: AppTextStyles.micro(
              color: AppTheme.textMuted(context, opacity: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.flatCard(context),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickActionTile(
            icon: LucideIcons.briefcase,
            label: 'Trips',
            onTap: () => context.go('/trips'),
          ),
          _QuickActionTile(
            icon: LucideIcons.globe,
            label: 'Translate',
            onTap: () => context.go('/translate'),
          ),
          _QuickActionTile(
            icon: LucideIcons.bot,
            label: 'Assistant',
            onTap: () => context.push('/ai-chat'),
          ),
          _QuickActionTile(
            icon: LucideIcons.triangleAlert,
            label: 'SOS',
            onTap: () => navigateToSos(context),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.accent(context).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: AppTheme.accent(context)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.micro(
              color: AppTheme.textMuted(context, opacity: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
