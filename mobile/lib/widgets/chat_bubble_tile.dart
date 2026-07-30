import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import '../theme/app_theme.dart';

/// A plain rounded message bubble — replaces the flutter_chat_bubble
/// package's speech-tail clipper with the simpler pill shape used across
/// the app's chat surfaces (traveler chat, AI assistant).
class ChatBubbleTile extends StatelessWidget {
  const ChatBubbleTile({
    super.key,
    required this.text,
    required this.isMe,
    this.enableMarkdown = false,
  });

  final String text;
  final bool isMe;

  /// Renders [text] as markdown instead of plain text — only meant for AI
  /// assistant replies (which regularly contain **bold**/lists/etc.), not
  /// human-typed messages between travelers.
  final bool enableMarkdown;

  @override
  Widget build(BuildContext context) {
    final color = isMe ? AppTheme.textPrimary(context) : AppTheme.textMuted(context, opacity: 0.8);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.accent(context).withValues(alpha: 0.15) : AppTheme.surfaceInput(context),
          borderRadius: BorderRadius.circular(18),
        ),
        child: enableMarkdown
            ? GptMarkdown(text, style: AppTextStyles.body(color: color))
            : Text(text, style: AppTextStyles.body(color: color)),
      ),
    );
  }
}
