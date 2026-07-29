import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_exception.dart';
import '../data/repositories/ai_repository.dart';
import '../models/trip.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/trip_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble_shimmer.dart';
import '../widgets/chat_bubble_tile.dart';

const _conversationsPrefKey = 'ai_chat_conversations_v2';
const _lastContextKeyPrefKey = 'ai_chat_last_context_v2';
const _generalContextKey = '__general__';

String _contextKeyFor(Trip? trip) => trip?.id ?? _generalContextKey;

/// Mirrors the server's MAX_MESSAGE_LENGTH (server/src/routes/ai.routes.ts)
/// so the input can block excess typing instead of letting the user hit
/// send and only then discover the message was too long.
const _maxMessageLength = 4000;

/// Strips the markdown syntax the assistant is asked to use (bold, headings,
/// bullets — see the formatting guardrail in ai.routes.ts) so Copy/Share
/// hand off clean prose instead of literal `**`/`#`/`-` to apps that don't
/// render markdown.
String _stripMarkdown(String text) {
  return text
      .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
      .replaceAll(RegExp(r'[*_](.+?)[*_]'), r'$1')
      .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')
      .replaceAll(RegExp(r'^[-*+]\s+', multiLine: true), '• ')
      .trim();
}

/// AI travel assistant, proxied through the backend's `/ai/chat` route so
/// the Groq API key never ships in client source (see
/// server/src/routes/ai.routes.ts). Can optionally be scoped to one of the
/// user's trips for destination- and itinerary-aware answers.
class GptScreen extends ConsumerStatefulWidget {
  const GptScreen({super.key});

  @override
  ConsumerState<GptScreen> createState() => _GptScreenState();
}

class _GptScreenState extends ConsumerState<GptScreen> {
  static const _maxHistorySent = 20;

  final _messages = <ChatMessage>[];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  String? _error;
  Trip? _selectedTrip;

  /// Which context [_isSending]'s in-flight request actually belongs to —
  /// used to scope the loading shimmer to that context, since switching away
  /// to a different (already non-empty) trip while a request is pending
  /// would otherwise show a misleading "thinking…" bubble there too.
  String? _pendingContextKey;

  /// Set while the input box holds an edit of a previously-sent message
  /// rather than a brand new one — see [_startEditing].
  ChatMessage? _editingMessage;

  /// Ids of assistant messages currently shown in full rather than
  /// truncated — see [_AssistantMessageRow].
  final Set<int> _expandedMessageIds = {};

  /// Every context's conversation (keyed by trip id, or [_generalContextKey])
  /// lives here — switching trips swaps [_messages] for a different entry
  /// instead of clearing history outright, so each context's conversation
  /// survives switching away and back, not just app restarts.
  final Map<String, List<ChatMessage>> _conversationsByContext = {};
  String _activeContextKey = _generalContextKey;

  /// Set while waiting for the trips list to load so a restored trip id can
  /// be resolved into an actual [Trip] object (see the `ref.listen` in build).
  String? _pendingRestoredTripId;

