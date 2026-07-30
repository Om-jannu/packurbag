import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_exception.dart';
import '../models/expense.dart';
import '../providers/expense_receipts_providers.dart';
import '../providers/repository_providers.dart';
import '../providers/trip_providers.dart';
import '../utils.dart';
import 'app_text_field.dart';
import 'multi_photo_picker.dart';

const _expenseCategories = [
  'Lodging',
  'Food',
  'Transport',
  'Activities',
  'Shopping',
  'Other',
];

/// Add/edit form for a single expense within a trip.
Future<void> showExpenseFormSheet(
  BuildContext context, {
  required String userId,
  required String tripId,
  required String defaultCurrency,
  Expense? expenseToEdit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => ExpenseFormSheet(
      userId: userId,
      tripId: tripId,
      defaultCurrency: defaultCurrency,
      expenseToEdit: expenseToEdit,
    ),
  );
}

class ExpenseFormSheet extends ConsumerStatefulWidget {
  const ExpenseFormSheet({
    super.key,
    required this.userId,
    required this.tripId,
    required this.defaultCurrency,
    this.expenseToEdit,
  });

  final String userId;
  final String tripId;
  final String defaultCurrency;
  final Expense? expenseToEdit;

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;
  late String _category;
  List<String> _existingPhotoPaths = [];
  final List<XFile> _newPhotos = [];
  bool _isSubmitting = false;

  bool get _isEditing => widget.expenseToEdit != null;

  @override
  void initState() {
    super.initState();
    final editing = widget.expenseToEdit;
    _titleController = TextEditingController(text: editing?.title ?? '');
    _amountController = TextEditingController(
      text: editing?.amount.toStringAsFixed(0) ?? '',
    );
    _currencyController = TextEditingController(
      text: editing?.currency ?? widget.defaultCurrency,
    );
    _category = editing?.category ?? _expenseCategories.first;
    if (editing != null) {
      ref
          .read(expenseReceiptsRepositoryProvider)
          .fetchReceiptPhotos(userId: widget.userId, expenseId: editing.id)
          .then((photos) {
            if (mounted) setState(() => _existingPhotoPaths = photos);
          });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final repo = ref.read(expenseRepositoryProvider);
    final receiptsRepo = ref.read(expenseReceiptsRepositoryProvider);
    final title = capitalizeWords(_titleController.text);
    final amount = double.parse(_amountController.text.trim());
    final currency = _currencyController.text.trim().toUpperCase();
    try {
      String expenseId;
      if (_isEditing) {
        expenseId = widget.expenseToEdit!.id;
        await repo.updateExpense(
          userId: widget.userId,
          tripId: widget.tripId,
          expenseId: expenseId,
          title: title,
          amount: amount,
          currency: currency,
          category: _category,
        );
      } else {
        final created = await repo.addExpense(
          userId: widget.userId,
          tripId: widget.tripId,
          title: title,
          amount: amount,
          currency: currency,
          category: _category,
        );
        expenseId = created.id;
      }
      if (_existingPhotoPaths.isNotEmpty || _newPhotos.isNotEmpty) {
        await receiptsRepo.saveReceiptPhotos(
          userId: widget.userId,
          expenseId: expenseId,
          existingPhotoPaths: _existingPhotoPaths,
          newPhotos: _newPhotos,
        );
      }
      ref.invalidate(tripsProvider(widget.userId));
      ref.invalidate(
        expenseReceiptsProvider((userId: widget.userId, expenseId: expenseId)),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _isSubmitting = true);
    try {
      final expenseId = widget.expenseToEdit!.id;
      await ref
          .read(expenseRepositoryProvider)
          .deleteExpense(
            userId: widget.userId,
            tripId: widget.tripId,
            expenseId: expenseId,
          );
      await ref
          .read(expenseReceiptsRepositoryProvider)
          .deleteReceiptPhotos(userId: widget.userId, expenseId: expenseId);
      ref.invalidate(tripsProvider(widget.userId));
      ref.invalidate(
        expenseReceiptsProvider((userId: widget.userId, expenseId: expenseId)),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Edit expense' : 'Add expense',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _titleController,
                label: 'What was it for?',
                validator: (v) => Validators.required(v, field: 'This field'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      controller: _amountController,
                      label: 'Amount',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        final parsed = double.tryParse(v ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _currencyController,
                      label: 'Currency',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _expenseCategories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: category == _category,
                    onSelected: (_) => setState(() => _category = category),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              MultiPhotoPicker(
                existingPhotoPaths: _existingPhotoPaths,
                newPhotos: _newPhotos,
                onRemoveExisting: (path) =>
                    setState(() => _existingPhotoPaths.remove(path)),
                onRemoveNew: (photo) =>
                    setState(() => _newPhotos.remove(photo)),
                onPhotosPicked: (photos) =>
                    setState(() => _newPhotos.addAll(photos)),
              ),
              const SizedBox(height: 20),
              if (_isEditing) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: _isSubmitting ? null : _delete,
                  icon: const Icon(LucideIcons.trash2),
                  label: const Text('Delete expense'),
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
                    : Text(_isEditing ? 'Save changes' : 'Add expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
