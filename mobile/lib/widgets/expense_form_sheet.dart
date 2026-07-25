import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_exception.dart';
import '../providers/repository_providers.dart';
import '../providers/trip_providers.dart';
import 'app_text_field.dart';

const _expenseCategories = ['Lodging', 'Food', 'Transport', 'Activities', 'Shopping', 'Other'];

Future<void> showExpenseFormSheet(
  BuildContext context, {
  required String userId,
  required String tripId,
  required String defaultCurrency,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => ExpenseFormSheet(
      userId: userId,
      tripId: tripId,
      defaultCurrency: defaultCurrency,
    ),
  );
}

class ExpenseFormSheet extends ConsumerStatefulWidget {
  const ExpenseFormSheet({
    super.key,
    required this.userId,
    required this.tripId,
    required this.defaultCurrency,
  });

  final String userId;
  final String tripId;
  final String defaultCurrency;

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  late final TextEditingController _currencyController;
  String _category = _expenseCategories.first;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currencyController = TextEditingController(text: widget.defaultCurrency);
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
    try {
      await ref.read(expenseRepositoryProvider).addExpense(
            userId: widget.userId,
            tripId: widget.tripId,
            title: _titleController.text.trim(),
            amount: double.parse(_amountController.text.trim()),
            currency: _currencyController.text.trim().toUpperCase(),
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
              'Add expense',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final parsed = double.tryParse(v ?? '');
                      if (parsed == null || parsed <= 0) return 'Enter a valid amount';
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
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add expense'),
            ),
          ],
        ),
      ),
    );
  }
}
