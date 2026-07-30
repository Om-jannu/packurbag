import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';
import 'attachment_thumbnail.dart';

/// Shared attachment-picker UI for Documents and Budget receipts. Shows
/// square thumbnails for [existingPhotoPaths] (already persisted) and
/// [newPhotos] (picked this session, not yet persisted) — each individually
/// removable — plus a trailing tile offering "choose from gallery"
/// (multi-select), "take photo" (camera, repeatable, so multiple shots can
/// be added one at a time), and, when [allowAnyFile] is set (Documents only —
/// Budget receipts stay photo-only), "choose file" for non-image documents
/// such as PDFs.
class MultiPhotoPicker extends StatelessWidget {
  const MultiPhotoPicker({
    super.key,
    required this.existingPhotoPaths,
    required this.newPhotos,
    required this.onRemoveExisting,
    required this.onRemoveNew,
    required this.onPhotosPicked,
    this.allowAnyFile = false,
  });

  final List<String> existingPhotoPaths;
  final List<XFile> newPhotos;
  final ValueChanged<String> onRemoveExisting;
  final ValueChanged<XFile> onRemoveNew;
  final ValueChanged<List<XFile>> onPhotosPicked;
  final bool allowAnyFile;

  static const tileSize = 72.0;

  /// Each option below pops the sheet and fires its picker in the same tap
  /// handler, rather than awaiting the sheet's close animation first and
  /// picking afterwards — on web, browsers only allow a file/camera dialog to
  /// open when it's triggered directly within a user gesture, and the delay
  /// from waiting on the sheet's dismissal is enough to lose that and have
  /// the picker silently fail to open.
  Future<void> _showAddMenu(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(LucideIcons.images, color: AppTheme.textPrimary(sheetContext)),
              title: Text('Choose from gallery', style: AppTextStyles.body(color: AppTheme.textPrimary(sheetContext))),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.camera, color: AppTheme.textPrimary(sheetContext)),
              title: Text('Take photo', style: AppTextStyles.body(color: AppTheme.textPrimary(sheetContext))),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickFromCamera();
              },
            ),
            if (allowAnyFile)
              ListTile(
                leading: Icon(LucideIcons.fileText, color: AppTheme.textPrimary(sheetContext)),
                title: Text('Choose file', style: AppTextStyles.body(color: AppTheme.textPrimary(sheetContext))),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAnyFile();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) onPhotosPicked(picked);
  }

  Future<void> _pickFromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) onPhotosPicked([picked]);
  }

  Future<void> _pickAnyFile() async {
    final result = await FilePicker.pickFiles();
    if (result == null) return;
    final picked = await Future.wait(result.files.map((file) async {
      return file.path != null
          ? XFile(file.path!)
          : XFile.fromData(await file.readAsBytes(), name: file.name);
    }));
    if (picked.isNotEmpty) onPhotosPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final path in existingPhotoPaths)
          _PhotoThumbnail(
            image: buildAttachmentThumbnail(context, path, fit: BoxFit.cover),
            onRemove: () => onRemoveExisting(path),
          ),
        for (final photo in newPhotos)
          _PhotoThumbnail(
            image: buildAttachmentThumbnail(context, photo.path, fit: BoxFit.cover),
            onRemove: () => onRemoveNew(photo),
          ),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showAddMenu(context),
          child: Container(
            width: tileSize,
            height: tileSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderMuted(context)),
            ),
            child: Icon(LucideIcons.plus, color: AppTheme.textMuted(context)),
          ),
        ),
      ],
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({required this.image, required this.onRemove});

  final Widget image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MultiPhotoPicker.tileSize,
      height: MultiPhotoPicker.tileSize,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox.expand(child: image),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(LucideIcons.x, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
