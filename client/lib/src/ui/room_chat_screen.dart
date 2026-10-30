import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/lobby_models.dart';
import '../api/player_models.dart';
import '../api/realtime_event.dart';
import '../api/request_id.dart';
import '../auth/auth_controller.dart';
import 'client_providers.dart';
import 'theme/app_theme.dart';

class RoomChatScreen extends ConsumerStatefulWidget {
  const RoomChatScreen({required this.auth, required this.room, super.key});

  final AuthController auth;
  final LobbyRoom room;

  @override
  ConsumerState<RoomChatScreen> createState() => _RoomChatScreenState();
}

class _RoomChatScreenState extends ConsumerState<RoomChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[];
  String? _pendingBody;
  String? _pendingRequestId;
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _receive(RealtimeEvent event) {
    if (event.type != 'ROOM_MESSAGE_CREATED' ||
        event.roomId != widget.room.id) {
      return;
    }
    _addMessage(
      ChatMessage(
        id: event.messageId,
        senderUserId: event.senderUserId,
        body: event.body,
        createdAt: DateTime.now(),
      ),
    );
  }

  void _addMessage(ChatMessage message) {
    if (!mounted ||
        message.id.isEmpty ||
        _messages.any((item) => item.id == message.id)) {
      return;
    }
    setState(() {
      _messages.add(message);
      if (_messages.length > 100) _messages.removeAt(0);
    });
  }

  Future<void> _send() async {
    final session = widget.auth.session;
    final body = _messageController.text.trim();
    if (session == null || body.isEmpty || _sending) return;
    if (_pendingBody != body) {
      _pendingBody = body;
      _pendingRequestId = createRequestId();
    }
    setState(() => _sending = true);
    try {
      final message = await ref
          .read(apiClientProvider)
          .sendRoomMessage(
            accessToken: session.accessToken,
            roomId: widget.room.id,
            body: body,
            requestId: _pendingRequestId!,
          );
      if (!mounted) return;
      _addMessage(message);
      _pendingBody = null;
      _pendingRequestId = null;
      _messageController.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('发送失败；重试将沿用本次请求编号。')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(realtimeEventsProvider, (previous, next) {
      next.whenData(_receive);
    });
    final userId = widget.auth.session?.userId;
    return Scaffold(
      appBar: AppBar(title: Text('${widget.room.name} · 房间聊天')),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('房间消息仅实时接收，不保留历史。'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(DarkTokens.spacingS3),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final own = message.senderUserId == userId;
                      return Align(
                        alignment: own
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                          ),
                          child: Card(
                            color: own ? DarkTokens.bgCard : DarkTokens.bgPanel,
                            child: Padding(
                              padding: const EdgeInsets.all(
                                DarkTokens.spacingS3,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!own)
                                    Text(
                                      message.senderUserId,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  Text(message.body),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(DarkTokens.spacingS3),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: '输入房间消息'),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: DarkTokens.spacingS2),
                  IconButton.filled(
                    tooltip: '发送',
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox.square(
                            dimension: DarkTokens.spacingS4,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
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
