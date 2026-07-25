import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../components/global_snackbar.dart';
import '../data/app_exception.dart';
import '../models/trip.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/trip_providers.dart';
import '../widgets/category_color.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_shimmer_card.dart';
import '../widgets/trip_form_sheet.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String userId,
    Trip trip,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete trip?'),
        content: Text(
            '"${trip.title}" and everything in it (itinerary, packing list, expenses) will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(tripRepositoryProvider)
                    .deleteTrip(userId: userId, tripId: trip.id);
                ref.invalidate(tripsProvider(userId));
              } on AppException catch (error) {
                if (context.mounted) GlobalSnackbar.show(context, error.message);
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).value?.id;
    final tripsAsync = userId == null ? null : ref.watch(tripsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: userId == null
                ? null
                : () => showTripFormSheet(context, userId: userId),
          ),
        ],
      ),
      body: tripsAsync == null
          ? const SizedBox.shrink()
          : tripsAsync.when(
              loading: () => _buildShimmerGrid(),
              error: (error, _) => Center(child: Text('$error')),
              data: (trips) {
                if (trips.isEmpty) {
                  return EmptyState(
                    icon: Icons.card_travel,
                    title: 'No trips yet',
                    message: 'Tap + to plan your first trip.',
                    action: FilledButton.icon(
                      onPressed: () => showTripFormSheet(context, userId: userId!),
                      icon: const Icon(Icons.add),
                      label: const Text('New trip'),
                    ),
                  );
                }
                final sorted = [...trips]
                  ..sort((a, b) => a.startDate.compareTo(b.startDate));
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final trip = sorted[index];
                    return _TripCard(
                      trip: trip,
                      onTap: () => context.push('/trips/detail', extra: trip),
                      onLongPress: () =>
                          _showDeleteConfirmation(context, ref, userId!, trip),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildShimmerGrid() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LoadingShimmerCard(height: 120),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.onTap, required this.onLongPress});

  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final color = parseCategoryColor(trip.coverColor);
    final now = DateTime.now();
    final daysUntil = trip.startDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    final isOngoing = !now.isBefore(trip.startDate) && !now.isAfter(trip.endDate);
    final countdownLabel = isOngoing
        ? 'Happening now'
        : daysUntil >= 0
            ? 'In $daysUntil day${daysUntil == 1 ? '' : 's'}'
            : 'Past trip';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.place_outlined,
                              size: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            trip.destination,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('d MMM').format(trip.startDate)} – ${DateFormat('d MMM yyyy').format(trip.endDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    countdownLabel,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
