import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/app_exception.dart';
import '../data/packing_templates.dart';
import '../models/expense.dart';
import '../models/itinerary_item.dart';
import '../models/packing_item.dart';
import '../models/travel_document.dart';
import '../models/trip.dart';
import '../providers/auth_provider.dart';
import '../providers/documents_providers.dart';
import '../providers/repository_providers.dart';
import '../providers/trip_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/category_color.dart';
import '../widgets/document_form_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_form_sheet.dart';
import '../widgets/itinerary_item_form_sheet.dart';
import '../widgets/packing_item_form_sheet.dart';
import '../widgets/photo_viewer_page.dart';
import '../widgets/priority_badge.dart';
import '../widgets/trip_form_sheet.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({super.key, required this.trip});

  final Trip trip;

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addForCurrentTab(BuildContext context, String userId, Trip trip) {
    switch (_tabController.index) {
      case 0:
        showItineraryItemFormSheet(context, userId: userId, tripId: trip.id);
      case 1:
        showPackingItemFormSheet(context, userId: userId, tripId: trip.id);
      case 2:
        showExpenseFormSheet(
          context,
          userId: userId,
          tripId: trip.id,
          defaultCurrency: trip.budgetCurrency,
        );
      case 3:
        showDocumentFormSheet(context, userId: userId, tripId: trip.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider).value?.id;
    // Re-read the latest version of this trip so edits made elsewhere show
    // up without re-navigating.
    final tripsAsync = userId == null ? null : ref.watch(tripsProvider(userId));
    final liveTrip = tripsAsync?.value?.firstWhere(
          (t) => t.id == widget.trip.id,
          orElse: () => widget.trip,
        ) ??
        widget.trip;
    final color = parseCategoryColor(liveTrip.coverColor);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: color.withValues(alpha: 0.15),
              padding: const EdgeInsets.fromLTRB(4, 8, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary(context)),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      liveTrip.title,
                      style: AppTextStyles.appBarTitle(color: AppTheme.textPrimary(context)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (userId != null)
                    IconButton(
                      icon: Icon(LucideIcons.pencil, color: AppTheme.textPrimary(context)),
                      tooltip: 'Edit trip',
                      onPressed: () =>
                          showTripFormSheet(context, userId: userId, tripToEdit: liveTrip),
                    ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderMuted(context))),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: color,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: color,
                unselectedLabelColor: AppTheme.textMuted(context, opacity: 0.4),
                labelStyle: AppTextStyles.label(weight: FontWeight.w700),
                unselectedLabelStyle: AppTextStyles.label(weight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'Itinerary'),
                  Tab(text: 'Packing'),
                  Tab(text: 'Budget'),
                  Tab(text: 'Documents'),
                ],
              ),
            ),
            Expanded(
              child: userId == null
                  ? const SizedBox.shrink()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _ItineraryTab(userId: userId, trip: liveTrip, color: color),
                        _PackingTab(userId: userId, trip: liveTrip, color: color),
                        _BudgetTab(userId: userId, trip: liveTrip, color: color),
                        _DocumentsTab(userId: userId, trip: liveTrip, color: color),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: userId == null
          ? null
          : FloatingActionButton(
              backgroundColor: color,
              shape: const CircleBorder(),
              onPressed: () => _addForCurrentTab(context, userId, liveTrip),
              child: const Icon(LucideIcons.plus),
            ),
    );
  }
}

/// A plain filled dot/dash toggle — replaces Material's `Checkbox` (which
/// always renders a checkmark glyph) with the design reference's exact
/// look: an outlined circle/rounded-square that fills solid with a small
/// centered white dot when checked, no checkmark icon at all.
class _DotToggle extends StatelessWidget {
  const _DotToggle({
    required this.value,
    required this.color,
    required this.onChanged,
    this.shape = BoxShape.circle,
  });

  final bool value;
  final Color color;
  final BoxShape shape;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(6) : null,
          color: value ? color : Colors.transparent,
          border: value ? null : Border.all(color: AppTheme.textMuted(context, opacity: 0.3), width: 2),
        ),
        child: value
            ? Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              )
            : null,
      ),
    );
  }
}

