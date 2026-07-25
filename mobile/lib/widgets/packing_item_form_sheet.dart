import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_exception.dart';
import '../providers/repository_providers.dart';
import '../providers/trip_providers.dart';
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

Future<void> showPackingItemFormSheet(
  BuildContext context, {
  required String userId,
  required String tripId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => PackingItemFormSheet(userId: userId, tripId: tripId),
  );
}

class PackingItemFormSheet extends ConsumerStatefulWidget {
  const PackingItemFormSheet({super.key, required this.userId, required this.tripId});

  final String userId;
  final String tripId;

  @override
  ConsumerState<PackingItemFormSheet> createState() => _PackingItemFormSheetState();
}

class _PackingItemFormSheetState extends ConsumerState<PackingItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  String _category = _packingCategories.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(packingRepositoryProvider).addItem(
            userId: widget.userId,
            tripId: widget.tripId,
            text: _textController.text.trim(),
            category: _category,
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
              'Add packing item',
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
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add item'),
            ),
          ],
        ),
      ),
    );
  }
}
