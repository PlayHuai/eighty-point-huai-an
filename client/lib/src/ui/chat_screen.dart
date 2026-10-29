import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/player_models.dart';
import '../api/request_id.dart';
import '../auth/auth_controller.dart';
import 'client_providers.dart';
import 'theme/app_theme.dart';

final privateMessagesProvider =
    FutureProvider.family<ChatMessagesPage, String>((ref, peerUserId) {
      final session = ref.watch(
        authControllerProvider.select((auth) => auth.session),
      );
      if (session == null) throw StateError('Authentication required.');
      return ref.read(apiClientProvider).listPrivateMessages(
        accessToken: session.accessToken,
        peerUserId: peerUserId,
      );
    });

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.auth, required this.peer, super.key});

  final AuthController auth;
  final PlayerFriend peer;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _pendingBody;
  String? _pendingRequestId;
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
      await ref.read(apiClientProvider).sendPrivateMessage(
        accessToken: session.accessToken,
        peerUserId: widget.peer.userId,
        body: body,
        requestId: _pendingRequestId!,
      );
      if (!mounted) return;
      _pendingBody = null;
      _pendingRequestId = null;
      _messageController.clear();
      ref.invalidate(privateMessagesProvider(widget.peer.userId));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('发送失败；重试将沿用本次请求编号。')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.peer.nickname.isEmpty
            ? widget.peer.userId
            : widget.peer.nickname,
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: ref.watch(privateMessagesProvider(widget.peer.userId)).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: TextButton(
                onPressed: () =>
                    ref.invalidate(privateMessagesProvider(widget.peer.userId)),
                child: const Text('消息加载失败，点击重试'),
              ),
            ),
            data: (page) => page.messages.isEmpty
                ? const Center(child: Text('暂无消息'))
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(DarkTokens.spacingS3),
                    itemCount: page.messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          page.messages[page.messages.length - index - 1];
                      final own = message.senderUserId == widget.auth.session?.userId;
                      return Align(
                        alignment:
                            own ? Alignment.centerRight : Alignment.centerLeft,
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
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(message.body),
                                  const SizedBox(height: DarkTokens.spacingS1),
                                  Text(
                                    message.createdAt.toLocal().toString(),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: '输入消息'),
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
