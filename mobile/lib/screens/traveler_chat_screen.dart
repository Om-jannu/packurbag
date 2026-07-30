import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/global_snackbar.dart';
import '../data/app_exception.dart';
import '../models/nearby_traveler.dart';
import '../providers/auth_provider.dart';
import '../providers/discovery_providers.dart';
import '../providers/repository_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble_tile.dart';
import '../widgets/conversation_shimmer.dart';

/// 1:1 chat with a nearby traveler. Polls the conversation on a timer while
/// open rather than using a websocket — consistent with the rest of the
/// app's plain-REST data layer. A natural candidate for a future real-time
/// upgrade if polling ever feels laggy.
class TravelerChatScreen extends ConsumerStatefulWidget {
  const TravelerChatScreen({super.key, required this.traveler});

  final NearbyTraveler traveler;

  @override
  ConsumerState<TravelerChatScreen> createState() => _TravelerChatScreenState();
}

class _TravelerChatScreenState extends ConsumerState<TravelerChatScreen> {
  final _controller = TextEditingController();
  Timer? _pollTimer;
  bool _isSending = false;

  String? get _userId => ref.read(authProvider).value?.id;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final userId = _userId;
      if (userId == null) return;
      ref.invalidate(conversationProvider((userId: userId, otherUserId: widget.traveler.userId)));
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final userId = _userId;
    final text = _controller.text.trim();
    if (userId == null || text.isEmpty) return;
    setState(() => _isSending = true);
    try {
      await ref.read(messageRepositoryProvider).sendMessage(
            senderId: userId,
            receiverId: widget.traveler.userId,
            text: text,
          );
      if (!mounted) return;
      _controller.clear();
      ref.invalidate(conversationProvider((userId: userId, otherUserId: widget.traveler.userId)));
    } on AppException catch (error) {
      if (mounted) GlobalSnackbar.show(context, error.message);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider).value?.id;
    final conversationAsync = userId == null
        ? null
        : ref.watch(conversationProvider((userId: userId, otherUserId: widget.traveler.userId)));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderMuted(context))),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary(context)),
                  ),
                  Text(
                    widget.traveler.username,
                    style: AppTextStyles.appBarTitle(color: AppTheme.textPrimary(context)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: conversationAsync == null
                  ? const SizedBox.shrink()
                  : conversationAsync.when(
                      loading: () => const ConversationShimmer(),
                      error: (error, _) => Center(child: Text('$error')),
                      data: (messages) {
                        if (messages.isEmpty) {
                          return Center(
                            child: Text(
                              'Say hi to ${widget.traveler.username}!',
                              style: AppTextStyles.caption(
                                color: AppTheme.textMuted(context, opacity: 0.4),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe = message.senderId == userId;
                            return ChatBubbleTile(text: message.text, isMe: isMe);
                          },
                        );
                      },
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.borderMuted(context))),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: AppTextStyles.body(color: AppTheme.textPrimary(context)),
                          decoration: InputDecoration(
                            hintText: 'Message',
                            hintStyle: AppTextStyles.body(
                              color: AppTheme.textMuted(context, opacity: 0.35),
                            ),
                            filled: true,
                            fillColor: AppTheme.surfaceInput(context),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.accentStrong(context),
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                            disabledBackgroundColor:
                                AppTheme.accentStrong(context).withValues(alpha: 0.5),
                          ),
                          onPressed: _isSending ? null : _send,
                          icon: Icon(LucideIcons.send, color: AppTheme.onAccentStrong(context), size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
