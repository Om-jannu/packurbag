import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import '../widgets/category_color.dart';
import '../widgets/document_form_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_form_sheet.dart';
import '../widgets/itinerary_item_form_sheet.dart';
import '../widgets/packing_item_form_sheet.dart';
import '../widgets/priority_badge.dart';

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
      appBar: AppBar(
        title: Text(liveTrip.title),
        backgroundColor: color.withValues(alpha: 0.2),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: color,
          labelColor: color,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Itinerary'),
            Tab(text: 'Packing'),
            Tab(text: 'Budget'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: userId == null
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
      floatingActionButton: userId == null
          ? null
          : FloatingActionButton(
              backgroundColor: color,
              onPressed: () => _addForCurrentTab(context, userId, liveTrip),
              child: const Icon(Icons.add),
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
        icon: Icons.checklist_rtl,
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
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                leading: Transform.scale(
                  scale: 1.15,
                  child: Checkbox(
                    shape: const CircleBorder(),
                    side: BorderSide(color: color),
                    activeColor: color,
                    value: item.completed,
                    onChanged: (value) => _toggleCompleted(ref, item, value ?? false),
                  ),
                ),
                title: Text(
                  item.text,
                  style: TextStyle(
                    decoration: item.completed ? TextDecoration.lineThrough : null,
                    color: item.completed
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PriorityBadge(priority: item.priority, compact: true),
                    if (item.location.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.place_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 2),
                      Text(item.location, style: Theme.of(context).textTheme.bodySmall),
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
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: packingTemplates.keys.map((name) {
                  return ActionChip(
                    label: Text(name),
                    onPressed: () => _applyTemplate(ref, context, name),
                  );
                }).toList(),
              ),
              if (trip.packingItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: packedCount / trip.packingItems.length,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 4),
                Text(
                  '$packedCount of ${trip.packingItems.length} packed',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: trip.packingItems.isEmpty
              ? const EmptyState(
                  icon: Icons.luggage_outlined,
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
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      for (final item in entry.value)
                        CheckboxListTile(
                          value: item.packed,
                          onChanged: (value) => _togglePacked(ref, item, value ?? false),
                          activeColor: color,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            item.text,
                            style: TextStyle(
                              decoration: item.packed ? TextDecoration.lineThrough : null,
                            ),
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Spent so far', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(
                  '${totalInBudgetCurrency.toStringAsFixed(2)} ${trip.budgetCurrency}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (budget != null) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (totalInBudgetCurrency / budget).clamp(0, 1),
                    color: (remaining ?? 0) < 0
                        ? Theme.of(context).colorScheme.error
                        : color,
                    backgroundColor: color.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remaining != null && remaining < 0
                        ? '${(-remaining).toStringAsFixed(2)} ${trip.budgetCurrency} over budget'
                        : '${remaining?.toStringAsFixed(2)} ${trip.budgetCurrency} remaining of ${budget.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (trip.expenses.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 32),
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No expenses logged yet',
              message: 'Tap + to log your first expense.',
            ),
          )
        else
          for (final expense in [...trip.expenses]..sort((a, b) => b.date.compareTo(a.date)))
            Dismissible(
              key: ValueKey(expense.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Theme.of(context).colorScheme.errorContainer,
                child: Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer),
              ),
              onDismissed: (_) => ref.read(expenseRepositoryProvider).deleteExpense(
                    userId: userId,
                    tripId: trip.id,
                    expenseId: expense.id,
                  ),
              child: _ExpenseTile(expense: expense),
            ),
      ],
    );
  }
}

final _usdRatesProvider = FutureProvider<Map<String, double>>((ref) {
  return ref.watch(currencyRepositoryProvider).fetchUsdBaseRates();
});

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense});
  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.receipt_outlined),
      title: Text(expense.title),
      subtitle: Text('${expense.category} · ${DateFormat('d MMM').format(expense.date)}'),
      trailing: Text(
        '${expense.amount.toStringAsFixed(2)} ${expense.currency}',
        style: const TextStyle(fontWeight: FontWeight.w700),
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
  TravelDocumentType.passport: Icons.badge_outlined,
  TravelDocumentType.visa: Icons.assignment_ind_outlined,
  TravelDocumentType.ticket: Icons.confirmation_number_outlined,
  TravelDocumentType.insurance: Icons.health_and_safety_outlined,
  TravelDocumentType.other: Icons.description_outlined,
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
              Icon(Icons.lock_outline, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Stored only on this device — never uploaded.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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
                  icon: Icons.folder_shared_outlined,
                  title: 'No travel documents yet',
                  message: 'Tap + to save a passport, visa, ticket, or insurance reference.',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final document = documents[index];
                  return Dismissible(
                    key: ValueKey(document.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.delete_outline,
                          color: Theme.of(context).colorScheme.onErrorContainer),
                    ),
                    onDismissed: (_) => ref
                        .read(documentsRepositoryProvider)
                        .deleteDocument(userId: userId, documentId: document.id)
                        .then((_) => ref.invalidate(documentsProvider(ids))),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: document.imagePath != null && !kIsWeb
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(document.imagePath!),
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(_documentTypeIcons[document.type], color: color),
                        title: Text(document.title),
                        subtitle: Text(
                          document.notes.isEmpty
                              ? _documentTypeLabels[document.type]!
                              : '${_documentTypeLabels[document.type]} · ${document.notes}',
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
