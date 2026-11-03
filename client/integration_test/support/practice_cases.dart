import 'package:eighty_point_huai_an/src/api/request_id.dart';
import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pbgrpc.dart'
    as pb;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';

import 'real_environment.dart';
import 'remaining_cases.dart';

final Map<String, Future<void> Function(RealEnvironment)> practiceCases = {
  'PRACTICE-001': (e) async {
    final user = await e.user();
    await e.mount(signedIn: user);
    await e.tap(find.text('练习'));
    await e.visible(find.byKey(const ValueKey('room-identity')));
    await e.tap(find.text('准备'));
    await e.visible(find.byKey(const ValueKey('play-buttons')));
    final rooms = await e.database(
      "SELECT COUNT(*) FROM rooms WHERE owner_id='${user.id}';",
    );
    expect(rooms, '0', reason: 'Practice creation must not persist a room.');
    await e.captureUi('练习房-人机牌桌');
    for (final bot in ['Yao', 'Jia', 'Zhang']) {
      await e.visible(find.textContaining('的AI $bot'));
    }
    await e.tap(find.text('成员'));
    await e.visible(find.text('房间成员'));
    await e.captureUi('练习房-人类及三名机器人');
    await e.tap(find.text('关闭'));
    await e.tap(find.byTooltip('离开房间'));
    await e.visible(find.text('游戏大厅'));
  },
  'PRACTICE-002': (e) async {
    final user = await e.user();
    final id = createRequestId();
    final first = await e.api.createPracticeRoom(
      accessToken: user.token,
      requestId: id,
    );
    final repeated = await e.api.createPracticeRoom(
      accessToken: user.token,
      requestId: id,
    );
    expect(repeated.id, first.id);
    expect(first.practiceMode, isTrue);
    final details = await e.details(user, first.id);
    expect(details.members.length, 4);
    expect(details.members.map((member) => member.seatNo).toSet(), {
      1,
      2,
      3,
      4,
    });
    expect(
      details.members
          .where((member) => member.userId.startsWith('practice:${first.id}:'))
          .length,
      3,
    );
    final outsider = await e.user();
    await grpcError(
      () => e.details(outsider, first.id),
      StatusCode.permissionDenied,
    );
    await grpcError(
      () => e.snapshot(outsider, first.id),
      StatusCode.permissionDenied,
    );
    await grpcError(
      () => e.api.joinByCode(
        accessToken: outsider.token,
        roomCode: first.id,
        password: '',
      ),
      StatusCode.invalidArgument,
    );
    final public = await e.api.listRooms(
      accessToken: user.token,
      hallId: 'ordinary',
    );
    expect(public.any((room) => room.id == first.id), isFalse);
    await grpcError(
      () => e.lobby.createRoom(
        pb.CreateRoomRequest(
          hallId: 'practice',
          name: '练习房',
          requestId: createRequestId(),
          allowSpectators: true,
        ),
        options: e.options(user),
      ),
      StatusCode.invalidArgument,
    );
    await e.api.leaveRoom(
      accessToken: user.token,
      roomId: first.id,
      expectedVersion: details.version.toInt(),
      requestId: createRequestId(),
    );
    await grpcError(() => e.snapshot(user, first.id), StatusCode.notFound);
  },
  'PRACTICE-003': (e) async {
    final user = await e.user();
    final room = await e.api.createPracticeRoom(
      accessToken: user.token,
      requestId: createRequestId(),
    );
    var state = await _humanTurn(e, user, room.id);
    expect(state.visibleHand.length, state.phase == 'bury' ? 33 : 25);
    if (state.phase != 'bury') expect(state.bottomCards, isEmpty);
    final id = createRequestId();
    final action = suggestedAction(state);
    final first = await e.submit(user, state, action, requestId: id);
    final repeated = await e.submit(user, state, action, requestId: id);
    expect(repeated.stateVersion, first.stateVersion);
    await grpcError(
      () => e.submit(
        user,
        state,
        action,
        version: state.stateVersion,
        requestId: createRequestId(),
      ),
      StatusCode.aborted,
    );
    state = await _humanTurn(e, user, room.id);
    expect(state.currentTurnUserId, user.id);
    expect(state.stateVersion, greaterThan(Int64(1)));
    await grpcError(
      () => e.submit(
        user,
        state,
        pb.GameAction(playCards: pb.PlayCardsAction(cards: ['invalid-card'])),
      ),
      StatusCode.invalidArgument,
    );
    final reconnect = await e.game.requestReconnect(
      pb.RequestReconnectRequest(gameSessionId: room.id, lastSeenSeq: Int64(1)),
      options: e.options(user),
    );
    expect(reconnect.snapshot.visibleHand, state.visibleHand);
    expect(reconnect.events, isNotEmpty);
  },
  'PRACTICE-004': (e) async {
    final user = await e.user();
    final before = await e.api.getStatistics(accessToken: user.token);
    final room = await e.api.createPracticeRoom(
      accessToken: user.token,
      requestId: createRequestId(),
    );
    await e.showTable(user, room);
    var state = await _humanTurn(e, user, room.id);
    final captured = <String>{};
    var continued = false;
    for (var step = 0; step < 10000 && state.phase != 'finished'; step++) {
      if (state.phase != 'hand_over') {
        expect(
          state.currentTurnUserId,
          user.id,
          reason: 'Server bots must return control to the real human.',
        );
      }
      if (captured.add(state.phase)) await e.captureUi('练习房-${state.phase}');
      if (state.phase == 'hand_over') continued = true;
      final previous = state;
      await e.submit(user, state, suggestedAction(state));
      state = await _humanTurn(e, user, room.id);
      expect(state.stateVersion, greaterThan(previous.stateVersion));
      if (state.phase == 'playing') {
        expect(state.suggestedPlay, isNotEmpty);
        expect(state.suggestedPlay.every(state.visibleHand.contains), isTrue);
      }
      if (step % 25 == 0)
        e.step(
          'Practice human action=$step phase=${state.phase} round=${state.roundNo}',
        );
    }
    expect(state.phase, 'finished');
    expect(
      continued,
      isTrue,
      reason: 'Practice must cover human continuation into another hand.',
    );
    final after = await e.api.getStatistics(accessToken: user.token);
    expect(
      [after.points, after.totalGames, after.wins, after.losses],
      [before.points, before.totalGames, before.wins, before.losses],
    );
    expect(
      await e.database(
        "SELECT COUNT(*) FROM game_sessions WHERE room_id='${room.id}';",
      ),
      '0',
    );
    expect(
      await e.database(
        "SELECT COUNT(*) FROM point_ledger WHERE user_id='${user.id}';",
      ),
      '0',
    );
    await e.visible(find.text('准备'));
    await e.captureUi('练习房-整盘结束不计积分');
    await e.tap(find.byTooltip('离开房间'));
    await e.visible(find.text('游戏大厅'));
    await grpcError(() => e.snapshot(user, room.id), StatusCode.notFound);
  },
};

Future<pb.GameSnapshot> _humanTurn(
  RealEnvironment e,
  TestUser user,
  String roomId,
) async {
  final timeout = Stopwatch()..start();
  while (true) {
    final state = await e.snapshot(user, roomId);
    if (state.phase == 'awaiting_ready') {
      await e.submit(
        user,
        state,
        pb.GameAction(continueAction: pb.ContinueAction()),
      );
      continue;
    }
    if (state.phase == 'finished' ||
        (state.currentTurnUserId == user.id &&
            state.availableActions.any(
              {'DECLARE', 'BURY', 'COUNTER', 'PASS', 'PLAY'}.contains,
            )) ||
        state.availableActions.contains('CONTINUE'))
      return state;
    if (timeout.elapsed > const Duration(minutes: 2)) {
      throw StateError(
        'Server robots did not return control to the human in $roomId.',
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await e.tester.pump();
  }
}
