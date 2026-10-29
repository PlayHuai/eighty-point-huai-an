import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pbgrpc.dart'
    as api;
import 'package:grpc/service_api.dart';

import 'channel_factory.dart';
import '../auth/auth_session.dart';
import 'lobby_models.dart';

abstract interface class ApiClient {
  Future<AuthSession> login({
    required String account,
    required String password,
  });

  Future<AuthSession> register({
    required String account,
    required String password,
    required String nickname,
  });

  Future<void> updateProfile({
    required String accessToken,
    required String nickname,
    required String avatarUrl,
  });

  Future<AuthSession> refresh(String refreshToken);

  Future<void> logout(String refreshToken);

  Future<List<LobbyHall>> listHalls({required String accessToken});

  Future<List<LobbyRoom>> listRooms({
    required String accessToken,
    required String hallId,
  });

  Future<LobbyRoom> createRoom({
    required String accessToken,
    required String hallId,
    required String name,
    required String password,
  });

  Future<LobbyRoom> joinRoom({
    required String accessToken,
    required String roomId,
  });

  Future<LobbyRoom> joinByCode({
    required String accessToken,
    required String roomCode,
    required String password,
  });

  Future<void> close();
}

class GrpcApiClient implements ApiClient {
  GrpcApiClient(Uri endpoint) : _channel = createClientChannel(endpoint) {
    _auth = api.AuthServiceClient(_channel);
    _player = api.PlayerServiceClient(_channel);
  }

  final ClientChannel _channel;
  late final api.AuthServiceClient _auth;
  late final api.PlayerServiceClient _player;
  late final api.LobbyServiceClient _lobby = api.LobbyServiceClient(_channel);

  @override
  Future<AuthSession> login({
    required String account,
    required String password,
  }) async {
    final response = await _auth.login(
      api.LoginRequest()
        ..account = account
        ..password = password,
    );
    return _sessionFrom(response);
  }

  @override
  Future<AuthSession> register({
    required String account,
    required String password,
    required String nickname,
  }) async {
    final response = await _auth.register(
      api.RegisterRequest()
        ..account = account
        ..password = password
        ..nickname = nickname,
    );
    return _sessionFrom(response);
  }

  @override
  Future<void> updateProfile({
    required String accessToken,
    required String nickname,
    required String avatarUrl,
  }) async {
    await _player.updateProfile(
      api.UpdateProfileRequest()
        ..nickname = nickname
        ..avatarUrl = avatarUrl,
      options: CallOptions(
        metadata: {'authorization': 'Bearer ' + accessToken},
      ),
    );
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    final response = await _auth.refreshSession(
      api.RefreshSessionRequest()..refreshToken = refreshToken,
    );
    return _sessionFrom(response);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _auth.logout(api.LogoutRequest()..refreshToken = refreshToken);
  }

  @override
  Future<List<LobbyHall>> listHalls({required String accessToken}) async {
    final response = await _lobby.listHalls(
      api.Empty(),
      options: _authenticatedOptions(accessToken),
    );
    return response.halls
        .map(
          (hall) => LobbyHall(
            id: hall.hallId,
            name: hall.name,
            minimumPoints: hall.minimumPoints,
            maximumPoints: hall.maximumPoints,
            multiplier: hall.multiplierBasisPoints / 10000,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<LobbyRoom>> listRooms({
    required String accessToken,
    required String hallId,
  }) async {
    final rooms = <LobbyRoom>[];
    final seenPageTokens = <String>{};
    var pageToken = '';
    do {
      final response = await _lobby.listRooms(
        api.ListRoomsRequest()
          ..hallId = hallId
          ..page = (api.PageRequest()
            ..pageSize = 50
            ..pageToken = pageToken),
        options: _authenticatedOptions(accessToken),
      );
      rooms.addAll(response.rooms.map(_roomFrom));
      final nextPageToken = response.page.nextPageToken;
      if (nextPageToken.isEmpty || !seenPageTokens.add(nextPageToken)) break;
      pageToken = nextPageToken;
    } while (true);
    return rooms;
  }

  @override
  Future<LobbyRoom> createRoom({
    required String accessToken,
    required String hallId,
    required String name,
    required String password,
  }) async {
    final response = await _lobby.createRoom(
      api.CreateRoomRequest()
        ..hallId = hallId
        ..name = name
        ..password = password,
      options: _authenticatedOptions(accessToken),
    );
    return _roomFrom(response);
  }

  @override
  Future<LobbyRoom> joinRoom({
    required String accessToken,
    required String roomId,
  }) async {
    final response = await _lobby.joinRoom(
      api.RoomRequest()..roomId = roomId,
      options: _authenticatedOptions(accessToken),
    );
    return _roomFrom(response);
  }

  @override
  Future<LobbyRoom> joinByCode({
    required String accessToken,
    required String roomCode,
    required String password,
  }) async {
    final response = await _lobby.joinByCode(
      api.JoinByCodeRequest()
        ..roomCode = roomCode
        ..password = password,
      options: _authenticatedOptions(accessToken),
    );
    return _roomFrom(response);
  }

  CallOptions _authenticatedOptions(String accessToken) => CallOptions(
    metadata: {'authorization': 'Bearer ' + accessToken},
  );

  LobbyRoom _roomFrom(api.RoomSummary room) => LobbyRoom(
    id: room.roomId,
    hallId: room.hallId,
    name: room.name,
    status: switch (room.status) {
      api.RoomStatus.ROOM_STATUS_WAITING => LobbyRoomStatus.waiting,
      api.RoomStatus.ROOM_STATUS_PLAYING => LobbyRoomStatus.playing,
      api.RoomStatus.ROOM_STATUS_CLOSED => LobbyRoomStatus.closed,
      _ => LobbyRoomStatus.unspecified,
    },
    occupiedSeats: room.occupiedSeats,
    capacity: room.capacity,
    hasPassword: room.hasPassword,
    version: room.version,
  );

  @override
  Future<void> close() => _channel.shutdown();

  AuthSession _sessionFrom(api.AuthResponse response) {
    final tokens = response.tokens;
    final profile = response.profile;
    return AuthSession(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresAt: tokens.accessTokenExpiresAt.toDateTime(),
      userId: profile.userId,
      nickname: profile.nickname,
    );
  }
}
