import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/app_exception.dart';
import '../models/itinerary_item.dart';
import '../providers/repository_providers.dart';
import '../providers/trip_providers.dart';
import '../utils.dart';
import 'app_text_field.dart';
import 'priority_badge.dart';

/// Add/edit form for a single itinerary item within a trip.
Future<void> showItineraryItemFormSheet(
  BuildContext context, {
  required String userId,
  required String tripId,
  ItineraryItem? itemToEdit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => ItineraryItemFormSheet(
      userId: userId,
      tripId: tripId,
      itemToEdit: itemToEdit,
    ),
  );
}

class ItineraryItemFormSheet extends ConsumerStatefulWidget {
  const ItineraryItemFormSheet({
    super.key,
    required this.userId,
    required this.tripId,
    this.itemToEdit,
  });

  final String userId;
  final String tripId;
  final ItineraryItem? itemToEdit;

  @override
  ConsumerState<ItineraryItemFormSheet> createState() => _ItineraryItemFormSheetState();
}

class _ItineraryItemFormSheetState extends ConsumerState<ItineraryItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _textController;
  late final TextEditingController _locationController;
  late DateTime _date;
  late int _priority;
  bool _isSubmitting = false;

  bool get _isEditing => widget.itemToEdit != null;

  @override
  void initState() {
    super.initState();
    final editing = widget.itemToEdit;
    _textController = TextEditingController(text: editing?.text ?? '');
    _locationController = TextEditingController(text: editing?.location ?? '');
    _date = editing?.date ?? DateTime.now();
    _priority = editing?.priority ?? TodoPriority.neutral.value;
  }

  @override
  void dispose() {
    _textController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final repo = ref.read(itineraryRepositoryProvider);
    final text = capitalizeWords(_textController.text);
    final location = capitalizeWords(_locationController.text);
    try {
      if (_isEditing) {
        await repo.updateItem(
          userId: widget.userId,
          tripId: widget.tripId,
          itemId: widget.itemToEdit!.id,
          text: text,
          date: _date,
          priority: _priority,
          location: location,
        );
      } else {
        await repo.addItem(
          userId: widget.userId,
          tripId: widget.tripId,
          text: text,
          date: _date,
          priority: _priority,
          location: location,
        );
      }
      ref.invalidate(tripsProvider(widget.userId));
      if (!mounted) return;
      Navigator.pop(context);
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(itineraryRepositoryProvider).deleteItem(
            userId: widget.userId,
            tripId: widget.tripId,
            itemId: widget.itemToEdit!.id,
          );
      ref.invalidate(tripsProvider(widget.userId));
      if (!mounted) return;
      Navigator.pop(context);
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? 'Edit itinerary item' : 'Add itinerary item',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _textController,
              label: 'What are you doing?',
              validator: (v) => Validators.required(v, field: 'This field'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _locationController,
              label: 'Location (optional)',
              prefixIcon: Icons.place_outlined,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TodoPriority.values.map((p) {
                return ChoiceChip(
                  label: Text(p.label),
                  selected: p.value == _priority,
                  onSelected: (_) => setState(() => _priority = p.value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(DateFormat('EEE, d MMM yyyy').format(_date)),
              trailing: TextButton(onPressed: _pickDate, child: const Text('Change')),
            ),
            const SizedBox(height: 16),
            if (_isEditing) ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: _isSubmitting ? null : _delete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete item'),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save changes' : 'Add item'),
            ),
          ],
        ),
      ),
    );
  }
}
