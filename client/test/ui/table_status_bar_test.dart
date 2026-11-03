import 'package:eighty_point_huai_an/src/ui/components/table_status_bar.dart';
import 'package:eighty_point_huai_an/src/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (points, scoring, color) in [
    (0, false, DarkTokens.textPrimary),
    (79, true, DarkTokens.textPrimary),
    (80, false, DarkTokens.redBright),
    (80, true, DarkTokens.scoreGreen),
    (160, true, DarkTokens.scoreGreen),
  ]) {
    testWidgets('score $points scoring perspective $scoring uses $color', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: TableStatusBar(
              ownLevel: 'A',
              opponentLevel: '8',
              points: points,
              scoringPerspective: scoring,
            ),
          ),
        ),
      );
      final score = tester.widget<Text>(
        find.byKey(const ValueKey('score-right')),
      );
      final span = score.textSpan! as TextSpan;
      expect((span.children!.last as TextSpan).style!.color, color);
      expect((span.children!.last as TextSpan).text, '$points');
      expect(find.text('我方 A  :  对方 8'), findsOneWidget);
      final levels = find.byKey(const ValueKey('levels-center'));
      final scoreFinder = find.byKey(const ValueKey('score-right'));
      double baseline(Finder finder) {
        final paragraph = tester.renderObject<RenderParagraph>(finder);
        return tester.getTopLeft(finder).dy +
            paragraph.getDryBaseline(
              paragraph.constraints,
              TextBaseline.alphabetic,
            )!;
      }

      expect(baseline(scoreFinder), closeTo(baseline(levels), 0.01));
    });
  }
}
