import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';

/// A few alternating shimmering bubbles — for a plain two-person chat
/// screen's loading state (no per-message avatar, unlike [ChatBubbleShimmer]
/// which is specifically shaped for the AI assistant's bot-avatar layout).
class ConversationShimmer extends StatelessWidget {
  const ConversationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const widths = [150.0, 110.0, 170.0];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: widths.length,
      itemBuilder: (context, index) {
        final isMe = index.isOdd;
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.accent(context).withValues(alpha: 0.1) : AppTheme.surfaceInput(context),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Shimmer.fromColors(
              baseColor: colorScheme.surfaceContainerHigh,
              highlightColor: colorScheme.surfaceContainerHighest,
              child: Container(
                width: widths[index],
                height: 12,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        );
      },
    );
  }
}
