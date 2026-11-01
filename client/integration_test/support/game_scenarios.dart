import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pbgrpc.dart'
    as pb;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';

import 'real_environment.dart';

typedef ScenarioCase = Future<void> Function(RealEnvironment);

final Map<String, ScenarioCase> gameScenarios = {
  'GAME-006': (e) async {
    final (players, created, initial) = await e.start(scenario: 'declaration');
    await e.showTable(players.first, created);
    final state = await e.snapshot(players.first, initial.gameSessionId);
    expect(state.visibleHand, contains('clubs:2:0'));
    await e.submit(
      players.first,
      state,
      pb.GameAction(
        declareTrump: pb.DeclareTrumpAction(
          cards: ['clubs:2:0'],
          suit: 'clubs',
        ),
      ),
    );
    final owner = await e.snapshot(players.first, initial.gameSessionId);
    expect(owner.phase, 'bury');
    expect(owner.trumpSuit, 'clubs');
    expect(owner.visibleHand.length, 33);
    final other = await e.snapshot(players[1], initial.gameSessionId);
    expect(other.bottomCards, isEmpty);
    expect(other.publicCards, isEmpty);
    expect(other.visibleHand.length, 25);
  },
  'GAME-007': (e) async {
    final (players, _, initial) = await e.start(scenario: 'declaration');
    // Let seat 2 declare using one of its level cards, leaving seat 1's pair intact.
    final declarer = players[1];
    var state = await e.snapshot(declarer, initial.gameSessionId);
    final levelCard = state.visibleHand.firstWhere(
      (card) => card.split(':')[1] == '2',
    );
    await e.submit(
      declarer,
      state,
      pb.GameAction(
        declareTrump: pb.DeclareTrumpAction(
          cards: [levelCard],
          suit: levelCard.split(':').first,
        ),
      ),
    );
    await bury(
      e,
      players.first,
      initial.gameSessionId,
      protect: {'clubs:2:0', 'clubs:2:1'},
    );
    // Counter begins at seat 2 but skips the original declarer.
    state = await e.snapshot(players[2], initial.gameSessionId);
    expect(state.currentTurnUserId, players[2].id);
    for (final player in [players[2], players[3]]) {
      state = await e.snapshot(player, initial.gameSessionId);
      await e.submit(player, state, pb.GameAction(pass: pb.PassAction()));
    }
    state = await e.snapshot(players.first, initial.gameSessionId);
    await e.submit(
      players.first,
      state,
      pb.GameAction(
        counterTrump: pb.DeclareTrumpAction(cards: ['clubs:2:0', 'clubs:2:1']),
      ),
    );
    state = await e.snapshot(players.first, initial.gameSessionId);
    expect(state.phase, 'bury');
    expect(state.visibleHand.length, 33);
    await bury(e, players.first, initial.gameSessionId);
    expect(
      (await e.snapshot(
        players.first,
        initial.gameSessionId,
      )).currentTurnUserId,
      players[1].id,
    );
  },
  'GAME-008': (e) async {
    final (players, _, initial) = await e.start(scenario: 'declaration');
    await declareAndBury(e, players, initial.gameSessionId);
    for (var seat = 1; seat <= 2; seat++) {
      final rank = seat == 1 ? 15 : 16;
      var state = await e.snapshot(players[seat], initial.gameSessionId);
      expect(state.currentTurnUserId, players[seat].id);
      await e.submit(
        players[seat],
        state,
        pb.GameAction(
          counterTrump: pb.DeclareTrumpAction(
            cards: ['joker:$rank:0', 'joker:$rank:1'],
          ),
        ),
      );
      state = await e.snapshot(players[seat], initial.gameSessionId);
      expect(state.phase, 'bury');
      expect(state.visibleHand.length, 33);
      expect(state.trumpSuit, 'no suit');
      await bury(e, players[seat], initial.gameSessionId);
    }
  },
  'GAME-009': (e) async {
    for (final companion in ['spades:9:0', 'diamonds:2:0', 'joker:15:0']) {
      final (players, _, initial) = await e.start(scenario: 'red');
      await declareAndBury(e, players, initial.gameSessionId);
      for (final player in [players[1], players[2]]) {
        final state = await e.snapshot(player, initial.gameSessionId);
        await e.submit(player, state, pb.GameAction(pass: pb.PassAction()));
      }
      var state = await e.snapshot(players[3], initial.gameSessionId);
      // Fixture allocator guarantees this seat's two red fives; companion choice
      // is checked against the actual private hand rather than fabricating ownership.
      final chosen = state.visibleHand.contains(companion)
          ? companion
          : state.visibleHand.firstWhere(
              (card) => card != 'hearts:5:0' && card != 'hearts:5:1',
            );
      expect(
        chosen,
        companion,
        reason: 'Scenario must supply the required companion.',
      );
      await e.submit(
        players[3],
        state,
        pb.GameAction(
          counterTrump: pb.DeclareTrumpAction(cards: ['hearts:5:0', companion]),
        ),
      );
      state = await e.snapshot(players[3], initial.gameSessionId);
      expect(state.phase, 'bury');
      expect(
        state.trumpSuit,
        companion.startsWith('spades') ? 'spades' : 'no suit',
      );
    }
  },
  'GAME-010': (e) async {
    final (players, _, initial) = await e.start(scenario: 'declaration');
    await declareAndBury(e, players, initial.gameSessionId);
    var state = await e.snapshot(players[1], initial.gameSessionId);
    await e.submit(
      players[1],
      state,
      pb.GameAction(
        counterTrump: pb.DeclareTrumpAction(
          cards: ['joker:15:0', 'joker:15:1'],
        ),
      ),
    );
    await bury(e, players[1], initial.gameSessionId);
    for (final player in [players[2], players[3]]) {
      state = await e.snapshot(player, initial.gameSessionId);
      await e.submit(player, state, pb.GameAction(pass: pb.PassAction()));
    }
    state = await e.snapshot(players.first, initial.gameSessionId);
    expect(state.availableActions, contains('REDECLARE'));
    await e.submit(
      players.first,
      state,
      pb.GameAction(redeclareTrump: pb.DeclareTrumpAction()),
    );
    state = await e.snapshot(players.first, initial.gameSessionId);
    expect(state.phase, 'bury');
    expect(state.trumpSuit, 'clubs');
    await bury(e, players.first, initial.gameSessionId);
    expect(
      (await e.snapshot(players.first, initial.gameSessionId)).phase,
      'playing',
    );
  },
  'GAME-011': (e) async {
    final (players, _, initial) = await e.start(scenario: 'declaration');
    await declareAndBury(e, players, initial.gameSessionId);
    var state = await e.snapshot(players[1], initial.gameSessionId);
    await e.submit(
      players[1],
      state,
      pb.GameAction(
        counterTrump: pb.DeclareTrumpAction(
          cards: ['joker:15:0', 'joker:15:1'],
        ),
      ),
    );
    await bury(e, players[1], initial.gameSessionId);
    state = await e.snapshot(players[2], initial.gameSessionId);
    await e.submit(
      players[2],
      state,
      pb.GameAction(
        counterTrump: pb.DeclareTrumpAction(
          cards: ['joker:16:0', 'joker:16:1'],
        ),
      ),
    );
    await bury(e, players[2], initial.gameSessionId);
    for (final player in [players[3], players.first]) {
      state = await e.snapshot(player, initial.gameSessionId);
      await e.submit(player, state, pb.GameAction(pass: pb.PassAction()));
    }
    state = await e.snapshot(players[1], initial.gameSessionId);
    await e.submit(
      players[1],
      state,
      pb.GameAction(
        counterTrump: pb.DeclareTrumpAction(
          cards: ['joker:15:0', 'joker:15:1'],
        ),
      ),
    );
    state = await e.snapshot(players.first, initial.gameSessionId);
    expect(state.phase, 'hand_over');
    expect(state.capturedPoints.toInt(), 0);
    expect(state.teamOneLevel, 'J');
  },
  'GAME-012': (e) async {
    for (final rank in [2, 5, 15, 16]) {
      final (players, _, initial) = await e.start(scenario: 'fallback/$rank');
      for (final player in players) {
        final state = await e.snapshot(player, initial.gameSessionId);
        expect(state.currentTurnUserId, player.id);
        await e.submit(player, state, pb.GameAction(pass: pb.PassAction()));
      }
      final state = await e.snapshot(players.first, initial.gameSessionId);
      expect(state.phase, 'bury');
      expect(state.trumpSuit, 'no suit');
      expect(state.visibleHand.length, 33);
    }
  },
  'GAME-020': (e) async {
    await finalScenario(
      e,
      'comeback/11/70',
      expectedOne: '3',
      expectedTwo: '2',
      score: 70,
    );
    await finalScenario(
      e,
      'comeback/11/80/pair',
      expectedOne: '2',
      expectedTwo: 'J',
      score: 80,
    );
  },
  'GAME-013': (e) async {
    final (players, _, initial) = await e.start(scenario: 'redfive');
    await playFinal(e, players, initial.gameSessionId);
    final state = await e.snapshot(players.first, initial.gameSessionId);
    expect(state.capturedPoints.toInt(), 0);
    expect(state.teamOneLevel, 'J');
    expect(state.teamTwoLevel, '2');
    expect(
      state.publicCards,
      containsAll(['hearts:5:0', 'joker:16:0', 'joker:15:0']),
    );
    final (capturedPlayers, _, capturedInitial) = await e.start(
      scenario: 'redfive-captured',
    );
    await playFinal(e, capturedPlayers, capturedInitial.gameSessionId);
    final captured = await e.snapshot(
      capturedPlayers.first,
      capturedInitial.gameSessionId,
    );
    expect(
      captured.capturedPoints.toInt(),
      5,
      reason: 'Captured red five has no additional penalty.',
    );
  },
  'GAME-014': (e) async {
    for (final name in ['pair', 'tractor']) {
      final (players, _, initial) = await e.start(scenario: name);
      await playFinal(e, players, initial.gameSessionId);
      final state = await e.snapshot(players.first, initial.gameSessionId);
      expect(state.phase, 'hand_over');
      expect(state.capturedPoints.toInt(), name == 'pair' ? 20 : 40);
    }
    final (players, _, initial) = await e.start(scenario: 'level-gap');
    await grpcError(
      () => e.submit(
        players.first,
        initial,
        pb.GameAction(
          playCards: pb.PlayCardsAction(cards: initial.visibleHand),
        ),
      ),
      StatusCode.invalidArgument,
    );
  },
  'GAME-015': (e) async {
    final (players, _, initial) = await e.start(scenario: 'follow');
    await e.submit(
      players.first,
      initial,
      pb.GameAction(
        playCards: pb.PlayCardsAction(cards: ['spades:6:0', 'spades:6:1']),
      ),
    );
    var state = await e.snapshot(players[1], initial.gameSessionId);
    final version = state.stateVersion;
    await grpcError(
      () => e.submit(
        players[1],
        state,
        pb.GameAction(
          playCards: pb.PlayCardsAction(cards: ['hearts:3:0', 'hearts:3:1']),
        ),
      ),
      StatusCode.invalidArgument,
    );
    await grpcError(
      () => e.submit(
        players[1],
        state,
        pb.GameAction(
          playCards: pb.PlayCardsAction(cards: ['spades:8:0', 'hearts:3:0']),
        ),
      ),
      StatusCode.invalidArgument,
    );
    state = await e.snapshot(players[1], initial.gameSessionId);
    expect(state.stateVersion, version);
    expect(
      (await e.submit(
        players[1],
        state,
        pb.GameAction(
          playCards: pb.PlayCardsAction(cards: ['spades:8:0', 'spades:8:1']),
        ),
      )).accepted,
      isTrue,
    );
  },
  'GAME-016': (e) async {
    final (players, _, initial) = await e.start(scenario: 'throw');
    await grpcError(
      () => e.submit(
        players.first,
        initial,
        pb.GameAction(
          playCards: pb.PlayCardsAction(cards: ['spades:14:0', 'spades:12:0']),
        ),
      ),
      StatusCode.invalidArgument,
    );
    expect(
      (await e.snapshot(players.first, initial.gameSessionId)).stateVersion,
      initial.stateVersion,
    );
    expect(
      (await e.submit(
        players.first,
        initial,
        pb.GameAction(playCards: pb.PlayCardsAction(cards: ['spades:14:0'])),
      )).accepted,
      isTrue,
    );
  },
  'GAME-017': (e) async {
    final (players, _, initial) = await e.start(scenario: 'combo');
    for (var seat = 0; seat < 4; seat++) {
      final state = await e.snapshot(players[seat], initial.gameSessionId);
      final cards = seat < 2
          ? state.visibleHand
                .where((c) => c.startsWith(seat == 0 ? 'spades:' : 'clubs:'))
                .toList()
          : state.suggestedPlay;
      expect(cards.length, 3);
      await e.submit(
        players[seat],
        state,
        pb.GameAction(playCards: pb.PlayCardsAction(cards: cards)),
      );
    }
    final state = await e.snapshot(players.first, initial.gameSessionId);
    expect(state.currentTurnUserId, players[1].id);
    // Two 510k combinations contribute 25 points each; red five scores zero.
    expect(state.capturedPoints.toInt(), 50);
  },
  'GAME-018': (e) async {
    final (players, _, initial) = await e.start(scenario: 'draw');
    await e.submit(
      players.first,
      initial,
      pb.GameAction(
        playCards: pb.PlayCardsAction(
          cards: ['clubs:5:0', 'clubs:10:0', 'clubs:13:0'],
        ),
      ),
    );
    var state = await e.snapshot(players[1], initial.gameSessionId);
    await grpcError(
      () => e.submit(
        players[1],
        state,
        pb.GameAction(
          playCards: pb.PlayCardsAction(
            cards: ['joker:15:0', 'clubs:2:0', 'diamonds:3:0'],
          ),
        ),
      ),
      StatusCode.invalidArgument,
    );
    for (var seat = 1; seat < 4; seat++) {
      state = await e.snapshot(players[seat], initial.gameSessionId);
      final expected = switch (seat) {
        1 => ['joker:16:0', 'joker:15:0', 'clubs:2:0'],
        2 => ['hearts:5:0', 'clubs:14:0', 'clubs:12:0'],
        _ => state.suggestedPlay,
      };
      expect(state.suggestedPlay.toSet(), expected.toSet());
      await e.submit(
        players[seat],
        state,
        pb.GameAction(playCards: pb.PlayCardsAction(cards: expected)),
      );
    }
    state = await e.snapshot(players.first, initial.gameSessionId);
    expect(state.phase, 'playing');
    expect(state.currentTurnUserId, players.first.id);
  },
  'GAME-019': (e) async {
    for (final width in [1, 2, 4, 6]) {
      final (players, _, initial) = await e.start(scenario: 'bottom/$width');
      var trickPoints = 0;
      for (final player in players) {
        final hand = (await e.snapshot(
          player,
          initial.gameSessionId,
        )).visibleHand;
        for (final card in hand) {
          final rank = int.parse(card.split(':')[1]);
          trickPoints += rank == 5 ? 5 : (rank == 10 || rank == 13 ? 10 : 0);
        }
      }
      await playFinal(e, players, initial.gameSessionId);
      final state = await e.snapshot(players.first, initial.gameSessionId);
      final multiplier = switch (width) {
        1 => 2,
        2 => 4,
        4 => 8,
        _ => 16,
      };
      expect(state.capturedPoints.toInt(), trickPoints + 5 * multiplier);
      expect(state.bottomPublic, isTrue);
      expect(state.bottomCards.length, 8);
    }
  },
  'GAME-021': (e) async {
    await finalScenario(
      e,
      'comeback/14/75',
      expectedOne: 'A',
      expectedTwo: '2',
      score: 75,
      finished: true,
    );
    await finalScenario(
      e,
      'comeback/14/80',
      expectedOne: 'J',
      expectedTwo: 'A',
      score: 80,
    );
    await finalScenario(
      e,
      'comeback/14/100/pair',
      expectedOne: '2',
      expectedTwo: 'A',
      score: 100,
    );
  },
  'GAME-022': (e) async {
    await finalScenario(e, 'sky', expectedOne: 'A', expectedTwo: '2', score: 0);
  },
  'GAME-023': (e) async {
    // The scenario begins at the final trick of hand 2 with first-hand sky-earth
    // recorded. This verifies the actual transition, not an engine-only mock.
    await finalScenario(
      e,
      'spring',
      expectedOne: 'A',
      expectedTwo: '2',
      score: 0,
      finished: true,
    );
    // Ledger validation remains a separate required assertion: snapshot success
    // alone must not disguise the currently missing durable points settlement.
    final owner = e.users[e.users.length - 4];
    final statistics = await e.api.getStatistics(accessToken: owner.token);
    expect(
      statistics.points,
      480,
      reason: 'Spring must award 480 points in ordinary hall.',
    );
  },
  'GAME-024': (e) async {
    for (var score = 0; score <= 200; score += 5) {
      final advance = score < 75 ? (80 - score) ~/ 10 : 0;
      // Runtime cannot cross the unplayed mandatory J.
      final one = score < 75 ? (4 + advance).clamp(2, 11) : 4;
      await finalScenario(
        e,
        'score/4/$score',
        expectedOne: rankName(one),
        expectedTwo: '2',
        score: score,
      );
    }
  },
  'GAME-025': (e) async {
    for (final level in [2, 11, 14]) {
      for (final score in [0, 70, 75, 80, 85, 90, 200]) {
        var one = level;
        var two = 2;
        final finished = level == 14 && score <= 75;
        if (score >= 80) {
          two = level;
        } else if (level != 14 && score < 75) {
          one = (level + (80 - score) ~/ 10 + (level == 2 ? 1 : 0)).clamp(
            2,
            14,
          );
        } else if (level == 2 && score == 75) {
          one = 4;
        }
        await finalScenario(
          e,
          'score/$level/$score',
          expectedOne: rankName(one),
          expectedTwo: rankName(two),
          score: score,
          finished: finished,
        );
      }
    }
  },
  'GAME-026': (e) async {
    await finalScenario(
      e,
      'score/2/0',
      expectedOne: 'J',
      expectedTwo: '2',
      score: 0,
    );
    await finalScenario(
      e,
      'score/2/75',
      expectedOne: '4',
      expectedTwo: '2',
      score: 75,
    );
    await finalScenario(
      e,
      'score/2/80',
      expectedOne: '2',
      expectedTwo: '2',
      score: 80,
    );
    await finalScenario(
      e,
      'score/3/70',
      expectedOne: '4',
      expectedTwo: '2',
      score: 70,
    );
  },
  'GAME-027': (e) async {
    for (final score in [70, 80]) {
      final (players, _, initial) = await e.start(scenario: 'score/4/$score');
      await playFinal(e, players, initial.gameSessionId);
      for (final player in players) {
        final state = await e.snapshot(player, initial.gameSessionId);
        await e.submit(
          player,
          state,
          pb.GameAction(continueAction: pb.ContinueAction()),
        );
      }
      final next = await e.snapshot(players.first, initial.gameSessionId);
      expect(next.phase, 'declaration');
      expect(next.dealerSeat, score < 80 ? 3 : 2);
      expect(next.roundNo, 2);
    }
  },
  'GAME-028': (e) async {
    final (players, _, initial) = await e.start(scenario: 'score/14/70');
    final before = await e.api.getStatistics(accessToken: players.first.token);
    for (var seat = 0; seat < 4; seat++) {
      final state = await e.snapshot(players[seat], initial.gameSessionId);
      final action = pb.GameAction(
        playCards: pb.PlayCardsAction(cards: state.visibleHand),
      );
      final requestId =
          '00000000-0000-4000-8000-${(seat + 1).toString().padLeft(12, '0')}';
      await e.submit(players[seat], state, action, requestId: requestId);
      await e.submit(players[seat], state, action, requestId: requestId);
    }
    final after = await e.api.getStatistics(accessToken: players.first.token);
    expect(after.points - before.points, 180);
    expect(after.totalGames - before.totalGames, 1);
    final reconnect = await e.game.requestReconnect(
      pb.RequestReconnectRequest(gameSessionId: initial.gameSessionId),
      options: e.options(players.first),
    );
    expect(reconnect.snapshot.phase, 'finished');
    final again = await e.api.getStatistics(accessToken: players.first.token);
    expect(again.points, after.points);
  },
  'GAME-029': (e) async {
    final (players, created, initial) = await e.start(scenario: 'declaration');
    await e.showTable(players.first, created);
    await e.visible(find.byKey(const ValueKey('autoplay-toggle')));
    await e.tap(find.byKey(const ValueKey('autoplay-toggle')));
    await e.visible(find.byKey(const ValueKey('autoplay-status')));
    await e.tap(find.byKey(const ValueKey('autoplay-toggle')));
    expect(find.text('取消托管'), findsNothing);
    final before = await e.snapshot(players.first, initial.gameSessionId);
    await e.tester.pumpWidget(const SizedBox.shrink());
    await Future<void>.delayed(const Duration(seconds: 65));
    final after = await e.snapshot(players.first, initial.gameSessionId);
    expect(
      after.stateVersion,
      greaterThan(before.stateVersion),
      reason: 'Disconnected current player must trigger server timeout/autoplay, not depend on the open client.',
    );
  },
  'GAME-031': (e) async {
    final (players, created, initial) = await e.start(scenario: 'spring');
    await e.showTable(players.first, created);
    await playFinal(e, players, initial.gameSessionId);
    await e.visible(find.textContaining('结算'));
    expect(find.textContaining('春天'), findsWidgets);
    expect(find.textContaining('480'), findsWidgets);
    expect(find.textContaining('历史'), findsWidgets);
  },
  'GAME-030': (e) async {
    final (players, created, initial) = await e.start(scenario: 'declaration');
    await e.showTable(players.first, created);
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
          (p) => p.id == state.currentTurnUserId,
        );
        final own = await e.snapshot(actor, initial.gameSessionId);
        final action = pb.GameAction();
        switch (own.phase) {
          case 'declaration':
          case 'counter':
            action.pass = pb.PassAction();
          case 'bury':
            action.buryCards = pb.BuryCardsAction(
              cards: own.visibleHand.take(8),
            );
          case 'playing':
            expect(own.suggestedPlay, isNotEmpty);
            action.playCards = pb.PlayCardsAction(cards: own.suggestedPlay);
          default:
            throw StateError('Unexpected phase ${own.phase}');
        }
        await e.submit(actor, own, action);
      }
      state = await e.snapshot(players.first, initial.gameSessionId);
      e.step(
        'Full match step=$step hand=${state.roundNo} phase=${state.phase} levels=${state.teamOneLevel}:${state.teamTwoLevel}',
      );
    }
    expect(state.phase, 'finished');
    expect(state.state, 'FINISHED');
    final details = await e.details(players.first, created.id);
    expect(details.room.status, pb.RoomStatus.ROOM_STATUS_WAITING);
    final stats = await e.api.getStatistics(accessToken: players.first.token);
    expect(
      stats.totalGames,
      1,
      reason: 'A completed match must be recorded, not only change in-memory phase.',
    );
  },
};

