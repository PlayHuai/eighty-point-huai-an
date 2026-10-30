import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pb.dart' as pb;
import 'package:eighty_point_huai_an/src/ui/components/game_table_board.dart';
import 'package:eighty_point_huai_an/src/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [320.0, 1449.0]) {
    testWidgets('perspective rotates physical seats at width $width', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final seated = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: GameTableBoard(
              members: [
                pb.RoomMember(
                  userId: 'player-3',
                  seatNo: 3,
                  profile: pb.UserProfile(nickname: '当前视角'),
                ),
              ],
              perspective: 3,
              ownerId: 'player-3',
              dealerUserId: '',
              currentTurnUserId: 'player-3',
              center: const Text('公开出牌'),
              onSeat: seated.add,
            ),
          ),
        ),
      );
      final bottom = tester.getCenter(
        find.byKey(const ValueKey('table-seat-3')),
      );
      final top = tester.getCenter(
        find.byKey(const ValueKey('table-seat-1')),
      );
      expect(bottom.dy, greaterThan(top.dy));
      expect(bottom.dx, top.dx);
      await tester.tap(find.byKey(const ValueKey('table-seat-2')));
      expect(seated, [2]);
      await tester.tap(find.byKey(const ValueKey('table-seat-3')));
      expect(seated, [2]);
      expect(tester.takeException(), isNull);
    });
  }
}
