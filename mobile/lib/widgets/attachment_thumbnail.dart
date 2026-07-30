import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';

/// Renders a locally-stored attachment at [path] as an image. Documents can
/// now hold non-image files too (PDFs, etc. picked via "Choose file") — when
/// the file can't be decoded as an image, this falls back to a generic
/// document icon instead of a broken-image placeholder.
Widget buildAttachmentThumbnail(
  BuildContext context,
  String path, {
  BoxFit? fit,
  double iconSize = 22,
}) {
  Widget errorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      color: AppTheme.surfaceMuted(context),
      alignment: Alignment.center,
      child: Icon(LucideIcons.fileText, size: iconSize, color: AppTheme.textMuted(context, opacity: 0.4)),
    );
  }

  return kIsWeb
      ? Image.network(path, fit: fit, errorBuilder: errorBuilder)
      : Image.file(File(path), fit: fit, errorBuilder: errorBuilder);
}
