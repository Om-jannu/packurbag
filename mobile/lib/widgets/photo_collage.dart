import 'package:flutter/material.dart';

import 'attachment_thumbnail.dart';

/// WhatsApp-style photo grid: up to 4 square tiles, 2 per row. 4 or fewer
/// photos show one tile each; more than 4 show the first 3 as plain tiles
/// plus a 4th tile — the 4th photo, dimmed, under a "+N" label where N is
/// however many photos aren't individually shown.
class PhotoCollage extends StatelessWidget {
  const PhotoCollage({super.key, required this.imagePaths, required this.onTapPhoto});

  final List<String> imagePaths;

  /// Called with the tapped tile's index into [imagePaths] (the *full*
  /// list, not just the visible tiles) — the overflow tile's index still
  /// points at its own (dimmed) photo, so a viewer opened from there can
  /// swipe forward into the rest.
  final ValueChanged<int> onTapPhoto;

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) return const SizedBox.shrink();

    final visibleCount = imagePaths.length > 4 ? 4 : imagePaths.length;
    final overflowCount = imagePaths.length > 4 ? imagePaths.length - 3 : 0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: visibleCount,
      itemBuilder: (context, index) {
        final isOverflowTile = overflowCount > 0 && index == 3;
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GestureDetector(
            onTap: () => onTapPhoto(index),
            child: Stack(
              fit: StackFit.expand,
              children: [
                buildAttachmentThumbnail(context, imagePaths[index], fit: BoxFit.cover),
                if (isOverflowTile)
                  Container(
                    color: Colors.black.withValues(alpha: 0.55),
                    alignment: Alignment.center,
                    child: Text(
                      '+$overflowCount',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
