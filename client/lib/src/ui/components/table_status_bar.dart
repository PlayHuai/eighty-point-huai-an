import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TableStatusBar extends StatelessWidget {
  const TableStatusBar({
    required this.ownLevel,
    required this.opponentLevel,
    required this.points,
    required this.scoringPerspective,
    super.key,
  });

  final String ownLevel;
  final String opponentLevel;
  final int points;
  final bool scoringPerspective;

  @override
  Widget build(BuildContext context) {
    final scoreColor = points < 80
        ? DarkTokens.textPrimary
        : scoringPerspective
        ? DarkTokens.scoreGreen
        : DarkTokens.redBright;
    return Container(
      color: DarkTokens.bgPanel,
      padding: const EdgeInsets.all(DarkTokens.spacingS4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final levels = Text(
            '我方 $ownLevel  :  对方 $opponentLevel',
            key: const ValueKey('levels-center'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: DarkTokens.textSecondary),
          );
          final score = Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '得分： '),
                TextSpan(
                  text: '$points',
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: DarkTokens.fontSizeL3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            key: const ValueKey('score-right'),
          );
          if (constraints.maxWidth < 600) {
            return Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: DarkTokens.spacingS4,
              runSpacing: DarkTokens.spacingS2,
              children: [levels, score],
            );
          }
          return Row(
            children: [
              const Spacer(),
              Expanded(flex: 2, child: levels),
              Expanded(
                child: Align(alignment: Alignment.centerRight, child: score),
              ),
            ],
          );
        },
      ),
    );
  }
}
