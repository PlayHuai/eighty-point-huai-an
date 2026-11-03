import 'package:eighty_point_huai_an/src/api/request_id.dart';
import 'package:eighty_point_huai_an/src/api/lobby_models.dart';
import 'package:eighty_point_huai_an/src/ui/components/game_table_board.dart';
import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pbgrpc.dart'
    as pb;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'real_environment.dart';
import 'game_scenarios.dart';

Future<(List<TestUser>, LobbyRoom)> _waiting(RealEnvironment e) async {
  final players = <TestUser>[for (var i = 0; i < 4; i++) await e.user()];
  final room = await e.create(players.first);
  for (var i = 0; i < 4; i++) {
    await e.join(players[i], room.id);
    await e.sit(players[i], room.id, i + 1);
  }
  final details = await e.details(players.first, room.id);
  await e.room.startGame(
    pb.RoomRequest(
      roomId: room.id,
      expectedVersion: details.version,
      requestId: createRequestId(),
    ),
    options: e.options(players.first),
  );
  return (players, room);
}

Future<void> _readyOthers(
  RealEnvironment e,
  List<TestUser> players,
  String id,
) async {
  for (final user in players.skip(1)) {
    final state = await e.rawSnapshot(user, id);
    await e.submit(
      user,
      state,
      pb.GameAction(continueAction: pb.ContinueAction()),
    );
  }
}

