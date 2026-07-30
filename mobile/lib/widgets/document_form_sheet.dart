import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/travel_document.dart';
import '../providers/documents_providers.dart';
import '../providers/repository_providers.dart';
import '../utils.dart';
import 'app_text_field.dart';
import 'multi_photo_picker.dart';

/// Add/edit form for a single photo-journal entry (e.g. "Day 1") within a trip.
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
  late List<String> _existingPhotoPaths;
  final List<XFile> _newPhotos = [];
  bool _isSubmitting = false;

  bool get _isEditing => widget.documentToEdit != null;

  @override
  void initState() {
    super.initState();
    final editing = widget.documentToEdit;
    _titleController = TextEditingController(text: editing?.title ?? '');
    _notesController = TextEditingController(text: editing?.notes ?? '');
    _existingPhotoPaths = List.of(editing?.imagePaths ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
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
          title: title,
          notes: notes,
          existingPhotoPaths: _existingPhotoPaths,
          newPhotos: _newPhotos,
        );
      } else {
        await repo.addDocument(
          userId: widget.userId,
          tripId: widget.tripId,
          title: title,
          notes: notes,
          photos: _newPhotos,
        );
      }
      if (!mounted) return;
      ref.invalidate(documentsProvider((userId: widget.userId, tripId: widget.tripId)));
      ref.invalidate(allDocumentsProvider(widget.userId));
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
      if (!mounted) return;
      ref.invalidate(documentsProvider((userId: widget.userId, tripId: widget.tripId)));
      ref.invalidate(allDocumentsProvider(widget.userId));
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Edit entry' : 'New photo entry',
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
              AppTextField(
                controller: _titleController,
                label: 'Title (e.g. "Day 1")',
                validator: (v) => Validators.required(v, field: 'Title'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _notesController,
                label: 'Notes (optional)',
              ),
              const SizedBox(height: 16),
              MultiPhotoPicker(
                existingPhotoPaths: _existingPhotoPaths,
                newPhotos: _newPhotos,
                onRemoveExisting: (path) => setState(() => _existingPhotoPaths.remove(path)),
                onRemoveNew: (photo) => setState(() => _newPhotos.remove(photo)),
                onPhotosPicked: (photos) => setState(() => _newPhotos.addAll(photos)),
                allowAnyFile: true,
              ),
              const SizedBox(height: 20),
              if (_isEditing) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: _isSubmitting ? null : _delete,
                  icon: const Icon(LucideIcons.trash2),
                  label: const Text('Delete entry'),
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
                    : Text(_isEditing ? 'Save changes' : 'Save entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
