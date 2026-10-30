import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';

import '../api/player_models.dart';
import '../api/request_id.dart';
import '../auth/auth_controller.dart';
import 'client_providers.dart';
import 'chat_screen.dart';
import 'friend_profile_screen.dart';
import 'responsive_breakpoints.dart';
import 'theme/app_theme.dart';

final friendListProvider = FutureProvider<List<PlayerFriend>>((ref) {
  final session = ref.watch(
    authControllerProvider.select((auth) => auth.session),
  );
  if (session == null) return Future.value(const <PlayerFriend>[]);
  return ref.read(apiClientProvider).listFriends(
    accessToken: session.accessToken,
  );
});

final friendRequestsProvider = FutureProvider<List<PlayerFriend>>((ref) {
  final session = ref.watch(
    authControllerProvider.select((auth) => auth.session),
  );
  if (session == null) return Future.value(const <PlayerFriend>[]);
  return ref.read(apiClientProvider).listFriendRequests(
    accessToken: session.accessToken,
  );
});

final playerSearchProvider =
    FutureProvider.family<List<PlayerFriend>, String>((ref, query) {
      final session = ref.watch(
        authControllerProvider.select((auth) => auth.session),
      );
      if (session == null || query.trim().isEmpty) {
        return Future.value(const <PlayerFriend>[]);
      }
      return ref.read(apiClientProvider).searchPlayers(
        accessToken: session.accessToken,
        query: query.trim(),
      );
    });

class FriendListScreen extends ConsumerStatefulWidget {
  const FriendListScreen({required this.auth, super.key});

  final AuthController auth;

  @override
  ConsumerState<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends ConsumerState<FriendListScreen> {
  final _searchController = TextEditingController();
  final _pendingRequestIds = <String, String>{};
  String _query = '';
  bool _isMutating = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _mutate(
    String requestKey,
    Future<void> Function(String accessToken, String requestId) action,
    String successMessage, {
    bool refreshRequests = false,
  }) async {
    final session = widget.auth.session;
    if (session == null || _isMutating) return;
    final requestId = _pendingRequestIds.putIfAbsent(
      requestKey,
      createRequestId,
    );
    setState(() => _isMutating = true);
    try {
      await action(session.accessToken, requestId);
      if (!mounted) return;
      _pendingRequestIds.remove(requestKey);
      ref.invalidate(friendListProvider);
      ref.invalidate(playerSearchProvider);
      if (refreshRequests) ref.invalidate(friendRequestsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (error) {
      if (!mounted) return;
      final text = error is GrpcError && error.code == StatusCode.failedPrecondition
          ? '当前好友关系状态不允许此操作。'
          : '操作失败，请检查网络后重试。';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(text)));
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  void _openProfile(PlayerFriend friend) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FriendProfileScreen(auth: widget.auth, friend: friend),
      ),
    );
  }

