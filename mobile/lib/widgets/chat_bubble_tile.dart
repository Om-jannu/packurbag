import 'package:flutter/material.dart';

/// A plain rounded message bubble — replaces the flutter_chat_bubble
/// package's speech-tail clipper with the simpler pill shape used across
/// the app's chat surfaces (traveler chat, AI assistant).
class ChatBubbleTile extends StatelessWidget {
  const ChatBubbleTile({super.key, required this.text, required this.isMe});

  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
