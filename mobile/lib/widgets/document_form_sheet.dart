import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/travel_document.dart';
import '../providers/documents_providers.dart';
import '../providers/repository_providers.dart';
import '../utils.dart';
import 'app_text_field.dart';

const _typeLabels = {
  TravelDocumentType.passport: 'Passport',
  TravelDocumentType.visa: 'Visa',
  TravelDocumentType.ticket: 'Ticket',
  TravelDocumentType.insurance: 'Insurance',
  TravelDocumentType.other: 'Other',
};

/// Add/edit form for a single travel document within a trip.
Future<void> showDocumentFormSheet(
  BuildContext context, {
  required String userId,
  required String tripId,
  TravelDocument? documentToEdit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => DocumentFormSheet(
      userId: userId,
      tripId: tripId,
      documentToEdit: documentToEdit,
    ),
  );
}

class DocumentFormSheet extends ConsumerStatefulWidget {
  const DocumentFormSheet({
    super.key,
    required this.userId,
    required this.tripId,
    this.documentToEdit,
  });

  final String userId;
  final String tripId;
  final TravelDocument? documentToEdit;

  @override
  ConsumerState<DocumentFormSheet> createState() => _DocumentFormSheetState();
}

class _DocumentFormSheetState extends ConsumerState<DocumentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late TravelDocumentType _type;
  XFile? _newPhoto;
  bool _isSubmitting = false;

  bool get _isEditing => widget.documentToEdit != null;

  @override
  void initState() {
    super.initState();
    final editing = widget.documentToEdit;
    _titleController = TextEditingController(text: editing?.title ?? '');
    _notesController = TextEditingController(text: editing?.notes ?? '');
    _type = editing?.type ?? TravelDocumentType.passport;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _newPhoto = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final repo = ref.read(documentsRepositoryProvider);
    final title = capitalizeWords(_titleController.text);
    final notes = _notesController.text.trim();
    try {
      if (_isEditing) {
        await repo.updateDocument(
          userId: widget.userId,
          documentId: widget.documentToEdit!.id,
          type: _type,
          title: title,
          notes: notes,
          newPhoto: _newPhoto,
        );
      } else {
        await repo.addDocument(
          userId: widget.userId,
          tripId: widget.tripId,
          type: _type,
          title: title,
          notes: notes,
          photo: _newPhoto,
        );
      }
      ref.invalidate(documentsProvider((userId: widget.userId, tripId: widget.tripId)));
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(documentsRepositoryProvider).deleteDocument(
            userId: widget.userId,
            documentId: widget.documentToEdit!.id,
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
    final existingPhotoPath = widget.documentToEdit?.imagePath;
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
                _isEditing ? 'Edit travel document' : 'Add travel document',
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
                icon: const Icon(LucideIcons.camera),
                label: Text(_newPhoto == null ? 'Attach photo (optional)' : 'New photo selected'),
              ),
              if (_newPhoto != null && !kIsWeb) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_newPhoto!.path), height: 120, fit: BoxFit.cover),
                ),
              ] else if (existingPhotoPath != null && !kIsWeb) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(existingPhotoPath), height: 120, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 20),
              if (_isEditing) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: _isSubmitting ? null : _delete,
                  icon: const Icon(LucideIcons.trash2),
                  label: const Text('Delete document'),
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
                    : Text(_isEditing ? 'Save changes' : 'Save document'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