String rankName(int rank) => switch (rank) {
  11 => 'J',
  12 => 'Q',
  13 => 'K',
  14 => 'A',
  _ => '$rank',
};

Future<void> declareAndBury(
  RealEnvironment e,
  List<TestUser> players,
  String id,
) async {
  final state = await e.snapshot(players.first, id);
  await e.submit(
    players.first,
    state,
    pb.GameAction(
      declareTrump: pb.DeclareTrumpAction(cards: ['clubs:2:0'], suit: 'clubs'),
    ),
  );
  await bury(e, players.first, id, protect: {'clubs:2:0', 'clubs:2:1'});
}

Future<void> bury(
  RealEnvironment e,
  TestUser player,
  String id, {
  Set<String> protect = const {},
}) async {
  final state = await e.snapshot(player, id);
  final cards = state.visibleHand
      .where((c) => !protect.contains(c) && !c.startsWith('joker:'))
      .take(8)
      .toList();
  expect(cards.length, 8);
  await e.submit(
    player,
    state,
    pb.GameAction(buryCards: pb.BuryCardsAction(cards: cards)),
  );
}

Future<void> playFinal(
  RealEnvironment e,
  List<TestUser> players,
  String id,
) async {
  for (var i = 0; i < 4; i++) {
    final state = await e.snapshot(players[i], id);
    expect(state.currentTurnUserId, players[i].id);
    await e.submit(
      players[i],
      state,
      pb.GameAction(playCards: pb.PlayCardsAction(cards: state.visibleHand)),
    );
  }
}

Future<void> finalScenario(
  RealEnvironment e,
  String name, {
  required String expectedOne,
  required String expectedTwo,
  required int score,
  bool finished = false,
}) async {
  e.step(
    'Deterministic scenario=$name expected=$expectedOne:$expectedTwo score=$score',
  );
  final (players, _, initial) = await e.start(scenario: name);
  await playFinal(e, players, initial.gameSessionId);
  final state = await e.snapshot(players.first, initial.gameSessionId);
  expect(state.phase, finished ? 'finished' : 'hand_over');
  expect(state.teamOneLevel, expectedOne);
  expect(state.teamTwoLevel, expectedTwo);
  expect(state.capturedPoints.toInt(), score);
}
