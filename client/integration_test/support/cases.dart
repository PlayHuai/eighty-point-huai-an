import 'dart:io';

import 'package:eighty_point_huai_an/src/api/event_socket.dart';
import 'package:eighty_point_huai_an/src/api/request_id.dart';
import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pbgrpc.dart'
    as pb;
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

import 'real_environment.dart';
import 'game_scenarios.dart';
import 'remaining_cases.dart';
import 'practice_cases.dart';

typedef RealCase = Future<void> Function(RealEnvironment);

final Map<String, RealCase> realCases = {
  ...gameScenarios,
  ...remainingCases,
  ...practiceCases,
  'ENV-001': (e) async {
    expect(apiEndpointValue, 'http://192.168.117.129:8081');
    expect(websocketEndpointValue, 'ws://192.168.117.129:8080/events');
    final client = HttpClient();
    try {
      final response = await (await client.getUrl(
        Uri.parse('http://${apiEndpoint.host}:8080/healthz'),
      )).close().timeout(const Duration(seconds: 10));
      expect(response.statusCode, HttpStatus.noContent);
      await response.drain<void>();
      final user = await e.user();
      expect(await e.api.listHalls(accessToken: user.token), isNotEmpty);
    } finally {
      client.close(force: true);
    }
  },
  'ENV-002': (e) async {
    final user = await e.user();
    final socket = await connectEventSocket(
      websocketEndpoint,
      user.token,
    ).timeout(const Duration(seconds: 10));
    try {
      final event = socket.messages
          .firstWhere((message) => message.contains('LOBBY_STATE_CHANGED'))
          .timeout(const Duration(seconds: 15));
      await e.create(user);
      expect(await event, contains('LOBBY_STATE_CHANGED'));
    } finally {
      await socket.close();
    }
  },
  'REG-001': (e) async {
    await e.registerForm();
    await e.waitFor(() => !e.auth!.isLoading, 'registration response');
    expect(e.auth!.session, isNotNull);
    await e.visible(find.text('游戏大厅'));
    final profile = await e.player.getProfile(
      pb.GetProfileRequest(userId: e.auth!.session!.userId),
      options: CallOptions(
        metadata: {'authorization': 'Bearer ${e.auth!.session!.accessToken}'},
      ),
    );
    expect(profile.nickname, '集成测试玩家');
    expect(profile.avatarUrl, isNotEmpty);
  },
  'REG-002': (e) async {
    await e.registerForm(confirmation: 'Different2026!');
    expect(find.text('两次输入的密码不一致'), findsOneWidget);
    expect(e.auth!.session, isNull);
  },
  'REG-003': (e) async {
    await e.registerForm(password: 'Ab12');
    expect(find.text('密码须为8到128字节且需包含字母和数字'), findsOneWidget);
    expect(e.auth!.session, isNull);
  },
  'REG-004': (e) async {
    await e.registerForm(password: '123456789');
    expect(find.text('密码须为8到128字节且需包含字母和数字'), findsOneWidget);
    await e.text('register-password-field', 'abcdefghijk');
    await e.text('register-confirm-password-field', 'abcdefghijk');
    await e.tap(find.widgetWithText(FilledButton, '注册'));
    expect(find.text('密码须为8到128字节且需包含字母和数字'), findsOneWidget);
    expect(e.auth!.session, isNull);
  },
  'REG-005': (e) async {
    await e.registerForm(account: '', password: '', nickname: '');
    for (final message in ['账号不能为空', '请确认密码', '昵称不能为空']) {
      expect(find.text(message), findsOneWidget);
    }
    await e.text('register-account-field', 'ab');
    await e.tap(find.widgetWithText(FilledButton, '注册'));
    expect(find.text('账号须为3到64字节且不能包含空格'), findsOneWidget);
    expect(e.auth!.session, isNull);
  },
  'REG-006': (e) async {
    final user = await e.user();
    await e.registerForm(account: user.account);
    await e.waitFor(() => !e.auth!.isLoading, 'duplicate registration');
    expect(e.auth!.session, isNull);
    expect(e.auth!.error, matches(RegExp('账号.*(存在|注册|重复)')));
    expect(e.auth!.error, isNot(contains('GrpcError')));
  },
  'REG-007': (e) async {
    await e.registerForm(nickname: List.filled(65, '名').join());
    expect(find.text('昵称不能超过64个字符'), findsOneWidget);
    expect(e.auth!.session, isNull);
  },
  'AUTH-001': (e) async {
    final user = await e.user();
    await login(e, user.account, testPassword);
    await e.visible(find.text('游戏大厅'));
    expect(e.auth!.session!.userId, user.id);
    await e.visible(find.textContaining('${user.session.nickname} · 0 分 · 青铜'));
  },
  'AUTH-002': (e) async {
    final user = await e.user();
    await login(e, user.account, 'Incorrect1234');
    expect(e.auth!.session, isNull);
    expect(e.auth!.error, matches(RegExp('(账号|密码).*(错误|不正确)')));
    expect(e.auth!.error, isNot(contains('GrpcError')));
  },
  'AUTH-003': (e) async {
    await login(
      e,
      'missing_${createRequestId().replaceAll('-', '')}',
      testPassword,
    );
    expect(e.auth!.session, isNull);
    expect(e.auth!.error, matches(RegExp('(账号|密码).*(错误|不存在|不正确)')));
    expect(e.auth!.error, isNot(contains('GrpcError')));
  },
  'AUTH-004': (e) async {
    final user = await e.user();
    for (var i = 0; i < 5; i++) {
      try {
        await e.api.login(account: user.account, password: 'Incorrect1234');
        fail('Incorrect password accepted.');
      } on GrpcError catch (error) {
        expect([
          StatusCode.unauthenticated,
          StatusCode.resourceExhausted,
        ], contains(error.code));
      }
    }
    await grpcError(
      () => e.api.login(account: user.account, password: testPassword),
      StatusCode.resourceExhausted,
    );
  },
  'AUTH-005': (e) async {
    final user = await e.user();
    await e.mount(signedIn: user);
    expect(e.auth!.session!.userId, user.id);
    expect(e.auth!.session!.refreshToken, isNot(user.session.refreshToken));
    expect(find.byKey(const ValueKey('login-account-field')), findsNothing);
  },
  'AUTH-006': (e) async {
    final user = await e.user();
    await e.mount(signedIn: user);
    final token = e.auth!.session!.accessToken;
    await e.tap(find.byTooltip('退出登录'));
    await e.visible(find.byKey(const ValueKey('login-account-field')));
    await grpcError(
      () => e.api.listHalls(accessToken: token),
      StatusCode.unauthenticated,
    );
  },
  'AUTH-007': (e) async {
    await grpcError(
      () => e.api.listHalls(accessToken: 'invalid'),
      StatusCode.unauthenticated,
    );
  },
  'LOBBY-001': (e) async {
    final user = await e.user();
    final halls = await e.api.listHalls(accessToken: user.token);
    final ordinary = halls.singleWhere((h) => h.id == 'ordinary');
    expect(
      [ordinary.minimumPoints, ordinary.maximumPoints, ordinary.multiplier],
      [0, 9999, 1.0],
    );
    final advanced = halls.singleWhere((h) => h.id == 'advanced');
    expect(
      [advanced.minimumPoints, advanced.maximumPoints, advanced.multiplier],
      [10000, 39999, 1.5],
    );
    final supreme = halls.singleWhere((h) => h.id == 'supreme');
    expect(
      [supreme.minimumPoints, supreme.maximumPoints, supreme.multiplier],
      [40000, 0, 2.0],
    );
    expect(halls.any((h) => h.id == 'friend'), isTrue);
    final stats = await e.api.getStatistics(accessToken: user.token);
    expect(
      [stats.points, stats.totalGames, stats.wins, stats.losses, stats.rank],
      [0, 0, 0, 0, '青铜'],
    );
    await e.mount(signedIn: user);
    for (final name in ['普通大厅', '高手大厅', '至尊大厅', '好友房']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('积分 0–9999'), findsOneWidget);
    expect(find.text('大厅系数 1.0×'), findsOneWidget);
  },
  'LOBBY-002': (e) async {
    final user = await e.user();
    for (final hall in ['advanced', 'supreme']) {
      await grpcError(
        () => e.api.listRooms(accessToken: user.token, hallId: hall),
        StatusCode.permissionDenied,
      );
    }
    await grpcError(
      () => e.api.listRooms(accessToken: user.token, hallId: 'friend'),
      StatusCode.failedPrecondition,
    );
  },
  'LOBBY-003': (e) async {
    final user = await e.user();
    final created = await e.create(user, password: 'Room1234');
    final list = await e.api.listRooms(
      accessToken: user.token,
      hallId: 'ordinary',
    );
    final value = list.singleWhere((r) => r.id == created.id);
    expect(value.name, created.name);
    expect(value.capacity, 4);
    expect(value.occupiedSeats, 0);
    expect(value.hasPassword, isTrue);
    expect(value.allowSpectators, isTrue);
    expect(value.minimumPoints, 0);
    await e.mount(signedIn: user);
    await e.visible(find.text(created.name));
    expect(find.text('房间号 ${created.id}'), findsOneWidget);
  },
  'LOBBY-004': (e) async {
    final user = await e.user();
    await e.mount(signedIn: user);
    final created = await e.create(user);
    await e.tap(find.byTooltip('刷新'));
    final search = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '搜索房间号或名称',
    );
    await e.tester.enterText(search, created.name);
    await e.visible(find.text(created.name));
    await e.tester.enterText(search, 'no_such_${createRequestId()}');
    await e.visible(find.text('没有匹配的房间'));
  },
  'ROOM-001': (e) async {
    final user = await e.user();
    await e.mount(signedIn: user);
    await e.tap(find.text('创建房间'));
    await e.text('create-room-name', '集成${createRequestId().substring(0, 8)}');
    await e.tap(find.widgetWithText(FilledButton, '创建'));
    await e.visible(find.byKey(const ValueKey('room-identity')));
  },
  'ROOM-002': (e) async {
    await e.mount(signedIn: await e.user());
    await e.tap(find.text('创建房间'));
    await e.text('create-room-name', '');
    expect(
      e.tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, '创建'))
          .onPressed,
      isNull,
    );
    await e.text('create-room-name', '合法名称');
    await e.text('create-room-minimum-points', '-1');
    expect(
      e.tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, '创建'))
          .onPressed,
      isNull,
    );
    await e.tap(find.text('取消'));
    expect(find.byKey(const ValueKey('create-room-dialog')), findsNothing);
  },
  'ROOM-003': (e) async {
    final owner = await e.user();
    final visitor = await e.user();
    final created = await e.create(owner, password: 'Room1234');
    expect(created.hasPassword, isTrue);
    await grpcError(
      () => e.api.joinByCode(
        accessToken: visitor.token,
        roomCode: created.id,
        password: 'Wrong1234',
      ),
      StatusCode.permissionDenied,
    );
    final joined = await e.api.joinByCode(
      accessToken: visitor.token,
      roomCode: created.id,
      password: 'Room1234',
    );
    expect(joined.id, created.id);
  },
  'ROOM-004': (e) async {
    final user = await e.user();
    final id = createRequestId();
    final first = await e.create(user, requestId: id, name: '幂等测试');
    final second = await e.create(user, requestId: id, name: '幂等测试');
    expect(second.id, first.id);
    final rooms = await e.api.listRooms(
      accessToken: user.token,
      hallId: 'ordinary',
    );
    expect(rooms.where((r) => r.id == first.id).length, 1);
  },
  'ROOM-005': (e) async {
    final user = await e.user();
    final created = await e.create(user);
    await e.join(user, created.id);
    final before = await e.details(user, created.id);
    final seated = await e.sit(user, created.id, 2);
    await grpcError(
      () => e.room.changeSeat(
        pb.SeatRequest(
          roomId: created.id,
          seatNo: 3,
          requestId: createRequestId(),
          expectedVersion: before.version,
        ),
        options: e.options(user),
      ),
      StatusCode.aborted,
    );
    expect((await e.details(user, created.id)).version, seated.version);
  },
  'ROOM-006': (e) async {
    final a = await e.user();
    final b = await e.user();
    final created = await e.create(a);
    await e.join(a, created.id);
    await e.sit(a, created.id, 1);
    await e.join(b, created.id);
    await grpcError(() => e.sit(b, created.id, 1), StatusCode.alreadyExists);
    var current = await e.details(a, created.id);
    current = await e.room.changeSeat(
      pb.SeatRequest(
        roomId: created.id,
        seatNo: 3,
        requestId: createRequestId(),
        expectedVersion: current.version,
      ),
      options: e.options(a),
    );
    expect(current.members.singleWhere((m) => m.userId == a.id).seatNo, 3);
    current = await e.room.standUp(
      pb.RoomRequest(
        roomId: created.id,
        requestId: createRequestId(),
        expectedVersion: current.version,
      ),
      options: e.options(a),
    );
    expect(current.members.singleWhere((m) => m.userId == a.id).seatNo, 0);
  },
  'ROOM-007': (e) async {
    final owner = await e.user();
    final created = await e.create(owner);
    await e.join(owner, created.id);
    final current = await e.sit(owner, created.id, 1);
    await grpcError(
      () => e.room.startGame(
        pb.RoomRequest(
          roomId: created.id,
          requestId: createRequestId(),
          expectedVersion: current.version,
        ),
        options: e.options(owner),
      ),
      StatusCode.failedPrecondition,
    );
  },
  'ROOM-008': (e) async {
    final (players, created, _) = await e.start();
    final current = await e.details(players[1], created.id);
    await grpcError(
      () => e.room.startGame(
        pb.RoomRequest(
          roomId: created.id,
          requestId: createRequestId(),
          expectedVersion: current.version,
        ),
        options: e.options(players[1]),
      ),
      StatusCode.permissionDenied,
    );
  },
  'ROOM-009': (e) async {
    final (players, created, state) = await e.start();
    final spectator = await e.user();
    await e.join(spectator, created.id);
    for (var seat = 1; seat <= 4; seat++) {
      var details = await e.details(spectator, created.id);
      await e.room.setSpectatorView(
        pb.SpectatorViewRequest(
          roomId: created.id,
          viewSeat: seat,
          requestId: createRequestId(),
          expectedVersion: details.version,
        ),
        options: e.options(spectator),
      );
      var view = await e.snapshot(spectator, state.gameSessionId);
      expect(view.viewSeat, seat);
      expect(view.visibleHand, isEmpty);
      expect(view.bottomCards, isEmpty);
      details = await e.details(players[seat - 1], created.id);
      await e.room.setHandVisibility(
        pb.SpectatorViewRequest(
          roomId: created.id,
          showHand: true,
          requestId: createRequestId(),
          expectedVersion: details.version,
        ),
        options: e.options(players[seat - 1]),
      );
      view = await e.snapshot(spectator, state.gameSessionId);
      expect(view.visibleHand.length, 25);
      expect(view.bottomCards, isEmpty);
      details = await e.details(players[seat - 1], created.id);
      await e.room.setHandVisibility(
        pb.SpectatorViewRequest(
          roomId: created.id,
          showHand: false,
          requestId: createRequestId(),
          expectedVersion: details.version,
        ),
        options: e.options(players[seat - 1]),
      );
      expect(
        (await e.snapshot(spectator, state.gameSessionId)).visibleHand,
        isEmpty,
      );
    }
  },
  'ROOM-010': (e) async {
    final (players, created, _) = await e.start();
    final owner = players.first;
    final current = await e.details(owner, created.id);
    await grpcError(
      () => e.room.changeSeat(
        pb.SeatRequest(
          roomId: created.id,
          seatNo: 2,
          requestId: createRequestId(),
          expectedVersion: current.version,
        ),
        options: e.options(owner),
      ),
      StatusCode.failedPrecondition,
    );
    await grpcError(
      () => e.room.standUp(
        pb.RoomRequest(
          roomId: created.id,
          requestId: createRequestId(),
          expectedVersion: current.version,
        ),
        options: e.options(owner),
      ),
      StatusCode.failedPrecondition,
    );
  },
  'GAME-001': (e) async {
    final (players, created, initial) = await e.start();
    final all = <String>{};
    for (final user in players) {
      final state = await e.snapshot(user, initial.gameSessionId);
      expect(state.visibleHand.length, 25);
      expect(state.bottomCards, isEmpty);
      all.addAll(state.visibleHand);
    }
    expect(all.length, 100);
    await e.showTable(players.first, created);
    final phases = <String>{};
    var state = initial;
    for (var step = 0; step < 300; step++) {
      phases.add(state.phase);
      if (state.phase == 'hand_over' || state.phase == 'finished') break;
      final actor = players.singleWhere((p) => p.id == state.currentTurnUserId);
      state = await e.snapshot(actor, state.gameSessionId);
      final action = pb.GameAction();
      switch (state.phase) {
        case 'declaration':
        case 'counter':
          action.pass = pb.PassAction();
        case 'bury':
          expect(state.visibleHand.length, 33);
          expect(state.visibleHand.toSet().difference(all).length, 8);
          action.buryCards = pb.BuryCardsAction(
            cards: state.visibleHand.take(8),
          );
        case 'playing':
          expect(state.suggestedPlay, isNotEmpty);
          action.playCards = pb.PlayCardsAction(cards: state.suggestedPlay);
        default:
          throw StateError('Unexpected phase ${state.phase}');
      }
      final response = await e.submit(actor, state, action);
      expect(response.accepted, isTrue);
      e.step(
        'step=$step phase=${state.phase} version=${response.stateVersion}',
      );
      state = await e.snapshot(players.first, state.gameSessionId);
    }
    expect(state.phase, anyOf('hand_over', 'finished'));
    expect(phases, containsAll(['declaration', 'bury', 'counter', 'playing']));
    expect(state.visibleHand, isEmpty);
    expect(state.capturedPoints, greaterThanOrEqualTo(Int64.ZERO));
  },
  'GAME-002': (e) async {
    final (players, _, initial) = await e.start();
    final actor = players.singleWhere((p) => p.id == initial.currentTurnUserId);
    final id = createRequestId();
    final action = pb.GameAction(pass: pb.PassAction());
    final first = await e.submit(actor, initial, action, requestId: id);
    final duplicate = await e.submit(actor, initial, action, requestId: id);
    expect(duplicate.stateVersion, first.stateVersion);
    expect(
      (await e.snapshot(actor, initial.gameSessionId)).stateVersion,
      first.stateVersion,
    );
    await grpcError(
      () => e.submit(
        actor,
        initial,
        pb.GameAction(playCards: pb.PlayCardsAction(cards: ['clubs:2:0'])),
        requestId: id,
      ),
      StatusCode.alreadyExists,
    );
  },
  'GAME-003': (e) async {
    final (players, _, initial) = await e.start();
    final actor = players.singleWhere((p) => p.id == initial.currentTurnUserId);
    await e.submit(actor, initial, pb.GameAction(pass: pb.PassAction()));
    await grpcError(
      () => e.submit(actor, initial, pb.GameAction(pass: pb.PassAction())),
      StatusCode.aborted,
    );
    expect(
      (await e.snapshot(actor, initial.gameSessionId)).stateVersion,
      initial.stateVersion + 1,
    );
  },
  'GAME-004': (e) async {
    final (players, _, initial) = await e.start();
    final actor = players.singleWhere((p) => p.id == initial.currentTurnUserId);
    await grpcError(
      () => e.submit(
        actor,
        initial,
        pb.GameAction(
          declareTrump: pb.DeclareTrumpAction(cards: ['clubs:99:0']),
        ),
      ),
      StatusCode.invalidArgument,
    );
    expect(
      (await e.snapshot(actor, initial.gameSessionId)).stateVersion,
      initial.stateVersion,
    );
  },
  'GAME-005': (e) async {
    final (players, _, initial) = await e.start();
    final actor = players.singleWhere((p) => p.id == initial.currentTurnUserId);
    await e.submit(actor, initial, pb.GameAction(pass: pb.PassAction()));
    final reconnect = await e.game.requestReconnect(
      pb.RequestReconnectRequest(
        gameSessionId: initial.gameSessionId,
        lastSeenSeq: initial.seq,
      ),
      options: e.options(actor),
    );
    expect(reconnect.snapshot.stateVersion, initial.stateVersion + 1);
    expect(
      reconnect.events,
      isNotEmpty,
      reason:
          'Reconnect must replay missed events, not just return a snapshot.',
    );
    expect(reconnect.events.every((event) => event.seq > initial.seq), isTrue);
  },
  'FRIEND-001': (e) async {
    final a = await e.user();
    final b = await e.user();
    await e.mount(signedIn: a);
    await e.tap(find.byTooltip('好友'));
    final search = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == '搜索玩家',
    );
    await e.visible(search);
    await e.captureUi('好友列表');
    await e.tester.enterText(search, b.id);
    await e.tap(find.byTooltip('搜索'));
    await e.visible(find.text(b.session.nickname));
    await e.captureUi('好友搜索结果');
    await e.tap(find.byTooltip('发送好友申请'));
    await e.visible(find.text('好友申请已发送。'));
    await e.api.respondFriendRequest(
      accessToken: b.token,
      userId: a.id,
      accept: true,
      requestId: createRequestId(),
    );
    await e.tap(find.text(b.session.nickname));
    await e.visible(find.text('好友资料 / 战绩'));
    await e.visible(find.text('段位：青铜'));
    expect(find.text('积分 0'), findsOneWidget);
    expect(find.text('总场次 0'), findsOneWidget);
    await e.visible(find.text('暂无战绩'));
    await e.captureUi('好友资料与战绩');
  },
  'FRIEND-002': (e) async {
    final a = await e.user();
    final b = await e.user();
    await e.api.sendFriendRequest(
      accessToken: a.token,
      userId: b.id,
      requestId: createRequestId(),
    );
    await e.api.respondFriendRequest(
      accessToken: b.token,
      userId: a.id,
      accept: false,
      requestId: createRequestId(),
    );
    expect(await e.api.listFriends(accessToken: a.token), isEmpty);
    await e.makeFriends(a, b);
    expect((await e.api.listFriends(accessToken: a.token)).single.userId, b.id);
    await e.api.removeFriend(
      accessToken: a.token,
      userId: b.id,
      requestId: createRequestId(),
    );
    expect(await e.api.listFriends(accessToken: a.token), isEmpty);
    expect(await e.api.listFriends(accessToken: b.token), isEmpty);
  },
  'FRIEND-003': (e) async {
    final a = await e.user();
    final b = await e.user();
    final outsider = await e.user();
    await e.makeFriends(a, b);
    final created = await e.create(a, hall: 'friend');
    await e.join(a, created.id);
    await grpcError(
      () => e.join(outsider, created.id),
      StatusCode.permissionDenied,
    );
    await e.api.sendRoomInvite(
      accessToken: a.token,
      roomId: created.id,
      friendId: b.id,
      requestId: createRequestId(),
    );
    final invites = await e.api.listRoomInvitations(accessToken: b.token);
    expect(invites.any((i) => i.roomId == created.id), isTrue);
    final joined = await e.api.joinInvitedRoom(
      accessToken: b.token,
      roomId: created.id,
      requestId: createRequestId(),
    );
    expect(joined.id, created.id);
  },
  'FRIEND-004': (e) async {
    final a = await e.user();
    final b = await e.user();
    await grpcError(
      () => e.api.getFriendStatistics(accessToken: a.token, userId: b.id),
      StatusCode.permissionDenied,
    );
    await grpcError(
      () => e.api.listFriendRecentResults(accessToken: a.token, userId: b.id),
      StatusCode.permissionDenied,
    );
  },
  'FRIEND-005': (e) async {
    final a = await e.user();
    final b = await e.user();
    final id = createRequestId();
    for (var i = 0; i < 2; i++) {
      await e.api.sendFriendRequest(
        accessToken: a.token,
        userId: b.id,
        requestId: id,
      );
    }
    final requests = await e.api.listFriendRequests(accessToken: b.token);
    expect(requests.where((request) => request.userId == a.id).length, 1);
  },
};

Future<void> login(RealEnvironment e, String account, String password) async {
  await e.mount();
  await e.text('login-account-field', account);
  await e.text('login-password-field', password);
  await e.tap(find.widgetWithText(FilledButton, '登录'));
  await e.waitFor(() => !e.auth!.isLoading, 'login response');
}
