import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';

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
  late int _roomVersion;
  String? _leaveRequestId;
  bool _sending = false;
  bool _leaving = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _roomVersion = widget.room.version;
  }

  void _receive(RealtimeEvent event) {
    if (event.type == 'CONNECTION_RESTORED') {
      unawaited(_refreshRoomVersion());
      return;
    }
    if (event.roomId != widget.room.id) return;
    if (event.type == 'ROOM_STATE_CHANGED') {
      if (event.version > _roomVersion) {
        setState(() => _roomVersion = event.version);
      }
      return;
    }
    if (event.type != 'ROOM_MESSAGE_CREATED') return;
    _addMessage(
      ChatMessage(
        id: event.messageId,
        senderUserId: event.senderUserId,
        body: event.body,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _refreshRoomVersion() async {
    final session = widget.auth.session;
    if (session == null) return;
    try {
      final room = await ref.read(apiClientProvider).getRoom(
            accessToken: session.accessToken,
            roomId: widget.room.id,
          );
      if (mounted && room.version > _roomVersion) {
        setState(() => _roomVersion = room.version);
      }
    } catch (_) {
      return;
    }
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

  Future<void> _leaveAndPop() async {
    if (_leaving) return;
    final session = widget.auth.session;
    if (session == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _leaving = true);
    try {
      final api = ref.read(apiClientProvider);
      _leaveRequestId ??= createRequestId();
      for (var attempt = 0; ; attempt++) {
        try {
          await api.leaveRoom(
            accessToken: session.accessToken,
            roomId: widget.room.id,
            expectedVersion: _roomVersion,
            requestId: _leaveRequestId!,
          );
          _leaveRequestId = null;
          break;
        } on GrpcError catch (error) {
          if (error.code != StatusCode.aborted || attempt != 0) rethrow;
          await _refreshRoomVersion();
        }
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('离开房间失败，请稍后重试。')));
      }
    } finally {
      if (mounted) setState(() => _leaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(realtimeEventsProvider, (previous, next) {
      next.whenData(_receive);
    });
    final userId = widget.auth.session?.userId;
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leaveAndPop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.room.name} · 房间聊天'),
          leading: IconButton(
            tooltip: '离开房间',
            onPressed: _leaving ? null : _leaveAndPop,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
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
                              maxWidth:
                                  MediaQuery.sizeOf(context).width * 0.75,
                            ),
                            child: Card(
                              color:
                                  own ? DarkTokens.bgCard : DarkTokens.bgPanel,
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
      ),
    );
  }
}
