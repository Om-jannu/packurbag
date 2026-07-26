import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_exception.dart';
import '../data/repositories/ai_repository.dart';
import '../models/trip.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/trip_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble_tile.dart';

/// AI travel assistant, proxied through the backend's `/ai/chat` route so
/// the OpenAI key never ships in client source (see server/server.js). Can
/// optionally be scoped to one of the user's trips for destination-aware
/// answers.
class GptScreen extends ConsumerStatefulWidget {
  const GptScreen({super.key});

  @override
  ConsumerState<GptScreen> createState() => _GptScreenState();
}

class _GptScreenState extends ConsumerState<GptScreen> {
  final _messages = <ChatMessage>[];
  final _controller = TextEditingController();
  bool _isSending = false;
  String? _error;
  Trip? _selectedTrip;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _controller.clear();
      _isSending = true;
      _error = null;
    });

    try {
      final reply = await ref.read(aiRepositoryProvider).sendChatMessage(
            message: text,
            history: _messages.sublist(0, _messages.length - 1),
            destination: _selectedTrip?.destination,
          );
      setState(() => _messages.add(ChatMessage(role: 'assistant', content: reply)));
    } on AppException catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _showTripPicker(List<Trip> trips) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.borderMuted(context))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ask about a specific trip',
                        style: AppTextStyles.bodyBold(color: AppTheme.textPrimary(context)),
                      ),
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.x, color: AppTheme.textMuted(context, opacity: 0.4)),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _TripPickerOption(
                      label: 'General travel advice',
                      selected: _selectedTrip == null,
                      onTap: () {
                        setState(() => _selectedTrip = null);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    for (final trip in trips)
                      _TripPickerOption(
                        label: '${trip.title} · ${trip.destination}',
                        selected: _selectedTrip?.id == trip.id,
                        onTap: () {
                          setState(() => _selectedTrip = trip);
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider).value?.id;
    final tripsAsync = userId == null ? null : ref.watch(tripsProvider(userId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderMuted(context))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary(context)),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Text(
                    'Travel Assistant',
                    style: AppTextStyles.appBarTitle(color: AppTheme.textPrimary(context)),
                  ),
                ],
              ),
            ),
            if (tripsAsync != null)
              tripsAsync.maybeWhen(
                data: (trips) => trips.isEmpty
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () => _showTripPicker(trips),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppTheme.borderMuted(context))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ask about',
                                style: AppTextStyles.label(color: AppTheme.textMuted(context)),
                              ),
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _selectedTrip?.title ?? 'General travel advice',
                                        style: AppTextStyles.label(
                                          color: AppTheme.textPrimary(context),
                                          weight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(LucideIcons.chevronDown,
                                        size: 18, color: AppTheme.textPrimary(context)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                orElse: () => const SizedBox.shrink(),
              ),
            if (_error != null)
              Container(
                width: double.infinity,
                color: AppTheme.coral.withValues(alpha: 0.15),
                padding: const EdgeInsets.all(12),
                child: Text(
                  _error!,
                  style: AppTextStyles.label(color: AppTheme.coral),
                ),
              ),
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        _selectedTrip == null
                            ? 'Ask me for destination ideas, itinerary tips, or local advice.'
                            : 'Ask me anything about ${_selectedTrip!.destination}.',
                        style: AppTextStyles.body(color: AppTheme.textMuted(context)),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isUser = message.role == 'user';
                        if (isUser) {
                          return ChatBubbleTile(text: message.content, isMe: true);
                        }
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
                              child: ChatBubbleTile(text: message.content, isMe: false),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            if (_isSending)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentStrong(context)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: AppTextStyles.body(color: AppTheme.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: AppTextStyles.body(color: AppTheme.textMuted(context, opacity: 0.35)),
                        filled: true,
                        fillColor: AppTheme.surfaceInput(context),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: AppTheme.accentStrong(context)),
                    onPressed: _isSending ? null : _send,
                    icon: Icon(LucideIcons.send, color: AppTheme.onAccentStrong(context)),
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

class _TripPickerOption extends StatelessWidget {
  const _TripPickerOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          label,
          style: AppTextStyles.body(
            color: selected ? AppTheme.textPrimary(context) : AppTheme.textMuted(context, opacity: 0.7),
            weight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
