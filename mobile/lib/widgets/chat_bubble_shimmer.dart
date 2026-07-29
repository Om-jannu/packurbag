import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';

/// A shimmering placeholder shaped like an incoming assistant bubble —
/// shown while waiting for a reply, instead of a spinner floating
/// disconnected from where the message will actually appear.
class ChatBubbleShimmer extends StatelessWidget {
  const ChatBubbleShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 12),
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.accent(context).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(LucideIcons.bot, size: 14, color: AppTheme.accent(context)),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: AppTheme.surfaceInput(context),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Shimmer.fromColors(
                baseColor: colorScheme.surfaceContainerHigh,
                highlightColor: colorScheme.surfaceContainerHighest,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _bar(width: 160),
                    const SizedBox(height: 8),
                    _bar(width: 110),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bar({required double width}) {
    return Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
