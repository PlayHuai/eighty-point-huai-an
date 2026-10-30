import 'package:eighty_point_huai_an/src/api/api_client.dart';
import 'package:eighty_point_huai_an/src/api/lobby_models.dart';
import 'package:eighty_point_huai_an/src/api/player_models.dart';
import 'package:eighty_point_huai_an/src/auth/auth_controller.dart';
import 'package:eighty_point_huai_an/src/auth/auth_session.dart';
import 'package:eighty_point_huai_an/src/auth/session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

void main() {
  group('AuthController.restoreSession', () {
    test(
      'preserves saved credentials after a transient refresh failure',
      () async {
        final store = _FakeSessionStore(_session);
        final api = _FakeApiClient(
          onRefresh: (_) async => throw GrpcError.unavailable('offline'),
        );
        final controller = AuthController(api: api, store: store);

        await controller.restoreSession();

        expect(store.clearCount, 0);
        expect(store.session, _session);
        expect(controller.session, isNull);
        expect(controller.canRetryRestore, isTrue);
        expect(controller.error, contains('offline'));

        controller.dispose();
      },
    );

    test(
      'clears saved credentials when the refresh token is rejected',
      () async {
        final store = _FakeSessionStore(_session);
        final api = _FakeApiClient(
          onRefresh: (_) async =>
              throw GrpcError.unauthenticated('invalid token'),
        );
        final controller = AuthController(api: api, store: store);

        await controller.restoreSession();

        expect(store.clearCount, 1);
        expect(store.session, isNull);
        expect(controller.canRetryRestore, isFalse);
        expect(controller.error, isNull);

        controller.dispose();
      },
    );
  });
}

final _session = AuthSession(
  accessToken: 'access',
  refreshToken: 'refresh',
  expiresAt: DateTime.utc(2030),
  userId: 'user',
  nickname: 'Player',
);

class _FakeApiClient implements ApiClient {
  _FakeApiClient({required this.onRefresh});

  final Future<AuthSession> Function(String refreshToken) onRefresh;

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
  }) => throw UnimplementedError();

  @override
  Future<void> updateProfile({
    required String accessToken,
    required String nickname,
    required String avatarUrl,
  }) async {}

  @override
  Future<AuthSession> refresh(String refreshToken) => onRefresh(refreshToken);

  @override
  Future<void> logout(String refreshToken) => throw UnimplementedError();

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
  _FakeSessionStore(this.session);

  AuthSession? session;
  int clearCount = 0;

  @override
  Future<AuthSession?> read() async => session;

  @override
  Future<void> write(AuthSession session) async {
    this.session = session;
  }

  @override
  Future<void> clear() async {
    clearCount++;
    session = null;
  }
}
