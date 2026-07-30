import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A shimmering placeholder shaped like an avatar + text row — for list
/// screens (nearby travelers, documents, etc.) where a plain spinner would
/// otherwise show while the real, similarly-shaped rows load in.
class ListRowShimmer extends StatelessWidget {
  const ListRowShimmer({super.key, this.showAvatar = true});

  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHigh,
        highlightColor: colorScheme.surfaceContainerHighest,
        child: Row(
          children: [
            if (showAvatar) ...[
              const CircleAvatar(radius: 20, backgroundColor: Colors.white),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 12,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 90,
                    height: 10,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A short list of [ListRowShimmer]s, for screens that show a `loading:`
/// case for a `ListView.builder`-shaped list.
class ListRowShimmerList extends StatelessWidget {
  const ListRowShimmerList({super.key, this.count = 5, this.showAvatar = true});

  final int count;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: count,
      itemBuilder: (context, index) => ListRowShimmer(showAvatar: showAvatar),
    );
  }
}
