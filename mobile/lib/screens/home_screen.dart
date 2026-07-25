import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/repositories/weather_repository.dart';
import '../models/itinerary_item.dart';
import '../models/trip.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/trip_providers.dart';
import '../widgets/category_color.dart';
import '../widgets/empty_state.dart';
import '../widgets/trip_calendar_card.dart';
import '../widgets/trip_form_sheet.dart';

final _weatherByCityProvider = FutureProvider.family<Weather, String>((ref, city) {
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
      final start = DateTime(t.startDate.year, t.startDate.month, t.startDate.day);
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
        if (!item.completed && !item.date.isBefore(now) && item.date.isBefore(weekFromNow)) {
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
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/packurbag-logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('Packurbag'),
          ],
        ),
      ),
      body: tripsAsync == null
          ? const SizedBox.shrink()
          : tripsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (trips) {
                final nextTrip = _nextTrip(trips);
                final selectedDayTrips =
                    _tripsOnDay(trips, _selectedDay ?? _focusedDay);
                final upcomingItinerary = _upcomingItinerary(trips);
                final ongoingCount =
                    trips.where((t) => _tripsOnDay([t], DateTime.now()).isNotEmpty).length;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (nextTrip == null)
                      EmptyState(
                        icon: Icons.card_travel,
                        title: 'No upcoming trips',
                        message: 'Plan your next adventure to see it here.',
                        action: FilledButton.icon(
                          onPressed: () => showTripFormSheet(context, userId: userId!),
                          icon: const Icon(Icons.add),
                          label: const Text('Plan a trip'),
                        ),
                      )
                    else ...[
                      _CountdownCard(trip: nextTrip),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _WeatherCard(destination: nextTrip.destination)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _CurrencySnippetCard(targetCurrency: nextTrip.budgetCurrency),
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
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
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
                      onMonthChanged: (month) => setState(() => _focusedDay = month),
                    ),
                    if (selectedDayTrips.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      for (final trip in selectedDayTrips)
                        Card(
                          margin: const EdgeInsets.only(top: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: parseCategoryColor(trip.coverColor),
                            ),
                            title: Text(trip.title),
                            subtitle: Text(trip.destination),
                            onTap: () => context.push('/trips/detail', extra: trip),
                          ),
                        ),
                    ],
                    if (upcomingItinerary.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Coming up this week',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Column(
                          children: [
                            for (final entry in upcomingItinerary)
                              ListTile(
                                leading: Icon(Icons.event_outlined,
                                    color: parseCategoryColor(entry.trip.coverColor)),
                                title: Text(entry.item.text),
                                subtitle: Text(
                                  '${entry.trip.title} · ${DateFormat('E, d MMM').format(entry.item.date)}',
                                ),
                                onTap: () =>
                                    context.push('/trips/detail', extra: entry.trip),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'Quick actions',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const _QuickActionsRow(),
                  ],
                );
              },
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
    final isOngoing = !now.isBefore(trip.startDate) && !now.isAfter(trip.endDate);
    final daysUntil = trip.startDate.difference(today).inDays;

    return Card(
      color: color.withValues(alpha: 0.15),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/trips/detail', extra: trip),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOngoing ? "You're in ${trip.destination}!" : 'Next up',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
              ),
              const SizedBox(height: 6),
              Text(
                trip.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 16, color: color),
                  const SizedBox(width: 4),
                  Text(trip.destination),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isOngoing ? 'Enjoy your trip!' : 'In $daysUntil day${daysUntil == 1 ? '' : 's'}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700, color: color),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: weatherAsync.when(
          loading: () => const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (error, _) => Row(
            children: [
              Icon(Icons.cloud_off_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Weather unavailable for $destination',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          data: (weather) => Row(
            children: [
              Image.network(weather.iconUrl, width: 48, height: 48,
                  errorBuilder: (_, _, _) {
                return const Icon(Icons.wb_sunny_outlined, size: 32);
              }),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.tempCelsius.round()}°C in ${weather.cityName}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      weather.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ratesAsync.when(
          loading: () => const SizedBox(
            height: 24,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (error, _) => Text(
            'Currency rates unavailable',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          data: (rates) {
            if (!rates.containsKey('INR') || !rates.containsKey(targetCurrency)) {
              return const SizedBox.shrink();
            }
            final converted = ref.read(currencyRepositoryProvider).convert(
                  amount: 1,
                  from: 'INR',
                  to: targetCurrency,
                  usdBaseRates: rates,
                );
            return Row(
              children: [
                Icon(Icons.currency_exchange, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  '1 INR ≈ ${converted.toStringAsFixed(4)} $targetCurrency',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            );
          },
        ),
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
            icon: Icons.card_travel,
            label: 'Trips',
            value: '$tripCount',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.flight_takeoff,
            label: 'Ongoing',
            value: '$ongoingCount',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.luggage_outlined,
            label: 'Packed',
            value: totalPacking == 0 ? '—' : '$packed/$totalPacking',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(value,
                style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            icon: Icons.card_travel,
            label: 'Trips',
            onTap: () => context.go('/trips'),
          ),
        ),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.translate,
            label: 'Translate',
            onTap: () => context.go('/translate'),
          ),
        ),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.smart_toy_outlined,
            label: 'Assistant',
            onTap: () => context.push('/ai-chat'),
          ),
        ),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.warning_amber_rounded,
            label: 'SOS',
            onTap: () => context.push('/sos'),
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