class _ItineraryTab extends ConsumerWidget {
  const _ItineraryTab({required this.userId, required this.trip, required this.color});

  final String userId;
  final Trip trip;
  final Color color;

  Future<void> _toggleCompleted(WidgetRef ref, ItineraryItem item, bool completed) async {
    try {
      await ref.read(itineraryRepositoryProvider).setCompleted(
            userId: userId,
            tripId: trip.id,
            itemId: item.id,
            completed: completed,
          );
      ref.invalidate(tripsProvider(userId));
    } on AppException catch (_) {
      // the next refetch reflects the true server state either way
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (trip.itinerary.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.listChecks,
        title: 'No itinerary items yet',
        message: 'Tap the + button to plan your first activity.',
      );
    }

    final grouped = <String, List<ItineraryItem>>{};
    for (final item in trip.itinerary) {
      final key = item.date.toLocal().toString().substring(0, 10);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    final dateKeys = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: dateKeys.length,
      itemBuilder: (context, index) {
        final dateKey = dateKeys[index];
        final items = grouped[dateKey]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                DateFormat('EEEE, d MMMM').format(DateTime.parse(dateKey)),
                style: AppTextStyles.label(
                  weight: FontWeight.w700,
                  color: AppTheme.textMuted(context, opacity: 0.5),
                ),
              ),
            ),
            for (final item in items)
              ListTile(
                onTap: () => showItineraryItemFormSheet(
                  context,
                  userId: userId,
                  tripId: trip.id,
                  itemToEdit: item,
                ),
                leading: _DotToggle(
                  value: item.completed,
                  color: color,
                  shape: BoxShape.circle,
                  onChanged: (value) => _toggleCompleted(ref, item, value),
                ),
                title: Text(
                  item.text,
                  style: AppTextStyles.body(
                    weight: FontWeight.w600,
                    color: item.completed
                        ? AppTheme.textMuted(context, opacity: 0.4)
                        : AppTheme.textPrimary(context),
                  ).copyWith(decoration: item.completed ? TextDecoration.lineThrough : null),
                ),
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PriorityBadge(priority: item.priority, compact: true),
                    if (item.location.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(LucideIcons.mapPin,
                          size: 14,
                          color: AppTheme.textMuted(context, opacity: 0.4)),
                      const SizedBox(width: 2),
                      Text(
                        item.location,
                        style: AppTextStyles.caption(color: AppTheme.textMuted(context, opacity: 0.4)),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PackingTab extends ConsumerWidget {
  const _PackingTab({required this.userId, required this.trip, required this.color});

  final String userId;
  final Trip trip;
  final Color color;

  Future<void> _applyTemplate(WidgetRef ref, BuildContext context, String templateName) async {
    final existing = trip.packingItems.map((i) => i.text.trim().toLowerCase()).toSet();
    final newItems = packingTemplates[templateName]!
        .where((item) => !existing.contains(item.$1.trim().toLowerCase()))
        .toList();

    if (newItems.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Those items are already on your list')),
        );
      }
      return;
    }

    try {
      await ref.read(packingRepositoryProvider).addItems(
            userId: userId,
            tripId: trip.id,
            items: newItems,
          );
      ref.invalidate(tripsProvider(userId));
    } on AppException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _togglePacked(WidgetRef ref, PackingItem item, bool packed) async {
    try {
      await ref.read(packingRepositoryProvider).setPacked(
            userId: userId,
            tripId: trip.id,
            itemId: item.id,
            packed: packed,
          );
      ref.invalidate(tripsProvider(userId));
    } on AppException catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = <String, List<PackingItem>>{};
    for (final item in trip.packingItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    final packedCount = trip.packingItems.where((i) => i.packed).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick-apply a template',
                style: AppTextStyles.label(
                  weight: FontWeight.w700,
                  color: AppTheme.textMuted(context, opacity: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: packingTemplates.keys.map((name) {
                  return ActionChip(
                    label: Text(name),
                    labelStyle: AppTextStyles.label(
                      weight: FontWeight.w600,
                      color: AppTheme.textPrimary(context),
                    ),
                    backgroundColor: AppTheme.surfaceInput(context),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    elevation: 0,
                    pressElevation: 0,
                    onPressed: () => _applyTemplate(ref, context, name),
                  );
                }).toList(),
              ),
              if (trip.packingItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: packedCount / trip.packingItems.length,
                    minHeight: 6,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.15),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$packedCount of ${trip.packingItems.length} packed',
                  style: AppTextStyles.caption(color: AppTheme.textMuted(context, opacity: 0.5)),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: trip.packingItems.isEmpty
              ? const EmptyState(
                  icon: LucideIcons.luggage,
                  title: 'Nothing on your packing list yet',
                  message: 'Apply a template above or tap + to add items.',
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: 96),
                  children: [
                    for (final entry in grouped.entries) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          entry.key,
                          style: AppTextStyles.label(
                            weight: FontWeight.w700,
                            color: AppTheme.textMuted(context, opacity: 0.4),
                          ),
                        ),
                      ),
                      for (final item in entry.value)
                        ListTile(
                          onTap: () => showPackingItemFormSheet(
                            context,
                            userId: userId,
                            tripId: trip.id,
                            itemToEdit: item,
                          ),
                          leading: _DotToggle(
                            value: item.packed,
                            color: color,
                            shape: BoxShape.rectangle,
                            onChanged: (value) => _togglePacked(ref, item, value),
                          ),
                          title: Text(
                            item.text,
                            style: AppTextStyles.body(
                              weight: FontWeight.w600,
                              color: item.packed
                                  ? AppTheme.textMuted(context, opacity: 0.4)
                                  : AppTheme.textPrimary(context),
                            ).copyWith(decoration: item.packed ? TextDecoration.lineThrough : null),
                          ),
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _BudgetTab extends ConsumerWidget {
  const _BudgetTab({required this.userId, required this.trip, required this.color});

  final String userId;
  final Trip trip;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(_usdRatesProvider);

    return ratesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildBody(context, ref, const {}),
      data: (rates) => _buildBody(context, ref, rates),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, Map<String, double> rates) {
    final currencyRepo = ref.read(currencyRepositoryProvider);
    double totalInBudgetCurrency = 0;
    for (final expense in trip.expenses) {
      totalInBudgetCurrency += rates.isEmpty
          ? expense.amount
          : currencyRepo.convert(
              amount: expense.amount,
              from: expense.currency,
              to: trip.budgetCurrency,
              usdBaseRates: rates,
            );
    }
    final budget = trip.budgetAmount;
    final remaining = budget == null ? null : budget - totalInBudgetCurrency;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Container(
          decoration: AppTheme.flatCard(context, color: color.withValues(alpha: 0.15)),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spent so far',
                style: AppTextStyles.label(
                  weight: FontWeight.w700,
                  color: AppTheme.textMuted(context, opacity: 0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${totalInBudgetCurrency.toStringAsFixed(2)} ${trip.budgetCurrency}',
                style: AppTextStyles.appBarTitle(color: AppTheme.textPrimary(context)),
              ),
              if (budget != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (totalInBudgetCurrency / budget).clamp(0, 1),
                    minHeight: 6,
                    color: (remaining ?? 0) < 0
                        ? Theme.of(context).colorScheme.error
                        : color,
                    backgroundColor: color.withValues(alpha: 0.15),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  remaining != null && remaining < 0
                      ? '${(-remaining).toStringAsFixed(2)} ${trip.budgetCurrency} over budget'
                      : '${remaining?.toStringAsFixed(2)} ${trip.budgetCurrency} remaining of ${budget.toStringAsFixed(0)}',
                  style: AppTextStyles.caption(color: AppTheme.textMuted(context, opacity: 0.5)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (trip.expenses.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 32),
            child: EmptyState(
              icon: LucideIcons.receipt,
              title: 'No expenses logged yet',
              message: 'Tap + to log your first expense.',
            ),
          )
        else
          for (final expense in [...trip.expenses]..sort((a, b) => b.date.compareTo(a.date)))
            _ExpenseTile(
              expense: expense,
              onTap: () => showExpenseFormSheet(
                context,
                userId: userId,
                tripId: trip.id,
                defaultCurrency: trip.budgetCurrency,
                expenseToEdit: expense,
              ),
              onDelete: () => ref.read(expenseRepositoryProvider).deleteExpense(
                    userId: userId,
                    tripId: trip.id,
                    expenseId: expense.id,
                  ),
            ),
      ],
    );
  }
}

final _usdRatesProvider = FutureProvider<Map<String, double>>((ref) {
  return ref.watch(currencyRepositoryProvider).fetchUsdBaseRates();
});

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense, required this.onTap, required this.onDelete});
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.flatCard(context, radius: AppTheme.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          leading: Icon(LucideIcons.receipt, color: AppTheme.textMuted(context, opacity: 0.4)),
          title: Text(
            expense.title,
            style: AppTextStyles.body(weight: FontWeight.w600, color: AppTheme.textPrimary(context)),
          ),
          subtitle: Text(
            '${expense.category} · ${DateFormat('d MMM').format(expense.date)}',
            style: AppTextStyles.caption(color: AppTheme.textMuted(context, opacity: 0.4)),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${expense.amount.toStringAsFixed(2)} ${expense.currency}',
                style: AppTextStyles.bodyBold(color: AppTheme.textPrimary(context)),
              ),
              IconButton(
                icon: Icon(LucideIcons.trash2, size: 18, color: AppTheme.textMuted(context, opacity: 0.4)),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _documentTypeLabels = {
  TravelDocumentType.passport: 'Passport',
  TravelDocumentType.visa: 'Visa',
  TravelDocumentType.ticket: 'Ticket',
  TravelDocumentType.insurance: 'Insurance',
  TravelDocumentType.other: 'Other',
};

const _documentTypeIcons = {
  TravelDocumentType.passport: LucideIcons.badgeCheck,
  TravelDocumentType.visa: LucideIcons.scrollText,
  TravelDocumentType.ticket: LucideIcons.ticket,
  TravelDocumentType.insurance: LucideIcons.shieldCheck,
  TravelDocumentType.other: LucideIcons.fileText,
};

class _DocumentsTab extends ConsumerWidget {
  const _DocumentsTab({required this.userId, required this.trip, required this.color});

  final String userId;
  final Trip trip;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = (userId: userId, tripId: trip.id);
    final documentsAsync = ref.watch(documentsProvider(ids));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Icon(LucideIcons.lock, size: 14, color: AppTheme.textMuted(context, opacity: 0.4)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Stored only on this device — never uploaded.',
                  style: AppTextStyles.caption(color: AppTheme.textMuted(context, opacity: 0.4)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: documentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('$error')),
            data: (documents) {
              if (documents.isEmpty) {
                return const EmptyState(
                  icon: LucideIcons.folderOpen,
                  title: 'No travel documents yet',
                  message: 'Tap + to save a passport, visa, ticket, or insurance reference.',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final document = documents[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: AppTheme.flatCard(context, radius: AppTheme.radiusMd),
                    clipBehavior: Clip.antiAlias,
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                      onTap: () => showDocumentFormSheet(
                        context,
                        userId: userId,
                        tripId: trip.id,
                        documentToEdit: document,
                      ),
                      leading: document.imagePath != null && !kIsWeb
                          ? GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PhotoViewerPage(
                                    imagePath: document.imagePath!,
                                    title: document.title,
                                  ),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(document.imagePath!),
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_documentTypeIcons[document.type], color: color),
                            ),
                      title: Text(
                        document.title,
                        style: AppTextStyles.body(
                          weight: FontWeight.w600,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      subtitle: Text(
                        document.notes.isEmpty
                            ? _documentTypeLabels[document.type]!
                            : '${_documentTypeLabels[document.type]} · ${document.notes}',
                        style: AppTextStyles.caption(color: AppTheme.textMuted(context, opacity: 0.4)),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(LucideIcons.trash2,
                                size: 18, color: AppTheme.textMuted(context, opacity: 0.4)),
                            onPressed: () => ref
                                .read(documentsRepositoryProvider)
                                .deleteDocument(userId: userId, documentId: document.id)
                                .then((_) => ref.invalidate(documentsProvider(ids))),
                          ),
                          Icon(LucideIcons.chevronRight, color: AppTheme.textMuted(context, opacity: 0.3)),
                        ],
                      ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
