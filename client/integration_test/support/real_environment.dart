import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:eighty_point_huai_an/src/api/api_client.dart';
import 'package:eighty_point_huai_an/src/api/channel_factory.dart';
import 'package:eighty_point_huai_an/src/api/lobby_models.dart';
import 'package:eighty_point_huai_an/src/api/request_id.dart';
import 'package:eighty_point_huai_an/src/auth/auth_controller.dart';
import 'package:eighty_point_huai_an/src/auth/auth_session.dart';
import 'package:eighty_point_huai_an/src/auth/session_store.dart';
import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pbgrpc.dart'
    as pb;
import 'package:eighty_point_huai_an/src/ui/client_app.dart';
import 'package:eighty_point_huai_an/src/ui/game_table_screen.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/service_api.dart';
import 'package:grpc/grpc.dart' show GrpcError;

const testPassword = 'Cards2026!integration';
const apiEndpointValue = String.fromEnvironment('API_ENDPOINT');
const websocketEndpointValue = String.fromEnvironment('WEBSOCKET_ENDPOINT');
final apiEndpoint = Uri.parse(apiEndpointValue);
final websocketEndpoint = Uri.parse(websocketEndpointValue);

class TestUser {
  const TestUser(this.account, this.session);
  final String account;
  final AuthSession session;
  String get id => session.userId;
  String get token => session.accessToken;
}

// Isolate test sessions from the Windows user's existing secure-storage login.
// All credentials, refreshes and protected calls still come from the real server.
class TestSessionStore implements SessionStore {
  TestSessionStore([this.session]);
  AuthSession? session;
  @override
  Future<AuthSession?> read() async => session;
  @override
  Future<void> write(AuthSession value) async => session = value;
  @override
  Future<void> clear() async => session = null;
}

class RealEnvironment {
  RealEnvironment(this.tester)
    : channel = createClientChannel(apiEndpoint),
      api = GrpcApiClient(apiEndpoint);

  final WidgetTester tester;
  final ClientChannel channel;
  final GrpcApiClient api;
  final trace = StringBuffer();
  final boundaryKey = GlobalKey();
  AuthController? auth;
  final users = <TestUser>[];
  final rooms = <(TestUser, String)>[];
  final _initialRoomVersions = <String, int>{};
  final _roomMembers = <String, TestUser>{};
  late final lobby = pb.LobbyServiceClient(channel);
  late final room = pb.RoomServiceClient(channel);
  late final game = pb.GameServiceClient(channel);
  late final player = pb.PlayerServiceClient(channel);
  late final friends = pb.FriendServiceClient(channel);

  void step(String value) =>
      trace.writeln('${DateTime.now().toIso8601String()} $value');

  CallOptions options(TestUser user) => CallOptions(
    metadata: {'authorization': 'Bearer ${user.token}'},
    timeout: const Duration(seconds: 15),
  );

  Future<TestUser> user() async {
    final account = 'it_${createRequestId().replaceAll('-', '')}';
    final session = await api
        .register(
          account: account,
          password: testPassword,
          nickname: '测试${account.substring(account.length - 8)}',
        )
        .timeout(const Duration(seconds: 20));
    final value = TestUser(account, session);
    users.add(value);
    step('Created isolated test account ${value.id}');
    return value;
  }

