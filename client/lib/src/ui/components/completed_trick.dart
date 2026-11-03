import 'package:flutter/material.dart';

import '../../generated/huai/v1/api.pb.dart' as pb;
import '../theme/app_theme.dart';
import 'table_cards.dart';

class CompletedTrick extends StatelessWidget {
  const CompletedTrick({required this.trick, super.key});

  final pb.TrickHistory trick;

  @override
  Widget build(BuildContext context) {
    final winner = trick.plays
        .where((play) => play.seatNo == trick.winnerSeat)
        .firstOrNull;
    if (winner == null) return const SizedBox.shrink();
    return DecoratedBox(
      key: const ValueKey('completed-trick-winner'),
      decoration: BoxDecoration(
        border: Border.all(color: DarkTokens.goldBright),
        borderRadius: BorderRadius.circular(DarkTokens.radiusCard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DarkTokens.spacingS1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '上一墩 · ${trick.winnerSeat}号位最大',
              style: const TextStyle(color: DarkTokens.goldBright),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final card in winner.cards)
                    SizedBox(
                      height: DarkTokens.spacingS6,
                      width: DarkTokens.spacingS5,
                      child: TableCard(card: card),
                    ),
                  if (trick.capturedPoints > 0)
                    TweenAnimationBuilder<double>(
                      key: ValueKey(
                        'trick-score-${trick.roundNo}-${trick.trickNo}',
                      ),
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1200),
                      builder: (_, progress, child) => Transform.translate(
                        offset: Offset(0, -DarkTokens.spacingS3 * progress),
                        child: Opacity(
                          opacity: 1 - progress * 0.4,
                          child: child,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(DarkTokens.spacingS2),
                        child: Text(
                          '+${trick.capturedPoints} 分',
                          style: const TextStyle(
                            color: DarkTokens.goldBright,
                            fontSize: DarkTokens.fontSizeL4,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
