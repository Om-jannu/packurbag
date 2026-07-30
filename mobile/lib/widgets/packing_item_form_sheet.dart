import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_exception.dart';
import '../models/packing_item.dart';
import '../providers/repository_providers.dart';
import '../providers/trip_providers.dart';
import '../utils.dart';
import 'app_text_field.dart';

const _packingCategories = [
  'Clothing',
  'Toiletries',
  'Electronics',
  'Documents',
  'Gear',
  'Accessories',
  'Other',
];

/// Add/edit form for a single packing item within a trip.
Future<void> showPackingItemFormSheet(
  BuildContext context, {
  required String userId,
  required String tripId,
  PackingItem? itemToEdit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => PackingItemFormSheet(
      userId: userId,
      tripId: tripId,
      itemToEdit: itemToEdit,
    ),
  );
}

class PackingItemFormSheet extends ConsumerStatefulWidget {
  const PackingItemFormSheet({
    super.key,
    required this.userId,
    required this.tripId,
    this.itemToEdit,
  });

  final String userId;
  final String tripId;
  final PackingItem? itemToEdit;

  @override
  ConsumerState<PackingItemFormSheet> createState() => _PackingItemFormSheetState();
}

class _PackingItemFormSheetState extends ConsumerState<PackingItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _textController;
  late String _category;
  bool _isSubmitting = false;

  bool get _isEditing => widget.itemToEdit != null;

  @override
  void initState() {
    super.initState();
    final editing = widget.itemToEdit;
    _textController = TextEditingController(text: editing?.text ?? '');
    _category = editing?.category ?? _packingCategories.first;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final repo = ref.read(packingRepositoryProvider);
    final text = capitalizeWords(_textController.text);
    try {
      if (_isEditing) {
        await repo.updateItem(
          userId: widget.userId,
          tripId: widget.tripId,
          itemId: widget.itemToEdit!.id,
          text: text,
          category: _category,
        );
      } else {
        await repo.addItem(
          userId: widget.userId,
          tripId: widget.tripId,
          text: text,
          category: _category,
        );
      }
      if (!mounted) return;
      ref.invalidate(tripsProvider(widget.userId));
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
      await ref.read(packingRepositoryProvider).deleteItem(
            userId: widget.userId,
            tripId: widget.tripId,
            itemId: widget.itemToEdit!.id,
          );
      if (!mounted) return;
      ref.invalidate(tripsProvider(widget.userId));
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
              _isEditing ? 'Edit packing item' : 'Add packing item',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _textController,
              label: 'Item',
              validator: (v) => Validators.required(v, field: 'Item'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _packingCategories.map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: category == _category,
                  onSelected: (_) => setState(() => _category = category),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_isEditing) ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: _isSubmitting ? null : _delete,
                icon: const Icon(LucideIcons.trash2),
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
