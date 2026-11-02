import 'package:flutter/material.dart';

import '../../generated/huai/v1/api.pb.dart' as pb;
import '../theme/app_theme.dart';

class GameSettlementPanel extends StatelessWidget {
  const GameSettlementPanel({
    required this.game,
    required this.onHistory,
    super.key,
  });

  final pb.GameSnapshot game;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final result = game.settlement;
    final labels = [
      if (result.spring) '春天',
      if (result.skyEarth) '上天入地',
      if (result.comeback) '翻盘',
      if (result.naturalLevel) '自然级',
    ];
    return TweenAnimationBuilder<double>(
      key: ValueKey('${game.handId}:settlement'),
      duration: const Duration(milliseconds: 450),
      tween: Tween(begin: 0, end: 1),
      builder: (context, progress, child) => FractionalTranslation(
        translation: Offset(0, 1 - progress),
        child: Opacity(opacity: progress, child: child),
      ),
      child: Container(
        key: const ValueKey('settlement-panel'),
        width: double.infinity,
        margin: const EdgeInsets.all(DarkTokens.spacingS3),
        padding: const EdgeInsets.all(DarkTokens.spacingS4),
        decoration: BoxDecoration(
          color: DarkTokens.bgPanel,
          borderRadius: BorderRadius.circular(DarkTokens.radiusPanel),
          border: Border.all(color: DarkTokens.goldPrimary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: DarkTokens.spacingS4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(result.matchFinished ? '整盘结算' : '本局结算'),
                for (final label in labels) Text(label),
                Text('第 ${result.roundNo} 局 · ${result.winnerTeam} 队胜'),
                TextButton(onPressed: onHistory, child: const Text('对局历史')),
              ],
            ),
            Text('级数 ${result.teamOneLevel} : ${result.teamTwoLevel}'),
            if (result.matchFinished)
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0, end: result.nominalPoints.toDouble()),
                builder: (_, points, _) => Text('本盘标准积分 ${points.round()}'),
              ),
            Wrap(
              spacing: DarkTokens.spacingS4,
              children: [
                for (final change in result.pointChanges)
                  Text(
                    '${change.userId == game.dealerUserId ? '庄家' : '玩家 ${change.userId.substring(0, change.userId.length.clamp(0, 8))}'} '
                    '${change.delta >= 0 ? '+' : ''}${change.delta} · ${change.rank}',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
