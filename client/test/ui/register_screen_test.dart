import 'dart:async';

import 'package:eighty_point_huai_an/src/api/api_client.dart';
import 'package:eighty_point_huai_an/src/api/lobby_models.dart';
import 'package:eighty_point_huai_an/src/api/player_models.dart';
import 'package:eighty_point_huai_an/src/auth/auth_controller.dart';
import 'package:eighty_point_huai_an/src/auth/auth_session.dart';
import 'package:eighty_point_huai_an/src/auth/session_store.dart';
import 'package:eighty_point_huai_an/src/ui/client_app.dart';
import 'package:eighty_point_huai_an/src/ui/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

void main() {
  testWidgets(
    'registration validates password confirmation and required data',
    (tester) async {
      final api = _FakeApiClient();
      final auth = AuthController(api: api, store: _FakeSessionStore());
      await auth.restoreSession();
      await tester.pumpWidget(MaterialApp(home: RegisterScreen(auth: auth)));

      await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
      await tester.tap(find.widgetWithText(FilledButton, '注册'));
      await tester.pump();
      expect(find.text('账号不能为空'), findsOneWidget);
      expect(find.text('密码须为8到128字节且需包含字母和数字'), findsOneWidget);
      expect(find.text('请确认密码'), findsOneWidget);
      expect(find.text('昵称不能为空'), findsOneWidget);

      await _enterText(tester, 'register-account-field', 'ab');
      await _enterText(tester, 'register-password-field', 'Cards2026!');
      await _enterText(
        tester,
        'register-confirm-password-field',
        'Different2026!',
      );
      await _enterText(tester, 'register-nickname-field', '玩家');
      await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
      await tester.tap(find.widgetWithText(FilledButton, '注册'));
      await tester.pump();

      expect(find.text('账号须为3到64字节且不能包含空格'), findsOneWidget);
      expect(find.text('两次输入的密码不一致'), findsOneWidget);
      await _enterText(tester, 'register-account-field', 'player01');
      await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
      await tester.tap(find.widgetWithText(FilledButton, '注册'));
      await tester.pump();
      expect(find.text('两次输入的密码不一致'), findsOneWidget);
      expect(api.registeredAccount, isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
    },
  );

  testWidgets(
    'registration submits avatar and enters the authenticated screen',
    (tester) async {
      final api = _FakeApiClient();
      final auth = AuthController(api: api, store: _FakeSessionStore());
      await tester.pumpWidget(ClientApp(auth: auth));
      await tester.pumpAndSettle();

      await tester.tap(find.text('创建账号'));
      await tester.pumpAndSettle();
      await _enterText(tester, 'register-account-field', ' player01 ');
      await _enterText(tester, 'register-password-field', 'Cards2026!');
      await _enterText(tester, 'register-confirm-password-field', 'Cards2026!');
      await _enterText(tester, 'register-nickname-field', ' 玩家 ');
      await tester.ensureVisible(
        find.byKey(const ValueKey('register-avatar-2')),
      );
      await tester.tap(find.byKey(const ValueKey('register-avatar-2')));
      await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
      await tester.tap(find.widgetWithText(FilledButton, '注册'));
      await tester.pump();

      expect(api.registeredAccount, 'player01');
      expect(api.registeredPassword, 'Cards2026!');
      expect(api.registeredNickname, '玩家');
      expect(api.registeredAvatarUrl, isNull);
      final formAbsorber = find.ancestor(
        of: find.byKey(const ValueKey('register-account-field')),
        matching: find.byType(AbsorbPointer),
      );
      expect(
        tester.widget<AbsorbPointer>(formAbsorber.first).absorbing,
        isTrue,
      );
      expect(
        tester
            .widgetList<TextFormField>(find.byType(TextFormField))
            .map((field) => field.controller!.text.trim()),
        ['player01', 'Cards2026!', 'Cards2026!', '玩家'],
      );

      api.registerCompleter.complete(_session);
      await tester.pumpAndSettle();
      expect(api.profileAccessToken, 'access');
      expect(api.profileNickname, '玩家');
      expect(api.registeredAvatarUrl, 'huai-avatar://locked');
      expect(find.text('游戏大厅'), findsOneWidget);
    },
  );

  testWidgets(
    'registration reports post-registration failures and enters app',
    (tester) async {
      final api = _FakeApiClient()..profileUpdateError = 'profile unavailable';
      final auth = AuthController(
        api: api,
        store: _FakeSessionStore(failWrites: true),
      );
      await tester.pumpWidget(ClientApp(auth: auth));
      await tester.pumpAndSettle();
      await tester.tap(find.text('创建账号'));
      await tester.pumpAndSettle();

      await _enterText(tester, 'register-account-field', 'player01');
      await _enterText(tester, 'register-password-field', 'Cards2026!');
      await _enterText(tester, 'register-confirm-password-field', 'Cards2026!');
      await _enterText(tester, 'register-nickname-field', '玩家');
      await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
      await tester.tap(find.widgetWithText(FilledButton, '注册'));
      await tester.pump();

      api.registerCompleter.complete(_session);
      await tester.pumpAndSettle();

      expect(find.text('游戏大厅'), findsOneWidget);
      expect(auth.error, contains('账号已创建，但登录状态无法保存。'));
      expect(auth.error, contains('账号已创建，但头像暂未保存。'));
    },
  );

  testWidgets('registration password visibility can be toggled', (
    tester,
  ) async {
    final auth = AuthController(
      api: _FakeApiClient(),
      store: _FakeSessionStore(),
    );
    await auth.restoreSession();
    await tester.pumpWidget(MaterialApp(home: RegisterScreen(auth: auth)));

    final passwordField = find.byKey(const ValueKey('register-password-field'));
    final passwordTextField = find.descendant(
      of: passwordField,
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(passwordTextField).obscureText, isTrue);
    await tester.tap(find.byTooltip('显示密码'));
    await tester.pump();
    expect(tester.widget<TextField>(passwordTextField).obscureText, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    auth.dispose();
  });

  testWidgets('registration validates UTF-8 byte limits', (tester) async {
    final api = _FakeApiClient();
    final auth = AuthController(api: api, store: _FakeSessionStore());
    await auth.restoreSession();
    await tester.pumpWidget(MaterialApp(home: RegisterScreen(auth: auth)));

    final overlongPassword = 'Aa1${List.filled(42, '界').join()}';
    await _enterText(
      tester,
      'register-account-field',
      List.filled(22, '界').join(),
    );
    await _enterText(tester, 'register-password-field', overlongPassword);
    await _enterText(
      tester,
      'register-confirm-password-field',
      overlongPassword,
    );
    await _enterText(tester, 'register-nickname-field', '玩家');
    await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();

    expect(find.text('账号须为3到64字节且不能包含空格'), findsOneWidget);
    expect(find.text('密码须为8到128字节且需包含字母和数字'), findsOneWidget);
    expect(api.registeredAccount, isNull);

    await _enterText(
      tester,
      'register-account-field',
      '${List.filled(127, 'é').join()}@a',
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();
    expect(find.text('邮箱账号不得超过254字节'), findsOneWidget);
    expect(api.registeredAccount, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    auth.dispose();
  });

  test('duplicate registration does not issue another request', () async {
    final api = _FakeApiClient();
    final auth = AuthController(api: api, store: _FakeSessionStore());
    await auth.restoreSession();

    final firstAttempt = auth.register(
      'player01',
      'Cards2026!',
      '玩家',
      'huai-avatar://login',
    );
    expect(auth.isLoading, isTrue);
    expect(
      await auth.register(
        'player01',
        'Cards2026!',
        '玩家',
        'huai-avatar://login',
      ),
      isFalse,
    );
    expect(api.registerCount, 1);

    api.registerCompleter.complete(_session);
    expect(await firstAttempt, isTrue);
    expect(auth.session, _session);
    expect(auth.error, isNull);
    auth.dispose();
  });

  testWidgets('registration shows server errors and remains on the form', (
    tester,
  ) async {
    final api = _FakeApiClient();
    final auth = AuthController(api: api, store: _FakeSessionStore());
    await auth.restoreSession();
    await tester.pumpWidget(MaterialApp(home: RegisterScreen(auth: auth)));
    await _enterText(tester, 'register-account-field', 'player01');
    await _enterText(tester, 'register-password-field', 'Cards2026!');
    await _enterText(tester, 'register-confirm-password-field', 'Cards2026!');
    await _enterText(tester, 'register-nickname-field', '玩家');
    await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pump();

    api.registerCompleter.completeError(
      GrpcError.alreadyExists('account already exists'),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('account already exists'), findsOneWidget);
    expect(find.byType(RegisterScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    auth.dispose();
  });

  testWidgets('registration form scrolls on short viewports', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 240));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(
      api: _FakeApiClient(),
      store: _FakeSessionStore(),
    );
    await auth.restoreSession();
    await tester.pumpWidget(MaterialApp(home: RegisterScreen(auth: auth)));

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(null);
    await tester.pumpWidget(const SizedBox.shrink());
    auth.dispose();
  });
}

Future<void> _enterText(
  WidgetTester tester,
  String fieldKey,
  String value,
) async {
  final finder = find.byKey(ValueKey(fieldKey));
  await tester.ensureVisible(finder);
  await tester.enterText(finder, value);
  await tester.pump();
}

class _FakeApiClient implements ApiClient {
  final registerCompleter = Completer<AuthSession>();
  var registerCount = 0;
  String? registeredAccount;
  String? registeredPassword;
  String? registeredNickname;
  String? registeredAvatarUrl;
  String? profileAccessToken;
  String? profileNickname;
  String? profileUpdateError;

  @override
  Future<AuthSession> login({
    required String account,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AuthSession> register({
    required String account,
    required String password,
    required String nickname,
  }) {
    registerCount++;
    registeredAccount = account;
    registeredPassword = password;
    registeredNickname = nickname;
    return registerCompleter.future;
  }

  @override
  Future<void> updateProfile({
    required String accessToken,
    required String nickname,
    required String avatarUrl,
  }) async {
    profileAccessToken = accessToken;
    profileNickname = nickname;
    registeredAvatarUrl = avatarUrl;
    if (profileUpdateError case final error?) throw StateError(error);
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async =>
      throw UnimplementedError();

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<List<LobbyHall>> listHalls({required String accessToken}) async =>
      const [];

  @override
  Future<List<LobbyRoom>> listRooms({
    required String accessToken,
    required String hallId,
  }) async => const [];

  @override
  Future<LobbyRoom> createRoom({
    required String accessToken,
    required String hallId,
    required String name,
    required String password,
    bool allowSpectators = false,
    int minimumPoints = 0,
    String requestId = '',
  }) => throw UnimplementedError();

  @override
  Future<LobbyRoom> joinRoom({
    required String accessToken,
    required String roomId,
    int expectedVersion = 0,
  }) => throw UnimplementedError();

  @override
  Future<void> leaveRoom({
    required String accessToken,
    required String roomId,
    required int expectedVersion,
    required String requestId,
  }) async {}

  @override
  Future<LobbyRoom> getRoom({
    required String accessToken,
    required String roomId,
  }) => throw UnimplementedError();

  @override
  Future<LobbyRoom> joinByCode({
    required String accessToken,
    required String roomCode,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<PlayerStatistics> getStatistics({required String accessToken}) async =>
      const PlayerStatistics(
        totalGames: 0,
        wins: 0,
        losses: 0,
        points: 0,
        rank: '',
      );

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
  }) async => const [];

  @override
  Future<List<PlayerFriend>> listFriends({required String accessToken}) async =>
      const [];

  @override
  Future<List<PlayerFriend>> searchPlayers({
    required String accessToken,
    required String query,
  }) async => const [];

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
  }) async => const ChatMessagesPage(messages: [], nextPageToken: '');

  @override
  Future<ChatMessage> sendPrivateMessage({
    required String accessToken,
    required String peerUserId,
    required String body,
    required String requestId,
  }) async => ChatMessage(
    id: 'message',
    senderUserId: '',
    body: body,
    createdAt: DateTime.utc(2026),
  );

  @override
  Future<void> sendRoomInvite({
    required String accessToken,
    required String roomId,
    required String friendId,
    String requestId = '',
  }) async {}

  @override
  Future<LobbyRoom> joinInvitedRoom({
    required String accessToken,
    required String roomId,
    required String requestId,
  }) => throw UnimplementedError();

  @override
  Future<void> hidePrivateMessage({
    required String accessToken,
    required String messageId,
  }) async {}

  @override
  Future<void> reportPrivateMessage({
    required String accessToken,
    required String messageId,
    String reason = '',
  }) async {}

  @override
  Future<ChatMessage> sendRoomMessage({
    required String accessToken,
    required String roomId,
    required String body,
    required String requestId,
  }) => throw UnimplementedError();

  @override
  Future<void> close() async {}
}

class _FakeSessionStore implements SessionStore {
  _FakeSessionStore({this.failWrites = false});

  final bool failWrites;

  @override
  Future<AuthSession?> read() async => null;

  @override
  Future<void> write(AuthSession session) async {
    if (failWrites) throw StateError('storage unavailable');
  }

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