  @override
  void initState() {
    super.initState();
    _restoreConversation();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _restoreConversation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_conversationsPrefKey);
    final lastKey = prefs.getString(_lastContextKeyPrefKey) ?? _generalContextKey;
    if (!mounted) return;

    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _conversationsByContext.addAll(decoded.map(
          (key, value) => MapEntry(
            key,
            (value as List<dynamic>)
                .map((m) => ChatMessage.fromStorageJson(m as Map<String, dynamic>))
                .toList(),
          ),
        ));
      } catch (_) {
        // Corrupt or outdated cache — start fresh rather than crash.
      }
    }

    setState(() {
      _activeContextKey = lastKey;
      _messages.addAll(_conversationsByContext[lastKey] ?? []);
      if (lastKey != _generalContextKey) {
        _pendingRestoredTripId = lastKey;
      }
    });
    _scrollToBottom();
  }

  Future<void> _persistConversation() async {
    _conversationsByContext[_activeContextKey] = List.of(_messages);
    await _writeConversations();
  }

  Future<void> _writeConversations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _conversationsPrefKey,
      jsonEncode(_conversationsByContext.map(
        (key, value) => MapEntry(key, value.map((m) => m.toStorageJson()).toList()),
      )),
    );
    await prefs.setString(_lastContextKeyPrefKey, _activeContextKey);
  }

  /// Applies [update] to [contextKey]'s message list — this is how
  /// [_send]/[_regenerate] write their result back once a response arrives,
  /// since by then the user may have switched to a different trip (or left
  /// the screen entirely). Writing straight into [_messages] regardless of
  /// which context is still active would silently attach the reply to the
  /// wrong conversation; this keeps it filed under the context it was
  /// actually asked in, live-updating the screen only if that context (and
  /// the widget) is still what's on screen.
  void _applyToContext(String contextKey, void Function(List<ChatMessage> messages) update) {
    if (contextKey == _activeContextKey) {
      if (mounted) {
        setState(() => update(_messages));
      } else {
        update(_messages);
      }
      _conversationsByContext[_activeContextKey] = List.of(_messages);
    } else {
      final messages = List<ChatMessage>.of(_conversationsByContext[contextKey] ?? []);
      update(messages);
      _conversationsByContext[contextKey] = messages;
    }
    _writeConversations();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// Switches the trip-context scope, swapping in that context's own saved
  /// conversation (starting fresh if it's never been chatted with) instead
  /// of wiping history — each context keeps its own thread.
  void _switchTrip(Trip? trip) {
    final newKey = _contextKeyFor(trip);
    if (newKey == _activeContextKey) return;

    _conversationsByContext[_activeContextKey] = List.of(_messages);
    setState(() {
      _selectedTrip = trip;
      _activeContextKey = newKey;
      _error = null;
      // An edit-in-progress is tied to the conversation it started in —
      // otherwise sending it after switching would silently inject the
      // edited text as a new message into the wrong trip's history.
      _editingMessage = null;
      _controller.clear();
      _messages
        ..clear()
        ..addAll(_conversationsByContext[newKey] ?? []);
    });
    _scrollToBottom();
    _persistConversation();
  }

  /// Puts [message]'s text into the input box for editing. Nothing is
  /// removed yet — that only happens if the edit is actually sent (see
  /// [_send]), so backing out of an edit loses nothing.
  void _startEditing(ChatMessage message) {
    // Force an explicit cancel (the banner's X) before starting a different
    // edit, rather than silently discarding whatever was being edited.
    if (_isSending || _editingMessage != null) return;
    setState(() {
      _editingMessage = message;
      _controller.text = message.content;
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingMessage = null;
      _controller.clear();
    });
  }

  /// Resends [retryMessage] if given, otherwise whatever's in the input box
  /// (either a brand new message, or an edit of [_editingMessage] if set).
  Future<void> _send({ChatMessage? retryMessage}) async {
    final editing = _editingMessage;
    final text = retryMessage?.content ?? _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    // Frozen at the moment the request starts — if the user switches trips
    // (or leaves the screen) before the reply arrives, the result still
    // needs to land in the conversation it was actually asked in.
    final requestContextKey = _activeContextKey;
    final requestDestination = _selectedTrip?.destination;
    final requestTripContext = _buildTripContext(_selectedTrip);

    late final ChatMessage userMessage;
    setState(() {
      if (retryMessage != null) {
        userMessage = retryMessage.copyWith(failed: false);
        final index = _messages.indexWhere((m) => m.id == retryMessage.id);
        if (index != -1) _messages[index] = userMessage;
      } else if (editing != null) {
        // Editing branches the conversation from this point — everything
        // after the original message no longer matches what's being asked.
        userMessage = ChatMessage(role: 'user', content: text);
        final index = _messages.indexWhere((m) => m.id == editing.id);
        if (index != -1) _messages.removeRange(index, _messages.length);
        _messages.add(userMessage);
        _editingMessage = null;
        _controller.clear();
      } else {
        userMessage = ChatMessage(role: 'user', content: text);
        _messages.add(userMessage);
        _controller.clear();
      }
      _isSending = true;
      _pendingContextKey = requestContextKey;
      _error = null;
    });
    _scrollToBottom();

    // Failed sends never got a reply, so they're not a completed turn —
    // including them would show the model a dangling, unanswered question
    // mixed into otherwise-real history.
    final priorTurns = _messages.where((m) => m.id != userMessage.id && !m.failed).toList();
    final historyToSend = priorTurns.length > _maxHistorySent
        ? priorTurns.sublist(priorTurns.length - _maxHistorySent)
        : priorTurns;

    try {
      final reply = await ref.read(aiRepositoryProvider).sendChatMessage(
            message: text,
            history: historyToSend,
            destination: requestDestination,
            tripContext: requestTripContext,
          );
      _applyToContext(
        requestContextKey,
        (messages) => messages.add(ChatMessage(role: 'assistant', content: reply)),
      );
      if (requestContextKey == _activeContextKey) _scrollToBottom();
    } on AppException catch (error) {
      _applyToContext(requestContextKey, (messages) {
        final index = messages.indexWhere((m) => m.id == userMessage.id);
        if (index != -1) messages[index] = userMessage.copyWith(failed: true);
      });
      if (requestContextKey == _activeContextKey && mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _pendingContextKey = null;
        });
      }
    }
  }

  /// Discards [assistantMessage] and asks for a fresh reply to the same
  /// preceding user message. If the new request fails, the user message
  /// is marked failed (same recovery path as a normal failed send) rather
  /// than leaving it with no reply and no way to retry from the UI.
  Future<void> _regenerate(ChatMessage assistantMessage) async {
    if (_isSending) return;
    final assistantIndex = _messages.indexWhere((m) => m.id == assistantMessage.id);
    if (assistantIndex <= 0) return;
    final precedingUser = _messages[assistantIndex - 1];
    if (precedingUser.role != 'user') return;

    final requestContextKey = _activeContextKey;
    final requestDestination = _selectedTrip?.destination;
    final requestTripContext = _buildTripContext(_selectedTrip);

    setState(() {
      _messages.removeAt(assistantIndex);
      _isSending = true;
      _pendingContextKey = requestContextKey;
      _error = null;
    });
    _scrollToBottom();

    final priorTurns = _messages.sublist(0, assistantIndex - 1).where((m) => !m.failed).toList();
    final historyToSend = priorTurns.length > _maxHistorySent
        ? priorTurns.sublist(priorTurns.length - _maxHistorySent)
        : priorTurns;

    try {
      final reply = await ref.read(aiRepositoryProvider).sendChatMessage(
            message: precedingUser.content,
            history: historyToSend,
            destination: requestDestination,
            tripContext: requestTripContext,
          );
      _applyToContext(
        requestContextKey,
        (messages) => messages.add(ChatMessage(role: 'assistant', content: reply)),
      );
      if (requestContextKey == _activeContextKey) _scrollToBottom();
    } on AppException catch (error) {
      _applyToContext(requestContextKey, (messages) {
        final userIndex = messages.indexWhere((m) => m.id == precedingUser.id);
        if (userIndex != -1) messages[userIndex] = precedingUser.copyWith(failed: true);
      });
      if (requestContextKey == _activeContextKey && mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _pendingContextKey = null;
        });
      }
    }
  }

  Future<void> _copyMessage(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 2)),
    );
  }

  Future<void> _shareMessage(String content) {
    return SharePlus.instance.share(ShareParams(text: content));
  }

  /// Short, pre-formatted summary of [trip]'s dates/budget/itinerary so the
  /// assistant can give advice aware of the actual trip, not just its
  /// destination name. Built from the user's own already-fetched trip data.
  String? _buildTripContext(Trip? trip) {
    if (trip == null) return null;

    final dateFormat = DateFormat('d MMM yyyy');
    final days = trip.endDate.difference(trip.startDate).inDays + 1;
    final parts = <String>[
      '${dateFormat.format(trip.startDate)} to ${dateFormat.format(trip.endDate)} ($days days)',
    ];
    if (trip.budgetAmount != null) {
      parts.add('budget ${trip.budgetAmount} ${trip.budgetCurrency}');
    }
    if (trip.itinerary.isNotEmpty) {
      final items = trip.itinerary.take(6).map((i) => i.text).join(', ');
      parts.add('itinerary so far: $items');
    }
    return parts.join('; ');
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
                        _switchTrip(null);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    for (final trip in trips)
                      _TripPickerOption(
                        label: '${trip.title} · ${trip.destination}',
                        selected: _selectedTrip?.id == trip.id,
                        onTap: () {
                          _switchTrip(trip);
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

    if (userId != null) {
      ref.listen<AsyncValue<List<Trip>>>(tripsProvider(userId), (previous, next) {
        final trips = next.value;
        if (trips == null) return;

        // Resolve a restored trip id (from a previous session) into an
        // actual Trip now that the list has loaded.
        final pendingId = _pendingRestoredTripId;
        if (pendingId != null) {
          _pendingRestoredTripId = null;
          Trip? found;
          for (final trip in trips) {
            if (trip.id == pendingId) {
              found = trip;
              break;
            }
          }
          if (found != null) {
            setState(() => _selectedTrip = found);
          } else {
            // That trip no longer exists — its saved conversation (if any)
            // stays in storage under its old key, but this chat falls back
            // to general advice instead of a destination that's gone.
            _switchTrip(null);
          }
          return;
        }

        // If the trip currently scoping this chat gets deleted elsewhere in
        // the app, fall back to general advice instead of silently
        // continuing to use a destination that no longer exists.
        final selected = _selectedTrip;
        if (selected != null && !trips.any((t) => t.id == selected.id)) {
          _switchTrip(null);
        }
      });
    }

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
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: _messages.length +
                          (_isSending && _pendingContextKey == _activeContextKey ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return const ChatBubbleShimmer();
                        }
                        final message = _messages[index];
                        if (message.role == 'user') {
                          return _UserMessageRow(
                            message: message,
                            isSending: _isSending,
                            onRetry: () => _send(retryMessage: message),
                            onEdit: () => _startEditing(message),
                            onCopy: () => _copyMessage(message.content),
                          );
                        }
                        return _AssistantMessageRow(
                          message: message,
                          isExpanded: _expandedMessageIds.contains(message.id),
                          onToggleExpand: () => setState(() {
                            if (!_expandedMessageIds.remove(message.id)) {
                              _expandedMessageIds.add(message.id);
                            }
                          }),
                          canRegenerate: !_isSending && index == _messages.length - 1,
                          onRegenerate: () => _regenerate(message),
                          onCopy: () => _copyMessage(_stripMarkdown(message.content)),
                          onShare: () => _shareMessage(_stripMarkdown(message.content)),
                        );
                      },
                    ),
            ),
            if (_editingMessage != null)
              Container(
                width: double.infinity,
                color: AppTheme.accent(context).withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(LucideIcons.pencil, size: 14, color: AppTheme.accent(context)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Editing message',
                        style: AppTextStyles.label(color: AppTheme.accent(context)),
                      ),
                    ),
                    InkWell(
                      onTap: _cancelEditing,
                      child: Icon(LucideIcons.x, size: 16, color: AppTheme.accent(context)),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLength: _maxMessageLength,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                        // Only surface it once it's actually relevant —
                        // showing "12/4000" under every short message would
                        // just be noise.
                        if (!isFocused || maxLength == null || currentLength < (maxLength * 0.8).round()) {
                          return null;
                        }
                        return Text(
                          '$currentLength/$maxLength',
                          style: AppTextStyles.tag(color: AppTheme.textMuted(context, opacity: 0.5)),
                        );
                      },
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

