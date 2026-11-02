import 'package:eighty_point_huai_an/src/api/request_id.dart';
import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pbgrpc.dart'
    as pb;
import 'package:eighty_point_huai_an/src/ui/friend_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

import 'game_scenarios.dart';
import 'real_environment.dart';

final Map<String, Future<void> Function(RealEnvironment)> remainingCases = {
  'AUTH-008': (e) async {
    final user = await e.user();
    final another = await e.api.login(
      account: user.account,
      password: testPassword,
    );
    await e.mount(signedIn: user);
    final current = e.auth!.session!;
    await e.tap(find.text('修改密码'));
    await e.captureUi('修改密码弹窗');
    await e.text('password-current', 'Wrong1234');
    await e.text('password-new', 'Replacement2026!');
    await e.text('password-confirm', 'Mismatch2026!');
    await e.tap(find.text('确认修改'));
    await e.visible(find.text('两次输入的密码不一致'));
    await e.captureUi('修改密码-确认不一致');
    await e.text('password-confirm', 'Replacement2026!');
    await e.tap(find.text('确认修改'));
    await e.visible(find.text('当前密码不正确，请重新输入。'));
    await e.captureUi('修改密码-当前密码错误');
    await e.text('password-current', testPassword);
    await e.tap(find.text('确认修改'));
    await e.visible(find.byKey(const ValueKey('login-account-field')));
    for (final session in [current, another, user.session]) {
      await grpcError(
        () => e.api.listHalls(accessToken: session.accessToken),
        StatusCode.unauthenticated,
      );
      await grpcError(
        () => e.api.refresh(session.refreshToken),
        StatusCode.unauthenticated,
      );
    }
    await grpcError(
      () => e.api.login(account: user.account, password: testPassword),
      StatusCode.unauthenticated,
    );
    expect(
      (await e.api.login(
        account: user.account,
        password: 'Replacement2026!',
      )).userId,
      user.id,
    );
  },
  'AUTH-009': (e) async {
    final user = await e.user();
    await e.accountFixture(user, disabled: true);
    await grpcError(
      () => e.api.login(account: user.account, password: testPassword),
      StatusCode.unauthenticated,
    );
    await grpcError(
      () => e.api.listHalls(accessToken: user.token),
      StatusCode.unauthenticated,
    );
    await grpcError(
      () => e.api.refresh(user.session.refreshToken),
      StatusCode.unauthenticated,
    );
  },
  'LOBBY-005': (e) async {
    for (final entry in [
      (9999, 'ordinary', 1.0),
      (10000, 'advanced', 1.5),
      (39999, 'advanced', 1.5),
      (40000, 'supreme', 2.0),
    ]) {
      final user = await e.user();
      await e.accountFixture(user, points: entry.$1);
      expect(
        (await e.api.getStatistics(accessToken: user.token)).points,
        entry.$1,
      );
      final halls = await e.api.listHalls(accessToken: user.token);
      expect(
        halls.singleWhere((hall) => hall.id == entry.$2).multiplier,
        entry.$3,
      );
      for (final hall in ['ordinary', 'advanced', 'supreme']) {
        final minimum = halls
            .singleWhere((value) => value.id == hall)
            .minimumPoints;
        if (entry.$1 >= minimum) {
          await e.api.listRooms(accessToken: user.token, hallId: hall);
        } else {
          await grpcError(
            () => e.api.listRooms(accessToken: user.token, hallId: hall),
            StatusCode.permissionDenied,
          );
        }
      }
      await e.mount(signedIn: user);
      await e.tap(
        find.text(halls.singleWhere((hall) => hall.id == entry.$2).name),
      );
      await e.visible(find.text('大厅系数 ${entry.$3}×'));
      await e.captureUi('大厅-积分${entry.$1}');
    }
  },
  'LOBBY-006': (e) async {
    final user = await e.user();
    final created = <String>{};
    final prefix = '分页${createRequestId().substring(0, 8)}';
    for (var index = 0; index < 51; index++) {
      created.add((await e.create(user, name: '$prefix-$index')).id);
    }
    var token = '';
    final seenTokens = <String>{};
    final found = <String>{};
    var pages = 0;
    do {
      final page = await e.lobby.listRooms(
        pb.ListRoomsRequest(
          hallId: 'ordinary',
          page: pb.PageRequest(pageSize: 50, pageToken: token),
        ),
        options: e.options(user),
      );
      pages++;
      for (final value in page.rooms) {
        expect(
          found.add(value.roomId),
          isTrue,
          reason: 'Pages must not overlap',
        );
      }
      token = page.page.nextPageToken;
      if (token.isNotEmpty) expect(seenTokens.add(token), isTrue);
    } while (token.isNotEmpty && pages < 100);
    expect(token, isEmpty);
    expect(pages, greaterThan(1));
    expect(found, containsAll(created));
    final all = await e.api.listRooms(
      accessToken: user.token,
      hallId: 'ordinary',
    );
    expect(all.map((room) => room.id).toSet(), found);
    await e.mount(signedIn: user);
    final search = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '搜索房间号或名称',
    );
    await e.tester.enterText(search, '$prefix-50');
    await e.visible(find.text('$prefix-50'));
    await e.captureUi('大厅-跨页房间搜索');
  },
  'ROOM-011': (e) async {
    final (players, created, _) = await e.start(scenario: 'declaration');
    final spectator = await e.user();
    await e.join(spectator, created.id);
    final details = await e.details(players.first, created.id);
    await e.showTable(players.first, created);
    await e.tap(find.text('成员'));
    await e.visible(find.text('房间成员'));
    for (final member in details.members) {
      final user = [
        ...players,
        spectator,
      ].singleWhere((user) => user.id == member.userId);
      final field = find.byKey(ValueKey('room-member-${member.userId}'));
      expect(
        e.tester.widget<Text>(field).data,
        contains(user.session.nickname),
      );
      expect(e.tester.widget<Text>(field).data, contains('段位 青铜 · 积分 0'));
      expect(
        e.tester.widget<Text>(field).data,
        contains(member.seatNo == 0 ? '旁观' : '${member.seatNo}号位'),
      );
      if (member.seatNo != 0)
        expect(e.tester.widget<Text>(field).data, contains('级数 2'));
      if (member.userId == players.first.id)
        expect(e.tester.widget<Text>(field).data, contains('房主'));
    }
    await e.captureUi('房间成员与旁观者弹窗');
  },
  'ROOM-012': (e) async {
    final (players, created, initial) = await e.start(scenario: 'score/14/70');
    await playFinal(e, players, initial.gameSessionId);
    final finished = await e.snapshot(players.first, initial.gameSessionId);
    expect(finished.phase, 'finished');
    final before = await e.api.getStatistics(accessToken: players.first.token);
    final firstMatches = await e.database(
      "SELECT COUNT(*) FROM game_sessions WHERE room_id='${created.id}';",
    );
    await e.showTable(players.first, created);
    await e.visible(find.text('开始游戏'));
    await e.captureUi('牌桌-整盘结束等待再开局');
    await e.tap(find.text('开始游戏'));
    await e.waitFor(
      () => find.text('开始游戏').evaluate().isEmpty,
      'second match begins',
    );
    var second = await e.snapshot(players.first, created.id);
    expect(second.phase, 'declaration');
    expect(second.roundNo, 1);
    expect(second.stateVersion, lessThan(finished.stateVersion));
    expect(
      await e.database(
        "SELECT COUNT(*) FROM game_sessions WHERE room_id='${created.id}';",
      ),
      '${int.parse(firstMatches) + 1}',
    );
    // Finish the second match with legal server suggestions, never editing its result.
    second = await completeMatch(e, players, second);
    expect(second.phase, 'finished');
    expect(
      (await e.api.getStatistics(accessToken: players.first.token)).totalGames,
      before.totalGames + 1,
    );
    await e.visible(find.text('开始游戏'));
    await e.tap(find.byTooltip('离开房间'));
    await e.visible(find.text('游戏大厅'));
    expect(
      (await e.details(players[1], created.id)).room.status,
      pb.RoomStatus.ROOM_STATUS_CLOSED,
    );
    final rooms = await e.api.listRooms(
      accessToken: players[1].token,
      hallId: 'ordinary',
    );
    expect(rooms.any((room) => room.id == created.id), isFalse);
  },
  'FRIEND-006': (e) async {
    final a = await e.user();
    final b = await e.user();
    await e.makeFriends(a, b);
    await e.mountPair(a, b);
    await e.tap(e.inClient(0, find.byTooltip('好友')));
    await e.visible(e.inClient(0, find.text('${b.id} · 在线')));
    await e.captureUi('双客户端-好友在线');
    await e.tap(e.inClient(1, find.byTooltip('退出登录')));
    await e.visible(e.inClient(0, find.text('${b.id} · 离线')));
    await e.captureUi('双客户端-好友离线');
    await e.tester.enterText(
      e.inClient(1, find.byKey(const ValueKey('login-account-field'))),
      b.account,
    );
    await e.tester.enterText(
      e.inClient(1, find.byKey(const ValueKey('login-password-field'))),
      testPassword,
    );
    await e.tap(e.inClient(1, find.widgetWithText(FilledButton, '登录')));
    await e.visible(e.inClient(0, find.text('${b.id} · 在线')));
    Navigator.of(e.tester.element(e.inClient(0, find.byType(FriendListScreen))))
        .pop();
    await e.visible(e.inClient(0, find.text('游戏大厅')));
    for (final index in [0, 1]) {
      await e.tap(e.inClient(index, find.text('好友房')));
    }
    await e.tap(e.inClient(0, find.text('创建房间')));
    await e.tester.enterText(
      e.inClient(0, find.byKey(const ValueKey('create-room-name'))),
      '双客户端邀请${createRequestId().substring(0, 6)}',
    );
    await e.tap(e.inClient(0, find.widgetWithText(FilledButton, '创建')));
    await e.visible(e.inClient(0, find.text('邀请好友加入好友房')));
    await e.captureUi('好友房-邀请好友弹窗');
    await e.tap(e.inClient(0, find.byTooltip('发送邀请')));
    await e.visible(e.inClient(1, find.text('接受邀请')));
    final invited = await e.api.listRoomInvitations(accessToken: b.token);
    expect(invited, isNotEmpty);
    final invitedRoomId = invited.last.roomId;
    await e.captureUi('双客户端-收到好友房邀请');
    await e.tap(e.inClient(0, find.text('完成')));
    await e.tap(e.inClient(1, find.text('接受邀请')));
    await e.visible(e.inClient(0, find.byKey(const ValueKey('room-identity'))));
    await e.visible(e.inClient(1, find.byKey(const ValueKey('room-identity'))));
    final details = await e.details(a, invitedRoomId);
    expect(
      details.members.map((member) => member.userId),
      containsAll([a.id, b.id]),
    );
    await e.captureUi('双客户端-同房间独立登录');
  },
};

