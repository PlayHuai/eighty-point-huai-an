import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/player_models.dart';
import '../auth/auth_controller.dart';
import 'chat_screen.dart';
import 'client_providers.dart';
import 'theme/app_theme.dart';

final friendStatisticsProvider =
    FutureProvider.family<PlayerStatistics, String>((ref, userId) {
      final session = ref.watch(
        authControllerProvider.select((auth) => auth.session),
      );
      if (session == null) throw StateError('Authentication required.');
      return ref.read(apiClientProvider).getFriendStatistics(
        accessToken: session.accessToken,
        userId: userId,
      );
    });

final friendRecentResultsProvider =
    FutureProvider.family<FriendRecentResultsPage, String>((ref, userId) {
      final session = ref.watch(
        authControllerProvider.select((auth) => auth.session),
      );
      if (session == null) throw StateError('Authentication required.');
      return ref.read(apiClientProvider).listFriendRecentResults(
        accessToken: session.accessToken,
        userId: userId,
        pageSize: 20,
      );
    });

class FriendProfileScreen extends ConsumerWidget {
  const FriendProfileScreen({
    required this.auth,
    required this.friend,
    super.key,
  });

  final AuthController auth;
  final PlayerFriend friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('好友资料 / 战绩')),
    body: ListView(
      padding: const EdgeInsets.all(DarkTokens.spacingS4),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(DarkTokens.spacingS4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: DarkTokens.spacingS6,
                  child: Text(
                    (friend.nickname.isEmpty ? friend.userId : friend.nickname)
                        .characters
                        .first,
                  ),
                ),
                const SizedBox(width: DarkTokens.spacingS3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.nickname.isEmpty
                            ? friend.userId
                            : friend.nickname,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(friend.userId),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: '聊天',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatScreen(auth: auth, peer: friend),
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DarkTokens.spacingS3),
        ref.watch(friendStatisticsProvider(friend.userId)).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _errorCard(
            '好友统计加载失败',
            () => ref.invalidate(friendStatisticsProvider(friend.userId)),
          ),
          data: (stats) => Card(
            child: Padding(
              padding: const EdgeInsets.all(DarkTokens.spacingS4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('段位：${stats.rank}'),
                  const SizedBox(height: DarkTokens.spacingS2),
                  Wrap(
                    spacing: DarkTokens.spacingS5,
                    runSpacing: DarkTokens.spacingS2,
                    children: [
                      Text('积分 ${stats.points}'),
                      Text('总场次 ${stats.totalGames}'),
                      Text('胜 ${stats.wins}'),
                      Text('负 ${stats.losses}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: DarkTokens.spacingS3),
        Text('最近战绩', style: Theme.of(context).textTheme.titleMedium),
        ref.watch(friendRecentResultsProvider(friend.userId)).when(
          loading: () => const Padding(
            padding: EdgeInsets.all(DarkTokens.spacingS4),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => _errorCard(
            '最近战绩加载失败',
            () => ref.invalidate(friendRecentResultsProvider(friend.userId)),
          ),
          data: (page) => page.results.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(DarkTokens.spacingS4),
                  child: Text('暂无战绩'),
                )
              : Column(
                  children: [
                    for (final result in page.results)
                      Card(
                        child: ListTile(
                          leading: Icon(
                            result.won ? Icons.emoji_events : Icons.sports,
                            color: result.won
                                ? DarkTokens.goldPrimary
                                : DarkTokens.textSecondary,
                          ),
                          title: Text(result.won ? '获胜' : '未获胜'),
                          subtitle: Text(
                            '${result.endedAt.toLocal()} · ${result.gameSessionId}',
                          ),
                          trailing: Text(
                            '${result.pointsDelta >= 0 ? '+' : ''}${result.pointsDelta}',
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    ),
  );

  Widget _errorCard(String message, VoidCallback retry) => Card(
    child: ListTile(
      title: Text(message),
      trailing: TextButton(onPressed: retry, child: const Text('重试')),
    ),
  );
}