class _UserMessageRow extends StatelessWidget {
  const _UserMessageRow({
    required this.message,
    required this.isSending,
    required this.onRetry,
    required this.onEdit,
    required this.onCopy,
  });

  final ChatMessage message;
  final bool isSending;
  final VoidCallback onRetry;
  final VoidCallback onEdit;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ChatBubbleTile(text: message.content, isMe: true),
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 4, top: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.failed) ...[
                Text('Failed to send', style: AppTextStyles.tag(color: AppTheme.coral)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 26,
                  height: 26,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(backgroundColor: AppTheme.coral),
                    iconSize: 13,
                    icon: const Icon(LucideIcons.refreshCw, color: Colors.white),
                    onPressed: isSending ? null : onRetry,
                    tooltip: 'Retry',
                  ),
                ),
                const SizedBox(width: 4),
              ] else
                _ActionIcon(icon: LucideIcons.pencil, tooltip: 'Edit', onTap: isSending ? null : onEdit),
              _ActionIcon(icon: LucideIcons.copy, tooltip: 'Copy', onTap: onCopy),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small icon-only action button shared by the message action rows — the
/// label lives in the tooltip instead of on the button itself.
class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.tooltip, required this.onTap, this.color});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 14, color: color ?? AppTheme.textMuted(context, opacity: 0.4)),
        ),
      ),
    );
  }
}

