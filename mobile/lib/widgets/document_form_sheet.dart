import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/travel_document.dart';
import '../providers/documents_providers.dart';
import '../providers/repository_providers.dart';
import 'app_text_field.dart';

const _typeLabels = {
  TravelDocumentType.passport: 'Passport',
  TravelDocumentType.visa: 'Visa',
  TravelDocumentType.ticket: 'Ticket',
  TravelDocumentType.insurance: 'Insurance',
  TravelDocumentType.other: 'Other',
};

Future<void> showDocumentFormSheet(
  BuildContext context, {
  required String userId,
  required String tripId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => DocumentFormSheet(userId: userId, tripId: tripId),
  );
}

class DocumentFormSheet extends ConsumerStatefulWidget {
  const DocumentFormSheet({super.key, required this.userId, required this.tripId});

  final String userId;
  final String tripId;

  @override
  ConsumerState<DocumentFormSheet> createState() => _DocumentFormSheetState();
}

class _DocumentFormSheetState extends ConsumerState<DocumentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  TravelDocumentType _type = TravelDocumentType.passport;
  XFile? _photo;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _photo = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(documentsRepositoryProvider).addDocument(
            userId: widget.userId,
            tripId: widget.tripId,
            type: _type,
            title: _titleController.text.trim(),
            notes: _notesController.text.trim(),
            photo: _photo,
          );
      ref.invalidate(documentsProvider((userId: widget.userId, tripId: widget.tripId)));
      if (!mounted) return;
      Navigator.pop(context);
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
              'Add travel document',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Stored only on this device — never uploaded.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TravelDocumentType.values.map((type) {
                return ChoiceChip(
                  label: Text(_typeLabels[type]!),
                  selected: type == _type,
                  onSelected: (_) => setState(() => _type = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _titleController,
              label: 'Title',
              validator: (v) => Validators.required(v, field: 'Title'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _notesController,
              label: 'Notes (optional)',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(_photo == null ? 'Attach photo (optional)' : 'Photo selected'),
            ),
            if (_photo != null && !kIsWeb) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_photo!.path), height: 120, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save document'),
            ),
          ],
        ),
      ),
    );
  }
}
