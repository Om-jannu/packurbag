import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/app_exception.dart';
import '../models/trip.dart';
import '../providers/repository_providers.dart';
import '../providers/trip_providers.dart';
import '../utils.dart';
import '../widgets/app_text_field.dart';
import '../widgets/category_color.dart';

/// Shows the add/edit form for a [Trip].
Future<void> showTripFormSheet(
  BuildContext context, {
  required String userId,
  Trip? tripToEdit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => TripFormSheet(userId: userId, tripToEdit: tripToEdit),
  );
}

class TripFormSheet extends ConsumerStatefulWidget {
  const TripFormSheet({super.key, required this.userId, this.tripToEdit});

  final String userId;
  final Trip? tripToEdit;

  @override
  ConsumerState<TripFormSheet> createState() => _TripFormSheetState();
}

class _TripFormSheetState extends ConsumerState<TripFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _destinationController;
  late final TextEditingController _budgetController;
  late final TextEditingController _budgetCurrencyController;
  late DateTime _startDate;
  late DateTime _endDate;
  late Color _coverColor;
  bool _isSubmitting = false;

  bool get _isEditing => widget.tripToEdit != null;

  @override
  void initState() {
    super.initState();
    final editing = widget.tripToEdit;
    _titleController = TextEditingController(text: editing?.title ?? '');
    _destinationController = TextEditingController(text: editing?.destination ?? '');
    _budgetController =
        TextEditingController(text: editing?.budgetAmount?.toStringAsFixed(0) ?? '');
    _budgetCurrencyController =
        TextEditingController(text: editing?.budgetCurrency ?? 'INR');
    _startDate = editing?.startDate ?? DateTime.now();
    _endDate = editing?.endDate ?? DateTime.now().add(const Duration(days: 6));
    _coverColor = parseCategoryColor(editing?.coverColor, fallback: const Color(0xFFFF6B4A));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _budgetCurrencyController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _pickColor() async {
    var picked = _coverColor;
    final confirmed = await ColorPicker(
      color: _coverColor,
      onColorChanged: (color) => picked = color,
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      showColorName: true,
      pickersEnabled: const {
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(context);
    if (confirmed) setState(() => _coverColor = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final repo = ref.read(tripRepositoryProvider);
    final budget = double.tryParse(_budgetController.text.trim());
    final budgetCurrency = _budgetCurrencyController.text.trim().isEmpty
        ? 'INR'
        : _budgetCurrencyController.text.trim().toUpperCase();
    final title = capitalizeWords(_titleController.text);
    final destination = capitalizeWords(_destinationController.text);
    try {
      if (_isEditing) {
        await repo.updateTrip(
          userId: widget.userId,
          tripId: widget.tripToEdit!.id,
          title: title,
          destination: destination,
          startDate: _startDate,
          endDate: _endDate,
          coverColor: _coverColor.hex,
          budgetAmount: budget,
          budgetCurrency: budgetCurrency,
        );
      } else {
        await repo.addTrip(
          userId: widget.userId,
          title: title,
          destination: destination,
          startDate: _startDate,
          endDate: _endDate,
          coverColor: _coverColor.hex,
          budgetAmount: budget,
          budgetCurrency: budgetCurrency,
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
                _isEditing ? 'Edit trip' : 'New trip',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _titleController,
                label: 'Trip name',
                validator: (v) => Validators.required(v, field: 'Trip name'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _destinationController,
                label: 'Destination',
                prefixIcon: Icons.place_outlined,
                validator: (v) => Validators.required(v, field: 'Destination'),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.date_range_outlined),
                title: Text(
                  '${DateFormat('d MMM yyyy').format(_startDate)} — ${DateFormat('d MMM yyyy').format(_endDate)}',
                ),
                trailing: TextButton(
                  onPressed: _pickDateRange,
                  child: const Text('Change'),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Cover color'),
                trailing: ColorIndicator(
                  width: 36,
                  height: 36,
                  borderRadius: 18,
                  color: _coverColor,
                  onSelectFocus: false,
                  onSelect: _pickColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      controller: _budgetController,
                      label: 'Budget (optional)',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _budgetCurrencyController,
                      label: 'Currency',
                    ),
                  ),
                ],
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
                    : Text(_isEditing ? 'Save changes' : 'Create trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