final Map<String, Future<void> Function(RealEnvironment)> v3Cases = {
  'TABLE-008': (e) async {
    final (players, room) = await _waiting(e);
    final before = await e.api.getStatistics(accessToken: players.first.token);
    final details = await e.details(players.first, room.id);
    await e.lobby.leaveRoom(
      pb.RoomRequest(
        roomId: room.id,
        expectedVersion: details.version,
        requestId: createRequestId(),
      ),
      options: e.options(players.first),
    );
    final remaining = await e.details(players[1], room.id);
    expect(remaining.room.status, pb.RoomStatus.ROOM_STATUS_WAITING);
    expect(remaining.room.occupiedSeats, 3);
    final state = await e.rawSnapshot(players[1], room.id);
    expect(state.phase, 'void');
    expect(state.availableActions, isEmpty);
    final after = await e.api.getStatistics(accessToken: players.first.token);
    expect(
      [after.points, after.totalGames],
      [before.points, before.totalGames],
    );
    await e.showTable(players[1], room);
    await e.captureUi('v3-准备期间退出整盘流局');
  },
  'TABLE-001': (e) async {
    final (players, room) = await _waiting(e);
    var state = await e.rawSnapshot(players.first, room.id);
    expect(state.phase, 'awaiting_ready');
    expect(state.visibleHand, isEmpty);
    expect(state.readySeats, [1]);
    await e.showTable(players.first, room);
    await e.captureUi('v3-牌桌等待准备');
    await _readyOthers(e, players, room.id);
    final start = Stopwatch()..start();
    TestUser? claimant;
    String? levelCard;
    while (claimant == null && start.elapsed < const Duration(seconds: 18)) {
      for (final user in players) {
        state = await e.rawSnapshot(user, room.id);
        final cards = state.visibleHand.where(
          (card) => card.split(':')[1] == '${state.trumpLevel}',
        );
        if (state.phase == 'dealing' && cards.isNotEmpty) {
          claimant = user;
          levelCard = cards.first;
          break;
        }
      }
      if (claimant == null)
        await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    expect(
      claimant,
      isNotNull,
      reason: 'A real dealt level card must allow a declaration.',
    );
    await e.showTable(claimant!, room);
    await e.visible(find.text('抢定'));
    final panel = find.byKey(const ValueKey('declaration-choices'));
    final board = find.byType(GameTableBoard).first;
    expect(
      e.tester.getRect(board).bottom - e.tester.getRect(panel).bottom,
      closeTo(10, 0.01),
    );
    final title = find.text('抢定 · 选择已有级牌的花色，点击抢定');
    final suits = find.descendant(of: panel, matching: find.byType(Wrap));
    expect(
      e.tester.getRect(suits).top - e.tester.getRect(title).bottom,
      closeTo(6, 0.01),
    );
    await e.captureUi('v3-GameTable-start-发牌抢定');
    state = await e.rawSnapshot(claimant, room.id);
    await e.submit(
      claimant,
      state,
      pb.GameAction(
        declareTrump: pb.DeclareTrumpAction(
          cards: [levelCard!],
          suit: levelCard.split(':').first,
        ),
      ),
    );
    final declared = await e.rawSnapshot(claimant, room.id);
    expect(declared.phase, 'dealing');
    final next = await e.snapshot(claimant, room.id);
    expect(next.phase, 'bury');
    expect(next.trumpSuit, levelCard.split(':').first);
    await e.captureUi('v3-发完牌进入扣底');
  },
  'TABLE-002': (e) async {
    final (players, room) = await _waiting(e);
    await _readyOthers(e, players, room.id);
    var state = await e.snapshot(players.first, room.id);
    expect(state.phase, 'declaration');
    expect(
      state.actionDeadline
          .toDateTime()
          .difference(state.serverTime.toDateTime())
          .inMilliseconds,
      inInclusiveRange(8500, 10000),
    );
    final timeout = Stopwatch()..start();
    while (state.phase == 'declaration' &&
        timeout.elapsed < const Duration(seconds: 12)) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      state = await e.rawSnapshot(players[1], room.id);
    }
    expect(state.phase, 'bury');
    expect(state.fallbackCard, isNotEmpty);
    expect(state.bottomCards, isEmpty);
    final parts = state.fallbackCard.split(':');
    final rank = int.parse(parts[1]);
    final noTrump =
        rank == state.trumpLevel ||
        rank >= 15 ||
        (parts[0] == 'hearts' && rank == 5);
    expect(state.trumpSuit, noTrump ? 'no suit' : parts.first);
    await e.showTable(players[1], room);
    await e.captureUi('v3-无人抢定翻开首张底牌');
  },
  'TABLE-003': (e) async {
    final user = await e.user();
    final initial = await e.player.getSettings(
      pb.Empty(),
      options: e.options(user),
    );
    expect(initial.showHandToSpectators, isFalse);
    final request = pb.UpdateSettingsRequest(
      showHandToSpectators: true,
      expectedVersion: initial.version,
      requestId: createRequestId(),
    );
    final saved = await e.player.updateSettings(
      request,
      options: e.options(user),
    );
    expect(
      (await e.player.updateSettings(
        request,
        options: e.options(user),
      )).version,
      saved.version,
    );
    await e.mount(signedIn: user);
    await e.tap(find.text('设置'));
    await e.visible(find.byKey(const ValueKey('global-show-hand')));
    await e.captureUi('v3-大厅全局设置-开牌');
    expect(
      e.tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey('global-show-hand')),
          )
          .value,
      isTrue,
    );
    await e.tap(find.text('关闭'));
    final room = await e.create(user);
    await e.join(user, room.id);
    await e.sit(user, room.id, 1);
    expect(
      (await e.details(
        user,
        room.id,
      )).members.singleWhere((member) => member.userId == user.id).showHand,
      isTrue,
    );
    await e.showTable(user, room);
    await e.tap(find.text('设置'));
    await e.visible(find.byKey(const ValueKey('global-show-hand')));
    await e.captureUi('v3-牌桌全局设置');
    await e.tap(find.byKey(const ValueKey('global-show-hand')));
    await e.waitFor(
      () =>
          e.tester
              .widget<SwitchListTile>(
                find.byKey(const ValueKey('global-show-hand')),
              )
              .value ==
          false,
      'server settings saved',
    );
    expect(
      (await e.player.getSettings(
        pb.Empty(),
        options: e.options(user),
      )).showHandToSpectators,
      isFalse,
    );
  },
  'TABLE-004': (e) async {
    final user = await e.user();
    await e.mount(signedIn: user);
    await e.tap(find.text('反馈'));
    await e.visible(find.text('问题'));
    expect(find.text('Bug'), findsNothing);
    final dialog = find.byType(AlertDialog);
    expect(e.tester.getSize(dialog).width, greaterThan(600));
    await e.captureUi('v3-问题反馈-扩大弹窗');
  },
  'TABLE-005': (e) async {
    final players = <TestUser>[for (var i = 0; i < 4; i++) await e.user()];
    final owner = players.first, viewer = await e.user();
    final room = await e.create(owner);
    for (final player in players) {
      await e.join(player, room.id);
    }
    await e.join(viewer, room.id);
    await e.showTable(viewer, room);
    await e.tap(find.byKey(const ValueKey('table-seat-2')));
    expect(
      (await e.details(
        viewer,
        room.id,
      )).members.singleWhere((member) => member.userId == viewer.id).viewSeat,
      2,
    );
    await e.captureUi('v3-旁观头像点击切换视角');
    for (final player in players) {
      final current = await e.details(player, room.id);
      await e.api.leaveRoom(
        accessToken: player.token,
        roomId: room.id,
        expectedVersion: current.version.toInt(),
        requestId: createRequestId(),
      );
    }
    await e.visible(find.text('房间已关闭'));
    expect(find.text('取消'), findsNothing);
    await e.captureUi('v3-最后玩家退出-旁观者确认');
    expect(
      (await e.api.listRooms(
        accessToken: viewer.token,
        hallId: 'ordinary',
      )).any((item) => item.id == room.id),
      isFalse,
    );
    await e.tap(find.text('确认'));
    await e.visible(find.text('游戏大厅'));
  },
  'TABLE-006': (e) async {
    final (players, room) = await _waiting(e);
    final before = await e.api.getStatistics(accessToken: players.first.token);
    final initial = await e.rawSnapshot(players.first, room.id);
    expect(
      initial.readyDeadline
          .toDateTime()
          .difference(initial.serverTime.toDateTime())
          .inSeconds,
      inInclusiveRange(295, 300),
    );
    await e.showTable(players.first, room);
    await e.visible(find.byKey(const ValueKey('waiting-decision')));
    await e.waitFor(
      () => find.text('准备等待已超过5分钟').evaluate().isNotEmpty,
      'real five-minute ready deadline',
      timeout: const Duration(minutes: 6),
    );
    await e.captureUi('v3-准备超时-继续等待投票');
    await e.tap(find.text('否'));
    var state = await e.rawSnapshot(players[1], room.id);
    expect(state.phase, 'awaiting_ready');
    expect(state.declinedWaitSeats, [1]);
    await e.submit(
      players[1],
      state,
      pb.GameAction(waitVote: pb.ConfirmAutoplayAction(accept: false)),
    );
    state = await e.rawSnapshot(players.first, room.id);
    expect(state.phase, 'void');
    expect(state.state, 'VOID');
    await e.visible(find.byKey(const ValueKey('void-result')));
    await e.captureUi('v3-两票否-流局不计分');
    final after = await e.api.getStatistics(accessToken: players.first.token);
    expect(
      [after.points, after.totalGames],
      [before.points, before.totalGames],
    );
    expect(
      await e.database(
        "SELECT status FROM game_sessions WHERE room_id='${room.id}' ORDER BY started_at DESC LIMIT 1;",
      ),
      'ABORTED',
    );
    expect(
      await e.database(
        "SELECT COUNT(*) FROM point_ledger WHERE user_id='${players.first.id}';",
      ),
      '0',
    );
  },
  'TABLE-007': (e) async {
    final (players, room, initial) = await e.start(scenario: 'score/14/70');
    await e.showTable(players.first, room);
    await e.captureUi('v3-GameTable-going-进行中');
    await playFinal(e, players, initial.gameSessionId);
    await e.visible(find.text('整盘结算'));
    await e.captureUi('v3-GameTable-final-结算');
  },
};
