import 'package:eighty_point_huai_an/src/api/api_client.dart';
import 'package:eighty_point_huai_an/src/api/lobby_models.dart';
import 'package:eighty_point_huai_an/src/api/player_models.dart';
import 'package:eighty_point_huai_an/src/auth/auth_controller.dart';
import 'package:eighty_point_huai_an/src/auth/auth_session.dart';
import 'package:eighty_point_huai_an/src/auth/session_store.dart';
import 'package:eighty_point_huai_an/src/ui/client_providers.dart';
import 'package:eighty_point_huai_an/src/ui/friend_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('friend list opens profile and private chat', (tester) async {
    final api = _FakeApiClient()..friends = [_friend];
    final auth = await _authenticated(api);

    await tester.pumpWidget(_friendListApp(auth, api));
    await tester.pumpAndSettle();

    expect(find.text('好友甲'), findsOneWidget);
    await tester.tap(find.text('好友甲'));
    await tester.pumpAndSettle();
    expect(find.text('好友资料 / 战绩'), findsOneWidget);
    expect(find.text('段位：新秀'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('聊天'));
    await tester.pumpAndSettle();
    expect(find.text('好友甲'), findsOneWidget);
    expect(find.text('暂无消息'), findsOneWidget);
  });

  testWidgets('search sends a friend request and retries with the same ID', (
    tester,
  ) async {
    final api = _FakeApiClient()
      ..searchResults = [_searchResult]
      ..failNextFriendRequest = true;
    final auth = await _authenticated(api);

    await tester.pumpWidget(_friendListApp(auth, api));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), ' new-player ');
    await tester.tap(find.byTooltip('搜索'));
    await tester.pumpAndSettle();

    expect(api.searchedQueries, ['new-player']);
    expect(find.text('新牌友'), findsOneWidget);
    await tester.tap(find.byTooltip('发送好友申请'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('发送好友申请'));
    await tester.pumpAndSettle();

    expect(api.friendRequestIds, hasLength(2));
    expect(api.friendRequestIds.first, api.friendRequestIds.last);
    expect(api.friendRequestIds.first, matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(find.text('好友申请已发送。'), findsOneWidget);
  });

  testWidgets('accepts and rejects incoming friend requests', (tester) async {
    final api = _FakeApiClient()..requests = [_request1, _request2];
    final auth = await _authenticated(api);

    await tester.pumpWidget(_friendListApp(auth, api));
    await tester.pumpAndSettle();
    await tester.tap(find.text('好友申请'));
    await tester.pumpAndSettle();

    expect(find.text('申请甲'), findsOneWidget);
    expect(find.text('申请乙'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '接受').first);
    await tester.pumpAndSettle();
    expect(api.responses, [('requester-1', true)]);
    expect(find.text('申请甲'), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, '拒绝'));
    await tester.pumpAndSettle();
    expect(api.responses, [('requester-1', true), ('requester-2', false)]);
    expect(find.text('暂无好友申请'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(TabBar),
        matching: find.text('好友'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('申请甲'), findsOneWidget);
  });

  testWidgets('removes a friend and refreshes the list', (tester) async {
    final api = _FakeApiClient()..friends = [_friend];
    final auth = await _authenticated(api);

    await tester.pumpWidget(_friendListApp(auth, api));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('删除好友'));
    await tester.pumpAndSettle();

    expect(api.removedFriendIds, ['friend-1']);
    expect(find.text('暂无好友'), findsOneWidget);
    expect(find.text('已删除好友。'), findsOneWidget);
  });
}

Widget _friendListApp(AuthController auth, _FakeApiClient api) => ProviderScope(
  overrides: [
    apiClientProvider.overrideWithValue(api),
    authControllerProvider.overrideWithValue(auth),
  ],
  child: MaterialApp(home: FriendListScreen(auth: auth)),
);

Future<AuthController> _authenticated(_FakeApiClient api) async {
  final auth = AuthController(api: api, store: _FakeSessionStore());
  await auth.login('account', 'password');
  return auth;
}

class _FakeApiClient implements ApiClient {
  List<PlayerFriend> friends = [];
  List<PlayerFriend> requests = [];
  List<PlayerFriend> searchResults = [];
  final searchedQueries = <String>[];
  final friendRequestIds = <String>[];
  final responses = <(String, bool)>[];
  final removedFriendIds = <String>[];
  bool failNextFriendRequest = false;

  @override
  Future<AuthSession> login({
    required String account,
    required String password,
  }) async => _session;

  @override
  Future<List<PlayerFriend>> listFriends({required String accessToken}) async =>
      List.unmodifiable(friends);

  @override
  Future<List<PlayerFriend>> listFriendRequests({
    required String accessToken,
  }) async => List.unmodifiable(requests);

  @override
  Future<List<PlayerFriend>> searchPlayers({
    required String accessToken,
    required String query,
  }) async {
    searchedQueries.add(query);
    return searchResults;
  }

  @override
  Future<void> sendFriendRequest({
    required String accessToken,
    required String userId,
    String requestId = '',
  }) async {
    friendRequestIds.add(requestId);
    if (failNextFriendRequest) {
      failNextFriendRequest = false;
      throw StateError('injected friend request failure');
    }
  }

  @override
  Future<void> respondFriendRequest({
    required String accessToken,
    required String userId,
    required bool accept,
    String requestId = '',
  }) async {
    final request = _requestForId(userId);
    responses.add((userId, accept));
    requests.removeWhere((request) => request.userId == userId);
    if (accept) friends.add(request);
  }

  @override
  Future<void> removeFriend({
    required String accessToken,
    required String userId,
    String requestId = '',
  }) async {
    removedFriendIds.add(userId);
    friends.removeWhere((friend) => friend.userId == userId);
  }

  @override
  Future<PlayerStatistics> getFriendStatistics({
    required String accessToken,
    required String userId,
  }) async => const PlayerStatistics(
    totalGames: 0,
    wins: 0,
    losses: 0,
    points: 0,
    rank: '新秀',
  );

  @override
  Future<FriendRecentResultsPage> listFriendRecentResults({
    required String accessToken,
    required String userId,
    String pageToken = '',
    int pageSize = 20,
  }) async => const FriendRecentResultsPage(results: [], nextPageToken: '');

  @override
  Future<ChatMessagesPage> listPrivateMessages({
    required String accessToken,
    required String peerUserId,
    String pageToken = '',
    int pageSize = 50,
  }) async => const ChatMessagesPage(messages: [], nextPageToken: '');

  @override
  Future<void> close() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  PlayerFriend _requestForId(String userId) =>
      requests.firstWhere((request) => request.userId == userId);
}

class _FakeSessionStore implements SessionStore {
  @override
  Future<AuthSession?> read() async => null;

  @override
  Future<void> write(AuthSession session) async {}

  @override
  Future<void> clear() async {}
}

const _friend = PlayerFriend(
  userId: 'friend-1',
  nickname: '好友甲',
  avatarUrl: '',
);
const _searchResult = PlayerFriend(
  userId: 'new-player',
  nickname: '新牌友',
  avatarUrl: '',
);
const _request1 = PlayerFriend(
  userId: 'requester-1',
  nickname: '申请甲',
  avatarUrl: '',
);
const _request2 = PlayerFriend(
  userId: 'requester-2',
  nickname: '申请乙',
  avatarUrl: '',
);
final _session = AuthSession(
  accessToken: 'access',
  refreshToken: 'refresh',
  expiresAt: DateTime.utc(2030),
  userId: 'current-user',
  nickname: '当前用户',
);
