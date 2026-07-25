import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_exception.dart';
import '../data/repositories/ai_repository.dart';
import '../models/trip.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/trip_providers.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userId = ref.watch(authProvider).value?.id;
    final tripsAsync = userId == null ? null : ref.watch(tripsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Travel Assistant')),
      body: Column(
        children: [
          if (tripsAsync != null)
            tripsAsync.maybeWhen(
              data: (trips) => trips.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: DropdownButtonFormField<Trip?>(
                        initialValue: _selectedTrip,
                        decoration: const InputDecoration(
                          labelText: 'Ask about a specific trip (optional)',
                        ),
                        items: [
                          const DropdownMenuItem<Trip?>(
                              value: null, child: Text('General travel advice')),
                          for (final trip in trips)
                            DropdownMenuItem<Trip?>(
                              value: trip,
                              child: Text('${trip.title} · ${trip.destination}'),
                            ),
                        ],
                        onChanged: (trip) => setState(() => _selectedTrip = trip),
                      ),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
          if (_error != null)
            Container(
              width: double.infinity,
              color: colorScheme.errorContainer,
              padding: const EdgeInsets.all(12),
              child: Text(
                _error!,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      _selectedTrip == null
                          ? 'Ask me for destination ideas, itinerary tips, or local advice.'
                          : 'Ask me anything about ${_selectedTrip!.destination}.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message.role == 'user';
                      return ChatBubbleTile(text: message.content, isMe: isUser);
                    },
                  ),
          ),
          if (_isSending)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Message'),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isSending ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