  void _openChat(PlayerFriend friend) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(auth: widget.auth, peer: friend),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('好友')),
    body: ResponsiveLayoutBuilder(
      builder: (context, constraints, size) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: size == ResponsiveSize.expanded ? 900 : double.infinity,
          ),
          child: Padding(
            padding: const EdgeInsets.all(DarkTokens.spacingS4),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: '搜索玩家',
                    suffixIcon: IconButton(
                      tooltip: '搜索',
                      onPressed: () =>
                          setState(() => _query = _searchController.text.trim()),
                      icon: const Icon(Icons.search),
                    ),
                  ),
                  onSubmitted: (query) => setState(() => _query = query.trim()),
                ),
                const SizedBox(height: DarkTokens.spacingS3),
                Expanded(
                  child: _query.isNotEmpty
                      ? _buildPlayers(
                          ref.watch(playerSearchProvider(_query)),
                          searching: true,
                        )
                      : DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              const TabBar(
                                tabs: [
                                  Tab(text: '好友'),
                                  Tab(text: '好友申请'),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildPlayers(ref.watch(friendListProvider)),
                                    _buildRequests(
                                      ref.watch(friendRequestsProvider),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildPlayers(
    AsyncValue<List<PlayerFriend>> players, {
    bool searching = false,
  }) => players.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (_, _) => _retry(
      () => searching
          ? ref.invalidate(playerSearchProvider(_query))
          : ref.invalidate(friendListProvider),
    ),
    data: (items) {
      if (items.isEmpty) {
        return Center(
          child: Text(searching ? '没有匹配的玩家' : '暂无好友'),
        );
      }
      return ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final friend = items[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: DarkTokens.bgCard,
              child: Text(_initial(friend)),
            ),
            title: Text(friend.nickname.isEmpty ? friend.userId : friend.nickname),
            subtitle: Text(friend.userId),
            onTap: () => _openProfile(friend),
            trailing: searching
                ? IconButton(
                    tooltip: '发送好友申请',
                    onPressed: _isMutating
                        ? null
                        : () => _mutate(
                            'friend-request:${friend.userId}',
                            (token, requestId) => ref
                                .read(apiClientProvider)
                                .sendFriendRequest(
                                  accessToken: token,
                                  userId: friend.userId,
                                  requestId: requestId,
                                ),
                            '好友申请已发送。',
                          ),
                    icon: const Icon(Icons.person_add_alt_1),
                  )
                : Wrap(
                    spacing: DarkTokens.spacingS1,
                    children: [
                      IconButton(
                        tooltip: '聊天',
                        onPressed: () => _openChat(friend),
                        icon: const Icon(Icons.chat_bubble_outline),
                      ),
                      IconButton(
                        tooltip: '删除好友',
                        onPressed: _isMutating
                            ? null
                            : () => _mutate(
                                'remove-friend:${friend.userId}',
                                (token, requestId) => ref
                                    .read(apiClientProvider)
                                    .removeFriend(
                                      accessToken: token,
                                      userId: friend.userId,
                                      requestId: requestId,
                                    ),
                                '已删除好友。',
                              ),
                        icon: const Icon(Icons.person_remove_outlined),
                      ),
                    ],
                  ),
          );
        },
      );
    },
  );

  Widget _buildRequests(AsyncValue<List<PlayerFriend>> requests) =>
      requests.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _retry(() => ref.invalidate(friendRequestsProvider)),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('暂无好友申请'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final request = items[index];
              return ListTile(
                title: Text(
                  request.nickname.isEmpty ? request.userId : request.nickname,
                ),
                subtitle: Text(request.userId),
                trailing: Wrap(
                  children: [
                    TextButton(
                      onPressed: _isMutating
                          ? null
                          : () => _mutate(
                              'respond:${request.userId}:accept',
                              (token, requestId) => ref
                                  .read(apiClientProvider)
                                  .respondFriendRequest(
                                    accessToken: token,
                                    userId: request.userId,
                                    accept: true,
                                    requestId: requestId,
                                  ),
                              '已接受好友申请。',
                              refreshRequests: true,
                            ),
                      child: const Text('接受'),
                    ),
                    TextButton(
                      onPressed: _isMutating
                          ? null
                          : () => _mutate(
                              'respond:${request.userId}:reject',
                              (token, requestId) => ref
                                  .read(apiClientProvider)
                                  .respondFriendRequest(
                                    accessToken: token,
                                    userId: request.userId,
                                    accept: false,
                                    requestId: requestId,
                                  ),
                              '已拒绝好友申请。',
                              refreshRequests: true,
                            ),
                      child: const Text('拒绝'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

  Widget _retry(VoidCallback retry) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('加载失败'),
        TextButton(onPressed: retry, child: const Text('重试')),
      ],
    ),
  );

  String _initial(PlayerFriend friend) =>
      (friend.nickname.isNotEmpty ? friend.nickname : friend.userId)
          .characters
          .first;
}