class _AssistantMessageRow extends StatelessWidget {
  const _AssistantMessageRow({
    required this.message,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.canRegenerate,
    required this.onRegenerate,
    required this.onCopy,
    required this.onShare,
  });

  static const _collapseThreshold = 500;

  final ChatMessage message;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final bool canRegenerate;
  final VoidCallback onRegenerate;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final isLong = message.content.length > _collapseThreshold;
    final displayText =
        (isLong && !isExpanded) ? _truncate(message.content, _collapseThreshold) : message.content;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChatBubbleTile(text: displayText, isMe: false, enableMarkdown: true),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4, top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLong)
                      _ActionIcon(
                        icon: isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                        tooltip: isExpanded ? 'View less' : 'View more',
                        onTap: onToggleExpand,
                        color: AppTheme.accent(context),
                      ),
                    if (canRegenerate)
                      _ActionIcon(icon: LucideIcons.refreshCw, tooltip: 'Regenerate', onTap: onRegenerate),
                    _ActionIcon(icon: LucideIcons.copy, tooltip: 'Copy', onTap: onCopy),
                    _ActionIcon(icon: LucideIcons.share2, tooltip: 'Share', onTap: onShare),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Cuts at the last line break or space before [maxLength] rather than a
  /// hard character index, so truncation doesn't split a word in half, then
  /// drops back further if that leaves an unclosed `**bold**` span open —
  /// otherwise the missing closing marker would bleed bold styling into the
  /// rest of the (already truncated) preview.
  static String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    final truncated = text.substring(0, maxLength);
    final lastBreak = truncated.lastIndexOf(RegExp(r'[\n ]'));
    var cut = lastBreak > 0 ? truncated.substring(0, lastBreak) : truncated;

    final boldMarkerCount = RegExp(r'\*\*').allMatches(cut).length;
    if (boldMarkerCount.isOdd) {
      final lastOpen = cut.lastIndexOf('**');
      if (lastOpen > 0) cut = cut.substring(0, lastOpen);
    }
    return '$cut…';
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
