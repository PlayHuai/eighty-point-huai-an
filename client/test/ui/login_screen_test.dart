import 'dart:async';

import 'package:eighty_point_huai_an/src/api/api_client.dart';
import 'package:eighty_point_huai_an/src/api/lobby_models.dart';
import 'package:eighty_point_huai_an/src/api/player_models.dart';
import 'package:eighty_point_huai_an/src/auth/auth_controller.dart';
import 'package:eighty_point_huai_an/src/auth/auth_session.dart';
import 'package:eighty_point_huai_an/src/auth/session_store.dart';
import 'package:eighty_point_huai_an/src/ui/client_app.dart';
import 'package:eighty_point_huai_an/src/ui/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

void main() {
  testWidgets('friend chat retries with the same request ID', (tester) async {
    final api = _FakeApiClient()
      ..halls = const [
        LobbyHall(
          id: 'ordinary',
          name: '普通大厅',
          minimumPoints: 0,
          maximumPoints: 9999,
          multiplier: 1,
        ),
      ]
      ..friends = const [
        PlayerFriend(
          userId: 'friend-1',
          nickname: '好友甲',
          avatarUrl: '',
        ),
      ]
      ..failNextChatSend = true;
    final auth = AuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('好友'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('聊天'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byHintText('输入消息'), '你好');
    await tester.tap(find.byTooltip('发送'));
    await tester.pumpAndSettle();
    final firstRequestId = api.chatRequestIds.single;

    await tester.tap(find.byTooltip('发送'));
    await tester.pumpAndSettle();
    expect(api.chatRequestIds, [firstRequestId, firstRequestId]);
    expect(api.sentMessages.single.body, '你好');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('friend hall is invitation-only, not a public room listing', (
    tester,
  ) async {
    final api = _FakeApiClient()
      ..halls = const [
        LobbyHall(
          id: 'ordinary',
          name: '普通大厅',
          minimumPoints: 0,
          maximumPoints: 9999,
          multiplier: 1,
        ),
        LobbyHall(
          id: friendRoomHallId,
          name: '好友房',
          minimumPoints: 0,
          maximumPoints: 0,
          multiplier: 1,
        ),
      ]
      ..roomInvitations = [
        RoomInvitation(
          roomId: 'friend-room-1',
          inviterUserId: 'friend-1',
          inviterNickname: '好友甲',
          invitedAt: DateTime.utc(2026, 1, 1),
        ),
      ];
    final auth = AuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.text('好友房'));
    await tester.pumpAndSettle();

    expect(find.text('好友甲 邀请你加入好友房'), findsOneWidget);
    expect(api.requestedRoomHallIds, isNot(contains(friendRoomHallId)));
    await tester.tap(find.text('接受邀请'));
    await tester.pumpAndSettle();
    expect(api.joinedInvitationRoomId, 'friend-room-1');
    expect(api.joinedInvitationRequestId, matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(find.textContaining('已加入 好友房'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('friend-room creation offers invites from the authenticated list', (
    tester,
  ) async {
    final api = _FakeApiClient()
      ..halls = const [
        LobbyHall(
          id: friendRoomHallId,
          name: '好友房',
          minimumPoints: 0,
          maximumPoints: 0,
          multiplier: 1,
        ),
      ]
      ..friends = const [
        PlayerFriend(
          userId: 'friend-1',
          nickname: '好友乙',
          avatarUrl: '',
        ),
      ];
    final auth = AuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.text('创建房间'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '周末好友局');
    await tester.tap(find.widgetWithText(FilledButton, '创建'));
    await tester.pumpAndSettle();

    expect(find.text('邀请好友加入好友房'), findsOneWidget);
    expect(find.text('好友乙'), findsOneWidget);
    await tester.tap(find.byTooltip('发送邀请'));
    await tester.pumpAndSettle();
    expect(api.invitedRoomId, 'created-friend-room');
    expect(api.invitedFriendId, 'friend-1');
    expect(find.text('好友房邀请已发送。'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('lobby renders server halls and joins a waiting room', (
    tester,
  ) async {
    final api = _FakeApiClient()
      ..halls = const [
        LobbyHall(
          id: 'normal',
          name: '普通大厅',
          minimumPoints: 0,
          maximumPoints: 9999,
          multiplier: 1,
        ),
      ]
      ..roomsByHall = const {
        'normal': [
          LobbyRoom(
            id: 'room-1',
            hallId: 'normal',
            name: '周末牌局',
            status: LobbyRoomStatus.waiting,
            occupiedSeats: 2,
            capacity: 4,
            hasPassword: false,
            version: 3,
            allowSpectators: true,
            minimumPoints: 100,
          ),
        ],
      };
    final auth = AuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    expect(find.text('普通大厅'), findsOneWidget);
    expect(find.text('周末牌局'), findsOneWidget);
    expect(find.text('2/4 人  ·  等待中'), findsOneWidget);
    expect(find.text('最低积分 100'), findsOneWidget);
    expect(find.text('允许观战'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '加入'));
    await tester.pumpAndSettle();
    expect(api.joinedRoomId, 'room-1');
    expect(find.textContaining('已加入 周末牌局'), findsOneWidget);
  });

  testWidgets('joining a password-protected room pre-fills its room number', (
    tester,
  ) async {
    final api = _FakeApiClient()
      ..halls = const [
        LobbyHall(
          id: 'normal',
          name: '普通大厅',
          minimumPoints: 0,
          maximumPoints: 9999,
          multiplier: 1,
        ),
      ]
      ..roomsByHall = const {
        'normal': [
          LobbyRoom(
            id: 'locked-room',
            hallId: 'normal',
            name: '密码房',
            status: LobbyRoomStatus.waiting,
            occupiedSeats: 1,
            capacity: 4,
            hasPassword: true,
            version: 1,
          ),
        ],
      };
    final auth = AuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '加入'));
    await tester.pumpAndSettle();

    final roomCodeField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == '房间号',
    );
    expect(
      tester.widget<TextField>(roomCodeField).controller!.text,
      'locked-room',
    );
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('加入'),
      ),
    );
    await tester.pumpAndSettle();
    expect(api.joinedRoomCode, 'locked-room');
  });

  testWidgets('room minimum points cannot exceed the selected hall cap', (
    tester,
  ) async {
    final api = _FakeApiClient()
      ..halls = const [
        LobbyHall(
          id: 'normal',
          name: '普通大厅',
          minimumPoints: 0,
          maximumPoints: 100,
          multiplier: 1,
        ),
      ];
    final auth = AuthController(api: api, store: _FakeSessionStore());
    final login = auth.login('account', 'password');
    api.loginCompleter.complete(_session);
    await login;

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '创建房间'));
    await tester.pumpAndSettle();
    final roomNameField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == '房间名称',
    );
    final minimumPointsField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == '最低准入积分',
    );
    await tester.enterText(roomNameField, '测试牌局');
    await tester.enterText(minimumPointsField, '101');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, '创建'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('最低准入积分不能超过当前大厅上限（100 分）。'), findsOneWidget);
    expect(api.createdRoomMinimumPoints, isEmpty);
  });

  testWidgets('login validates required fields and shows server errors', (
    tester,
  ) async {
    final api = _FakeApiClient();
    final auth = AuthController(api: api, store: _FakeSessionStore());
    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pump();
    expect(find.text('请输入账号'), findsOneWidget);
    expect(find.text('请输入密码'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'account');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pump();
    expect(auth.isLoading, isTrue);
    expect(find.byType(ModalBarrier), findsOneWidget);

    api.loginCompleter.completeError(
      GrpcError.unauthenticated('invalid credentials'),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('invalid credentials'), findsOneWidget);
  });

  testWidgets('successful login opens the authenticated landing screen', (
    tester,
  ) async {
    final api = _FakeApiClient();
    final auth = AuthController(api: api, store: _FakeSessionStore());
    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'account');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pump();
    api.loginCompleter.complete(_session);
    await tester.pumpAndSettle();

    expect(find.text('游戏大厅'), findsOneWidget);
  });

  testWidgets('login password visibility can be toggled', (tester) async {
    final auth = AuthController(
      api: _FakeApiClient(),
      store: _FakeSessionStore(),
    );
    await tester.pumpWidget(MaterialApp(home: LoginScreen(auth: auth)));

    final passwordField = find.byKey(const ValueKey('login-password-field'));
    expect(
      tester.widget<TextField>(
        find.descendant(of: passwordField, matching: find.byType(TextField)),
      ).obscureText,
      isTrue,
    );
    await tester.tap(
      find.descendant(of: passwordField, matching: find.text('显示')),
    );
    await tester.pump();
    expect(
      tester.widget<TextField>(
        find.descendant(of: passwordField, matching: find.byType(TextField)),
      ).obscureText,
      isFalse,
    );

    await tester.tap(
      find.descendant(of: passwordField, matching: find.text('隐藏')),
    );
    await tester.pump();
    expect(
      tester.widget<TextField>(
        find.descendant(of: passwordField, matching: find.byType(TextField)),
      ).obscureText,
      isTrue,
    );

    auth.dispose();
  });

  testWidgets('registration validates required fields and matching passwords', (
    tester,
  ) async {
    final auth = AuthController(
      api: _FakeApiClient(),
      store: _FakeSessionStore(),
    );
    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.text('创建账号'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();

    expect(find.text('账号不能为空'), findsOneWidget);
    expect(
      find.text('密码须为8到128字节且需包含字母和数字'),
      findsOneWidget,
    );
    expect(find.text('请确认密码'), findsOneWidget);
    expect(find.text('昵称不能为空'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('register-account-field')),
      'account',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-password-field')),
      'short',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm-password-field')),
      'different',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-nickname-field')),
      'nickname',
    );
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();

    expect(
      find.text('密码须为8到128字节且需包含字母和数字'),
      findsOneWidget,
    );
    expect(find.text('两次输入的密码不一致'), findsOneWidget);
    auth.dispose();
  });

  testWidgets('keeps registration fields mounted while the request is pending', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 500));
    final api = _FakeApiClient();
    final auth = AuthController(api: api, store: _FakeSessionStore());

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.text('创建账号'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('register-account-field')),
      'account',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-password-field')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm-password-field')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-nickname-field')),
      'nickname',
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();

    expect(find.text('选择头像'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(auth.isLoading, isTrue);
    expect(
      tester.widget<AbsorbPointer>(
        find.ancestor(
          of: find.byKey(const ValueKey('register-account-field')),
          matching: find.byType(AbsorbPointer),
        ),
      ).absorbing,
      isTrue,
    );
    expect(
      tester.widgetList<TextFormField>(find.byType(TextFormField)).map(
        (field) => field.controller!.text,
      ),
      ['account', 'password123', 'password123', 'nickname'],
    );

    api.registerCompleter.completeError(
      GrpcError.unauthenticated('registration failed'),
    );
    await tester.pumpAndSettle();

    expect(find.text('选择头像'), findsOneWidget);
    expect(
      tester.widgetList<TextFormField>(find.byType(TextFormField)).map(
        (field) => field.controller!.text,
      ),
      ['account', 'password123', 'password123', 'nickname'],
    );
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('registration updates the selected avatar before opening lobby', (
    tester,
  ) async {
    final api = _FakeApiClient();
    final auth = AuthController(api: api, store: _FakeSessionStore());
    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('创建账号'));
    await tester.tap(find.text('创建账号'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('register-account-field')),
      'account',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-password-field')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm-password-field')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-nickname-field')),
      'Player',
    );
    await tester.tap(find.byKey(const ValueKey('register-avatar-1')));
    await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();

    api.registerCompleter.complete(_session);
    await tester.pump();
    expect(api.updatedNickname, 'Player');
    expect(api.updatedAvatarUrl, 'huai-avatar://host');

    api.profileUpdateCompleter.complete();
    await tester.pumpAndSettle();
    expect(find.text('游戏大厅'), findsOneWidget);
  });

  testWidgets('registration form remains scrollable on a short viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 240));
    final auth = AuthController(
      api: _FakeApiClient(),
      store: _FakeSessionStore(),
    );

    await tester.pumpWidget(ClientApp(auth: auth));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('创建账号'));
    await tester.tap(find.text('创建账号'));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(null);
  });
}