Future<pb.GameSnapshot> completeMatch(
  RealEnvironment e,
  List<TestUser> players,
  pb.GameSnapshot initial,
) async {
  var state = initial;
  for (var step = 0; step < 20000 && state.phase != 'finished'; step++) {
    if (state.phase == 'hand_over') {
      for (final player in players) {
        final own = await e.snapshot(player, initial.gameSessionId);
        await e.submit(
          player,
          own,
          pb.GameAction(continueAction: pb.ContinueAction()),
        );
      }
    } else {
      final actor = players.singleWhere(
        (player) => player.id == state.currentTurnUserId,
      );
      final own = await e.snapshot(actor, initial.gameSessionId);
      await e.submit(actor, own, suggestedAction(own));
    }
    state = await e.snapshot(players.first, initial.gameSessionId);
    if (step % 50 == 0)
      e.step(
        'Full match step=$step phase=${state.phase} hand=${state.roundNo}',
      );
  }
  expect(state.phase, 'finished');
  return state;
}

pb.GameAction suggestedAction(pb.GameSnapshot state) => switch (state.phase) {
  'declaration' || 'counter' => pb.GameAction(pass: pb.PassAction()),
  'bury' => pb.GameAction(
    buryCards: pb.BuryCardsAction(cards: state.visibleHand.take(8)),
  ),
  'playing' when state.suggestedPlay.isNotEmpty => pb.GameAction(
    playCards: pb.PlayCardsAction(cards: state.suggestedPlay),
  ),
  'hand_over' => pb.GameAction(continueAction: pb.ContinueAction()),
  _ => throw StateError('No valid suggested action in ${state.phase}'),
};
