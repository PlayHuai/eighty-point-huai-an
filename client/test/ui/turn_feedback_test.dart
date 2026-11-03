import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pb.dart' as pb;
import 'package:eighty_point_huai_an/src/ui/components/completed_trick.dart';
import 'package:eighty_point_huai_an/src/ui/components/game_table_board.dart';
import 'package:eighty_point_huai_an/src/ui/components/table_cards.dart';
import 'package:eighty_point_huai_an/src/ui/components/turn_countdown.dart';
import 'package:eighty_point_huai_an/src/ui/theme/app_theme.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.windows]) {
    testWidgets('robot avatar has server-clock countdown on $platform', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final server = DateTime.utc(2000);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: GameTableBoard(
              members: [
                pb.RoomMember(
                  userId: 'practice:test:bot',
                  seatNo: 2,
                  profile: pb.UserProfile(nickname: '机器人'),
                  rank: '练习AI',
                ),
              ],
              perspective: 1,
              currentTurnUserId: 'practice:test:bot',
              ownerId: 'human',
              dealerUserId: 'human',
              actionDeadline: server.add(const Duration(seconds: 3)),
              serverTime: server,
              center: const Text('公开出牌'),
              onSeat: null,
            ),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('turn-countdown-2')), findsOneWidget);
      expect(find.text('3s'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }, variant: TargetPlatformVariant({platform}));
  }

  testWidgets('expired countdown displays zero without inferring an action', (
    tester,
  ) async {
    final server = DateTime.utc(2000);
    await tester.pumpWidget(
      MaterialApp(
        home: TurnCountdown(
          serverTime: server,
          deadline: server.subtract(const Duration(seconds: 1)),
        ),
      ),
    );
    expect(find.text('0s'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final score in [0, 25]) {
    testWidgets(
      'completed trick highlights entire winner and only real score $score',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: CompletedTrick(
                trick: pb.TrickHistory(
                  roundNo: 1,
                  trickNo: 2,
                  winnerSeat: 3,
                  capturedPoints: Int64(score),
                  plays: [
                    pb.PublicPlay(
                      seatNo: 1,
                      cards: ['clubs:13:0', 'clubs:13:1'],
                    ),
                    pb.PublicPlay(
                      seatNo: 3,
                      cards: ['clubs:14:0', 'clubs:14:1'],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        expect(find.text('上一墩 · 3号位最大'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('completed-trick-winner')),
          findsOneWidget,
        );
        expect(
          tester
              .widgetList<TableCard>(find.byType(TableCard))
              .map((card) => card.card),
          ['clubs:14:0', 'clubs:14:1'],
        );
        expect(
          find.text('+$score 分'),
          score > 0 ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const ValueKey('trick-score-1-2')),
          score > 0 ? findsOneWidget : findsNothing,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
