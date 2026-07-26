import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../components/global_snackbar.dart';
import '../data/app_exception.dart';
import '../models/trip.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/trip_providers.dart';
import '../theme/app_theme.dart';
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
                  Text('My Trips', style: AppTextStyles.appBarTitle(color: AppTheme.textPrimary(context))),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: userId == null
                        ? null
                        : () => showTripFormSheet(context, userId: userId),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.accent(context).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.plus, size: 18, color: AppTheme.accent(context)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tripsAsync == null
                  ? const SizedBox.shrink()
                  : tripsAsync.when(
                      loading: () => _buildShimmerGrid(),
                      error: (error, _) => Center(child: Text('$error')),
                      data: (trips) {
                        if (trips.isEmpty) {
                          return EmptyState(
                            icon: LucideIcons.briefcase,
                            title: 'No trips yet',
                            message: 'Tap + to plan your first trip.',
                            action: FilledButton.icon(
                              onPressed: () => showTripFormSheet(context, userId: userId!),
                              icon: const Icon(LucideIcons.plus),
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
            ),
          ],
        ),
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

    final budget = trip.budgetAmount;
    final spent = trip.expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final isOverBudget = budget != null && spent > budget;
    final errorColor = Theme.of(context).colorScheme.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppTheme.surfaceMuted(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 6,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        style: AppTextStyles.label(
                          weight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(LucideIcons.mapPin,
                              size: 13, color: AppTheme.textMuted(context, opacity: 0.5)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              trip.destination,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption(
                                  color: AppTheme.textMuted(context, opacity: 0.5)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('d MMM').format(trip.startDate)} – ${DateFormat('d MMM yyyy').format(trip.endDate)}',
                        style: AppTextStyles.micro(color: AppTheme.textMuted(context, opacity: 0.4)),
                      ),
                      if (budget != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: (spent / budget).clamp(0, 1),
                            minHeight: 5,
                            color: isOverBudget ? errorColor : color,
                            backgroundColor: color.withValues(alpha: 0.15),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOverBudget
                              ? '${spent.toStringAsFixed(0)} / ${budget.toStringAsFixed(0)} ${trip.budgetCurrency} · over budget'
                              : '${spent.toStringAsFixed(0)} / ${budget.toStringAsFixed(0)} ${trip.budgetCurrency} spent',
                          style: AppTextStyles.micro(
                            weight: isOverBudget ? FontWeight.w700 : FontWeight.w500,
                            color: isOverBudget ? errorColor : AppTheme.textMuted(context, opacity: 0.4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Text(
                    countdownLabel,
                    style: AppTextStyles.tag(color: color),
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