class _FakeApiClient implements ApiClient {
  final loginCompleter = Completer<AuthSession>();
  final registerCompleter = Completer<AuthSession>();
  final profileUpdateCompleter = Completer<void>();
  String? updatedNickname;
  String? updatedAvatarUrl;
  List<LobbyHall> halls = const [];
  Map<String, List<LobbyRoom>> roomsByHall = const {};
  List<RoomInvitation> roomInvitations = const [];
  List<PlayerFriend> friends = const [];
  final requestedRoomHallIds = <String>[];
  String? joinedRoomId;
  String? joinedRoomCode;
  String? joinedInvitationRoomId;
  String? joinedInvitationRequestId;
  String? invitedFriendId;
  String? invitedRoomId;
  final chatRequestIds = <String>[];
  final sentMessages = <ChatMessage>[];
  final createdRoomMinimumPoints = <int>[];
  bool failNextChatSend = false;

  @override
  Future<AuthSession> login({
    required String account,
    required String password,
  }) => loginCompleter.future;

  @override
  Future<AuthSession> register({
    required String account,
    required String password,
    required String nickname,
  }) => registerCompleter.future;

  @override
  Future<void> updateProfile({
    required String accessToken,
    required String nickname,
    required String avatarUrl,
  }) {
    updatedNickname = nickname;
    updatedAvatarUrl = avatarUrl;
    return profileUpdateCompleter.future;
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async =>
      throw UnimplementedError();

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<List<LobbyHall>> listHalls({required String accessToken}) async =>
      halls;

  @override
  Future<List<LobbyRoom>> listRooms({
    required String accessToken,
    required String hallId,
  }) async {
    requestedRoomHallIds.add(hallId);
    return roomsByHall[hallId] ?? const [];
  }

  @override
  Future<LobbyRoom> createRoom({
    required String accessToken,
    required String hallId,
    required String name,
    required String password,
    bool allowSpectators = false,
    int minimumPoints = 0,
    String requestId = '',
  }) async {
    createdRoomMinimumPoints.add(minimumPoints);
    return LobbyRoom(
      id: 'created-friend-room',
      hallId: hallId,
      name: name,
      status: LobbyRoomStatus.waiting,
      occupiedSeats: 0,
      capacity: 4,
      hasPassword: password.isNotEmpty,
      version: 1,
    );
  }

  @override
  Future<LobbyRoom> joinRoom({
    required String accessToken,
    required String roomId,
  }) async {
    joinedRoomId = roomId;
    return roomsByHall.values.expand((rooms) => rooms).firstWhere(
      (room) => room.id == roomId,
    );
  }

  @override
  Future<LobbyRoom> joinByCode({
    required String accessToken,
    required String roomCode,
    required String password,
  }) async {
    joinedRoomCode = roomCode;
    return LobbyRoom(
      id: roomCode,
      hallId: 'normal',
      name: '密码房',
      status: LobbyRoomStatus.waiting,
      occupiedSeats: 1,
      capacity: 4,
      hasPassword: true,
      version: 1,
    );
  }

  @override
  Future<PlayerStatistics> getFriendStatistics({
    required String accessToken,
    required String userId,
  }) => throw UnimplementedError();

  @override
  Future<FriendRecentResultsPage> listFriendRecentResults({
    required String accessToken,
    required String userId,
    String pageToken = '',
    int pageSize = 20,
  }) => throw UnimplementedError();

  @override
  Future<List<RoomInvitation>> listRoomInvitations({
    required String accessToken,
  }) async => roomInvitations;

  @override
  Future<List<PlayerFriend>> listFriends({required String accessToken}) async =>
      friends;

  @override
  Future<List<PlayerFriend>> searchPlayers({
    required String accessToken,
    required String query,
  }) async => friends.where((friend) => friend.userId.contains(query)).toList();

  @override
  Future<void> sendFriendRequest({
    required String accessToken,
    required String userId,
    String requestId = '',
  }) async {}

  @override
  Future<List<PlayerFriend>> listFriendRequests({
    required String accessToken,
  }) async => const [];

  @override
  Future<void> respondFriendRequest({
    required String accessToken,
    required String userId,
    required bool accept,
    String requestId = '',
  }) async {}

  @override
  Future<void> removeFriend({
    required String accessToken,
    required String userId,
    String requestId = '',
  }) async {}

  @override
  Future<ChatMessagesPage> listPrivateMessages({
    required String accessToken,
    required String peerUserId,
    String pageToken = '',
    int pageSize = 50,
  }) async => ChatMessagesPage(
    messages: List.unmodifiable(sentMessages),
    nextPageToken: '',
  );

  @override
  Future<ChatMessage> sendPrivateMessage({
    required String accessToken,
    required String peerUserId,
    required String body,
    required String requestId,
  }) async {
    chatRequestIds.add(requestId);
    if (failNextChatSend) {
      failNextChatSend = false;
      throw StateError('injected send failure');
    }
    final message = ChatMessage(
      id: 'message-${sentMessages.length + 1}',
      senderUserId: 'user',
      body: body,
      createdAt: DateTime.utc(2026),
    );
    sentMessages.add(message);
    return message;
  }

  @override
  Future<void> sendRoomInvite({
    required String accessToken,
    required String roomId,
    required String friendId,
    String requestId = '',
  }) async {
    invitedRoomId = roomId;
    invitedFriendId = friendId;
  }

  @override
  Future<LobbyRoom> joinInvitedRoom({
    required String accessToken,
    required String roomId,
    required String requestId,
  }) async {
    joinedInvitationRoomId = roomId;
    joinedInvitationRequestId = requestId;
    return LobbyRoom(
      id: roomId,
      hallId: friendRoomHallId,
      name: '好友房',
      status: LobbyRoomStatus.waiting,
      occupiedSeats: 2,
      capacity: 4,
      hasPassword: false,
      version: 3,
    );
  }

  @override
  Future<void> close() async {}
}

class _FakeSessionStore implements SessionStore {
  @override
  Future<AuthSession?> read() async => null;

  @override
  Future<void> write(AuthSession session) async {}

  @override
  Future<void> clear() async {}
}

final _session = AuthSession(
  accessToken: 'access',
  refreshToken: 'refresh',
  expiresAt: DateTime.utc(2030),
  userId: 'user',
  nickname: 'Player',
);
