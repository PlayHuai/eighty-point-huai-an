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
    test('preserves saved credentials after a transient refresh failure', () async {
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
    });

    test('clears saved credentials when the refresh token is rejected', () async {
      final store = _FakeSessionStore(_session);
      final api = _FakeApiClient(
        onRefresh: (_) async => throw GrpcError.unauthenticated('invalid token'),
      );
      final controller = AuthController(api: api, store: store);

      await controller.restoreSession();

      expect(store.clearCount, 1);
      expect(store.session, isNull);
      expect(controller.canRetryRestore, isFalse);
      expect(controller.error, isNull);

      controller.dispose();
    });
  });
}

const _session = AuthSession(
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
  }) => throw UnimplementedError();

  @override
  Future<LobbyRoom> joinRoom({
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
  Future<void> sendRoomInvite({
    required String accessToken,
    required String roomId,
    required String friendId,
  }) async {}

  @override
  Future<LobbyRoom> joinInvitedRoom({
    required String accessToken,
    required String roomId,
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