  Future<void> mount({TestUser? signedIn}) async {
    final uiSession = signedIn == null
        ? null
        : await api.login(account: signedIn.account, password: testPassword);
    final controller = AuthController(
      api: GrpcApiClient(apiEndpoint),
      store: TestSessionStore(uiSession),
    );
    auth = controller;
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: ClientApp(
          auth: controller,
          endpoint: apiEndpoint,
          websocketEndpoint: websocketEndpoint,
        ),
      ),
    );
    await waitFor(() => !controller.isLoading, 'session restore');
    if (signedIn != null) {
      await visible(find.text('游戏大厅'));
    } else {
      await visible(find.byKey(const ValueKey('login-account-field')));
    }
  }

  Future<void> waitFor(
    bool Function() condition,
    String description, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (!condition()) {
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException('Waiting for $description', timeout);
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump();
  }

  Future<void> visible(Finder finder) =>
      waitFor(() => finder.evaluate().isNotEmpty, finder.toString());

  Future<void> tap(Finder finder) async {
    await visible(finder);
    await tester.ensureVisible(finder.first);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(finder.first);
    await tester.pump(const Duration(milliseconds: 200));
  }

  Future<void> text(String key, String value) async {
    final finder = find.byKey(ValueKey(key));
    await visible(finder);
    await tester.ensureVisible(finder);
    await tester.enterText(finder, value);
    await tester.pump();
  }

  Future<void> registerForm({
    String? account,
    String password = testPassword,
    String? confirmation,
    String nickname = '集成测试玩家',
  }) async {
    await mount();
    await tap(find.text('创建账号'));
    await text(
      'register-account-field',
      account ?? 'it_${createRequestId().replaceAll('-', '')}',
    );
    await text('register-password-field', password);
    await text('register-confirm-password-field', confirmation ?? password);
    await text('register-nickname-field', nickname);
    await tap(find.widgetWithText(FilledButton, '注册'));
  }

  Future<LobbyRoom> create(
    TestUser owner, {
    String hall = 'ordinary',
    String password = '',
    bool spectators = true,
    String? requestId,
    String? name,
  }) async {
    final value = await api.createRoom(
      accessToken: owner.token,
      hallId: hall,
      name: name ?? '测试${createRequestId().substring(0, 8)}',
      password: password,
      allowSpectators: spectators,
      requestId: requestId ?? createRequestId(),
    );
    rooms.add((owner, value.id));
    _initialRoomVersions[value.id] = value.version;
    return value;
  }

  Future<pb.RoomDetails> details(TestUser user, String id) =>
      room.getRoom(pb.RoomRequest(roomId: id), options: options(user));

  Future<void> join(TestUser user, String id) async {
    final member = _roomMembers[id];
    final version = member == null
        ? Int64(_initialRoomVersions[id]!)
        : (await details(member, id)).version;
    await lobby.joinRoom(
      pb.RoomRequest(
        roomId: id,
        requestId: createRequestId(),
        expectedVersion: version,
      ),
      options: options(user),
    );
    _roomMembers.putIfAbsent(id, () => user);
  }

  Future<pb.RoomDetails> sit(TestUser user, String id, int seat) async {
    final current = await details(user, id);
    final member = current.members.singleWhere(
      (value) => value.userId == user.id,
    );
    if (member.seatNo == seat) return current;
    final request = pb.SeatRequest(
      roomId: id,
      seatNo: seat,
      expectedVersion: current.version,
      requestId: createRequestId(),
    );
    return member.seatNo == 0
        ? room.sitDown(request, options: options(user))
        : room.changeSeat(request, options: options(user));
  }

  Future<(List<TestUser>, LobbyRoom, pb.GameSnapshot)> start({
    String? scenario,
  }) async {
    final players = <TestUser>[];
    for (var i = 0; i < 4; i++) {
      players.add(await user());
    }
    final created = await create(players.first);
    for (var i = 0; i < players.length; i++) {
      await join(players[i], created.id);
      await sit(players[i], created.id, i + 1);
    }
    final current = await details(players.first, created.id);
    final snapshot = await room.startGame(
      pb.RoomRequest(
        roomId: created.id,
        requestId: createRequestId(),
        expectedVersion: current.version,
      ),
      options: CallOptions(
        metadata: {
          'authorization': 'Bearer ${players.first.token}',
          if (scenario != null) 'x-huai-test-scenario': scenario,
        },
        timeout: const Duration(seconds: 20),
      ),
    );
    step('Started real four-player game ${snapshot.gameSessionId}');
    return (players, created, snapshot);
  }

  Future<pb.GameSnapshot> snapshot(TestUser user, String id) =>
      game.getGameSnapshot(
        pb.GameSnapshotRequest(gameSessionId: id),
        options: options(user),
      );

  Future<pb.SubmitActionResponse> submit(
    TestUser user,
    pb.GameSnapshot state,
    pb.GameAction action, {
    String? requestId,
    Int64? version,
  }) => game.submitAction(
    pb.SubmitActionRequest(
      gameSessionId: state.gameSessionId,
      handId: state.handId,
      requestId: requestId ?? createRequestId(),
      expectedVersion: version ?? state.stateVersion,
      action: action,
    ),
    options: options(user),
  );

  Future<void> makeFriends(TestUser a, TestUser b) async {
    await api.sendFriendRequest(
      accessToken: a.token,
      userId: b.id,
      requestId: createRequestId(),
    );
    await api.respondFriendRequest(
      accessToken: b.token,
      userId: a.id,
      accept: true,
      requestId: createRequestId(),
    );
  }

  Future<void> showTable(TestUser user, LobbyRoom value) async {
    await mount(signedIn: user);
    final context = tester.element(find.text('游戏大厅'));
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => GameTableScreen(auth: auth!, room: value),
        ),
      ),
    );
    await visible(find.byKey(const ValueKey('room-identity')));
  }

  Future<void> screenshot(String path) async {
    final boundary = boundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary || boundary.debugNeedsPaint) {
      step('No painted UI available for screenshot.');
      return;
    }
    final image = await boundary.toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('PNG encoding failed.');
      await File(path).writeAsBytes(bytes.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  }

  Future<void> close() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 200));
    // Test accounts/data remain in the isolated deployment for issue review.
    await api.close();
    await channel.shutdown();
  }
}

Future<void> grpcError(Future<Object?> Function() operation, int code) async {
  await expectLater(
    operation(),
    throwsA(
      isA<GrpcError>().having((error) => error.code, 'gRPC status', code),
    ),
  );
}
