import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pbgrpc.dart'
    as api;
import 'package:fixnum/fixnum.dart';
import 'package:grpc/service_api.dart';

import 'channel_factory.dart';
import '../auth/auth_session.dart';
import 'lobby_models.dart';
import 'player_models.dart';
import 'request_id.dart';

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
    bool allowSpectators = false,
    int minimumPoints = 0,
    String requestId = '',
  });

  Future<LobbyRoom> joinRoom({
    required String accessToken,
    required String roomId,
    int expectedVersion = 0,
  });

  Future<void> leaveRoom({
    required String accessToken,
    required String roomId,
    required int expectedVersion,
    required String requestId,
  }) => throw UnsupportedError('Room departure is not supported.');

  Future<LobbyRoom> getRoom({
    required String accessToken,
    required String roomId,
  }) => throw UnsupportedError('Room refresh is not supported.');

  Future<LobbyRoom> joinByCode({
    required String accessToken,
    required String roomCode,
    required String password,
  });

  Future<PlayerStatistics> getStatistics({required String accessToken});

  Future<PlayerStatistics> getFriendStatistics({
    required String accessToken,
    required String userId,
  });

  Future<FriendRecentResultsPage> listFriendRecentResults({
    required String accessToken,
    required String userId,
    String pageToken = '',
    int pageSize = 20,
  });

  Future<List<RoomInvitation>> listRoomInvitations({
    required String accessToken,
  });

  Future<List<PlayerFriend>> listFriends({required String accessToken});

  Future<List<PlayerFriend>> searchPlayers({
    required String accessToken,
    required String query,
  }) => throw UnsupportedError('Player search is not supported.');

  Future<void> sendFriendRequest({
    required String accessToken,
    required String userId,
    String requestId = '',
  }) => throw UnsupportedError('Friend requests are not supported.');

  Future<List<PlayerFriend>> listFriendRequests({
    required String accessToken,
  }) => throw UnsupportedError('Friend request listing is not supported.');

  Future<void> respondFriendRequest({
    required String accessToken,
    required String userId,
    required bool accept,
    String requestId = '',
  }) => throw UnsupportedError('Friend request responses are not supported.');

  Future<void> removeFriend({
    required String accessToken,
    required String userId,
    String requestId = '',
  }) => throw UnsupportedError('Friend removal is not supported.');

  Future<ChatMessagesPage> listPrivateMessages({
    required String accessToken,
    required String peerUserId,
    String pageToken = '',
    int pageSize = 50,
  }) => throw UnsupportedError('Private messages are not supported.');

  Future<ChatMessage> sendPrivateMessage({
    required String accessToken,
    required String peerUserId,
    required String body,
    required String requestId,
  }) => throw UnsupportedError('Private messages are not supported.');

  Future<void> hidePrivateMessage({
    required String accessToken,
    required String messageId,
  }) => throw UnsupportedError('Private message hiding is not supported.');

  Future<void> reportPrivateMessage({
    required String accessToken,
    required String messageId,
    String reason = '',
  }) => throw UnsupportedError('Private message reporting is not supported.');

  Future<ChatMessage> sendRoomMessage({
    required String accessToken,
    required String roomId,
    required String body,
    required String requestId,
  }) => throw UnsupportedError('Room chat is not supported.');

  Future<void> sendRoomInvite({
    required String accessToken,
    required String roomId,
    required String friendId,
    String requestId = '',
  });

  Future<LobbyRoom> joinInvitedRoom({
    required String accessToken,
    required String roomId,
    required String requestId,
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
  late final api.FriendServiceClient _friends = api.FriendServiceClient(
    _channel,
  );
  late final api.RoomServiceClient _room = api.RoomServiceClient(_channel);
  late final api.ChatServiceClient _chat = api.ChatServiceClient(_channel);

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
            minimumPoints: hall.minimumPoints.toInt(),
            maximumPoints: hall.maximumPoints.toInt(),
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
    bool allowSpectators = false,
    int minimumPoints = 0,
    String requestId = '',
  }) async {
    final response = await _lobby.createRoom(
      api.CreateRoomRequest()
        ..hallId = hallId
        ..name = name
        ..password = password
        ..allowSpectators = allowSpectators
        ..minimumPoints = Int64(minimumPoints)
        ..requestId = requestId.isEmpty ? createRequestId() : requestId,
      options: _authenticatedOptions(accessToken),
    );
    return _roomFrom(response);
  }

  @override
  Future<LobbyRoom> joinRoom({
    required String accessToken,
    required String roomId,
    int expectedVersion = 0,
  }) async {
    final response = await _lobby.joinRoom(
      api.RoomRequest()
        ..roomId = roomId
        ..expectedVersion = Int64(expectedVersion),
      options: _authenticatedOptions(accessToken),
    );
    return _roomFrom(response);
  }

  @override
  Future<void> leaveRoom({
    required String accessToken,
    required String roomId,
    required int expectedVersion,
    required String requestId,
  }) async {
    await _lobby.leaveRoom(
      api.RoomRequest()
        ..roomId = roomId
        ..requestId = requestId
        ..expectedVersion = Int64(expectedVersion),
      options: _authenticatedOptions(accessToken),
    );
  }

  @override
  Future<LobbyRoom> getRoom({
    required String accessToken,
    required String roomId,
  }) async {
    final response = await _room.getRoom(
      api.RoomRequest()..roomId = roomId,
      options: _authenticatedOptions(accessToken),
    );
    return _roomFrom(response.room);
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

  @override
  Future<PlayerStatistics> getStatistics({required String accessToken}) async {
    final response = await _player.getStatistics(
      api.Empty(),
      options: _authenticatedOptions(accessToken),
    );
    return PlayerStatistics(
      totalGames: response.totalGames.toInt(),
      wins: response.wins.toInt(),
      losses: response.losses.toInt(),
      points: response.points.toInt(),
      rank: response.rank,
    );
  }

  @override
  Future<PlayerStatistics> getFriendStatistics({
    required String accessToken,
    required String userId,
  }) async {
    final response = await _player.getFriendStatistics(
      api.GetFriendStatisticsRequest()..userId = userId,
      options: _authenticatedOptions(accessToken),
    );
    return PlayerStatistics(
      totalGames: response.totalGames.toInt(),
      wins: response.wins.toInt(),
      losses: response.losses.toInt(),
      points: response.points.toInt(),
      rank: response.rank,
    );
  }

  @override
  Future<FriendRecentResultsPage> listFriendRecentResults({
    required String accessToken,
    required String userId,
    String pageToken = '',
    int pageSize = 20,
  }) async {
    final response = await _player.listFriendRecentResults(
      api.ListFriendRecentResultsRequest()
        ..userId = userId
        ..page = (api.PageRequest()
          ..pageToken = pageToken
          ..pageSize = pageSize),
      options: _authenticatedOptions(accessToken),
    );
    return FriendRecentResultsPage(
      results: response.results
          .map(
            (result) => RecentGameResult(
              gameSessionId: result.gameSessionId,
              won: result.won,
              pointsDelta: result.pointsDelta.toInt(),
              endedAt: result.endedAt.toDateTime(),
            ),
          )
          .toList(growable: false),
      nextPageToken: response.page.nextPageToken,
    );
  }

  @override
  Future<List<RoomInvitation>> listRoomInvitations({
    required String accessToken,
  }) async {
    final invitations = <RoomInvitation>[];
    final seenPageTokens = <String>{};
    var pageToken = '';
    do {
      final response = await _friends.listRoomInvitations(
        api.PageRequest()
          ..pageToken = pageToken
          ..pageSize = 50,
        options: _authenticatedOptions(accessToken),
      );
      invitations.addAll(
        response.invitations.map(
          (invitation) => RoomInvitation(
            roomId: invitation.roomId,
            inviterUserId: invitation.inviter.userId,
            inviterNickname: invitation.inviter.nickname,
            invitedAt: invitation.invitedAt.toDateTime(),
          ),
        ),
      );
      final nextPageToken = response.page.nextPageToken;
      if (nextPageToken.isEmpty || !seenPageTokens.add(nextPageToken)) break;
      pageToken = nextPageToken;
    } while (true);
    return invitations;
  }

  @override
  Future<void> sendRoomInvite({
    required String accessToken,
    required String roomId,
    required String friendId,
    String requestId = '',
  }) async {
    await _friends.sendRoomInvite(
      api.SendRoomInviteRequest()
        ..roomId = roomId
        ..friendId = friendId
        ..requestId = requestId.isEmpty ? createRequestId() : requestId,
      options: _authenticatedOptions(accessToken),
    );
  }

  @override
  Future<List<PlayerFriend>> listFriends({required String accessToken}) async {
    final friends = <PlayerFriend>[];
    final seenPageTokens = <String>{};
    var pageToken = '';
    do {
      final response = await _friends.listFriends(
        api.PageRequest()
          ..pageToken = pageToken
          ..pageSize = 50,
        options: _authenticatedOptions(accessToken),
      );
      friends.addAll(
        response.friends.map(
          (friend) => PlayerFriend(
            userId: friend.profile.userId,
            nickname: friend.profile.nickname,
            avatarUrl: friend.profile.avatarUrl,
            isOnline: friend.online,
          ),
        ),
      );
      final nextPageToken = response.page.nextPageToken;
      if (nextPageToken.isEmpty || !seenPageTokens.add(nextPageToken)) break;
      pageToken = nextPageToken;
    } while (true);
    return friends;
  }

  @override
  Future<List<PlayerFriend>> searchPlayers({
    required String accessToken,
    required String query,
  }) async {
    final response = await _friends.searchPlayers(
      api.SearchPlayersRequest()
        ..query = query
        ..page = (api.PageRequest()..pageSize = 50),
      options: _authenticatedOptions(accessToken),
    );
    return response.players
        .map(
          (profile) => PlayerFriend(
            userId: profile.userId,
            nickname: profile.nickname,
            avatarUrl: profile.avatarUrl,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> sendFriendRequest({
    required String accessToken,
    required String userId,
    String requestId = '',
  }) async {
    await _friends.sendRequest(
      api.FriendRequest()
        ..targetUserId = userId
        ..requestId = requestId.isEmpty ? createRequestId() : requestId,
      options: _authenticatedOptions(accessToken),
    );
  }

  @override
  Future<List<PlayerFriend>> listFriendRequests({
    required String accessToken,
  }) async {
    final response = await _friends.listFriendRequests(
      api.PageRequest()..pageSize = 50,
      options: _authenticatedOptions(accessToken),
    );
    return response.requests
        .map(
          (request) => PlayerFriend(
            userId: request.requester.userId,
            nickname: request.requester.nickname,
            avatarUrl: request.requester.avatarUrl,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> respondFriendRequest({
    required String accessToken,
    required String userId,
    required bool accept,
    String requestId = '',
  }) async {
    await _friends.respondRequest(
      api.RespondFriendRequest()
        ..requesterUserId = userId
        ..accept = accept
        ..requestId = requestId.isEmpty ? createRequestId() : requestId,
      options: _authenticatedOptions(accessToken),
    );
  }

  @override
  Future<void> removeFriend({
    required String accessToken,
    required String userId,
    String requestId = '',
  }) async {
    await _friends.removeFriend(
      api.FriendRequest()
        ..targetUserId = userId
        ..requestId = requestId.isEmpty ? createRequestId() : requestId,
      options: _authenticatedOptions(accessToken),
    );
  }

  @override
  Future<ChatMessagesPage> listPrivateMessages({
    required String accessToken,
    required String peerUserId,
    String pageToken = '',
    int pageSize = 50,
  }) async {
    final response = await _chat.listPrivateMessages(
      api.ListPrivateMessagesRequest()
        ..peerUserId = peerUserId
        ..page = (api.PageRequest()
          ..pageToken = pageToken
          ..pageSize = pageSize),
      options: _authenticatedOptions(accessToken),
    );
    return ChatMessagesPage(
      messages: response.messages
          .map(
            (message) => ChatMessage(
              id: message.messageId,
              senderUserId: message.senderUserId,
              body: message.body,
              createdAt: message.createdAt.toDateTime(),
            ),
          )
          .toList(growable: false),
      nextPageToken: response.page.nextPageToken,
    );
  }

  @override
  Future<ChatMessage> sendPrivateMessage({
    required String accessToken,
    required String peerUserId,
    required String body,
    required String requestId,
  }) async {
    final message = await _chat.sendPrivateMessage(
      api.SendPrivateMessageRequest()
        ..recipientUserId = peerUserId
        ..requestId = requestId
        ..body = body,
      options: _authenticatedOptions(accessToken),
    );
    return ChatMessage(
      id: message.messageId,
      senderUserId: message.senderUserId,
      body: message.body,
      createdAt: message.createdAt.toDateTime(),
    );
  }

  @override
  Future<void> hidePrivateMessage({
    required String accessToken,
    required String messageId,
  }) async {
    await _chat.hidePrivateMessage(
      api.HidePrivateMessageRequest()..messageId = messageId,
      options: _authenticatedOptions(accessToken),
    );
  }

  @override
  Future<void> reportPrivateMessage({
    required String accessToken,
    required String messageId,
    String reason = '',
  }) async {
    await _chat.reportPrivateMessage(
      api.ReportPrivateMessageRequest()
        ..messageId = messageId
        ..reason = reason,
      options: _authenticatedOptions(accessToken),
    );
  }

  @override
  Future<ChatMessage> sendRoomMessage({
    required String accessToken,
    required String roomId,
    required String body,
    required String requestId,
  }) async {
    final message = await _chat.sendRoomMessage(
      api.SendRoomMessageRequest()
        ..roomId = roomId
        ..requestId = requestId
        ..body = body,
      options: _authenticatedOptions(accessToken),
    );
    return ChatMessage(
      id: message.messageId,
      senderUserId: message.senderUserId,
      body: message.body,
      createdAt: message.createdAt.toDateTime(),
    );
  }

  @override
  Future<LobbyRoom> joinInvitedRoom({
    required String accessToken,
    required String roomId,
    required String requestId,
  }) async {
    final response = await _room.joinInvitedRoom(
      api.JoinInvitedRoomRequest()
        ..roomId = roomId
        ..requestId = requestId,
      options: _authenticatedOptions(accessToken),
    );
    return _roomFrom(response.room);
  }

  CallOptions _authenticatedOptions(String accessToken) =>
      CallOptions(metadata: {'authorization': 'Bearer ' + accessToken});

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
    version: room.version.toInt(),
    allowSpectators: room.allowSpectators,
    minimumPoints: room.minimumPoints.toInt(),
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
