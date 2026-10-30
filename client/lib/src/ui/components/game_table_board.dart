import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../generated/huai/v1/api.pb.dart' as pb;
import '../theme/app_theme.dart';
import 'design_icon.dart';

class GameTableBoard extends StatelessWidget {
  const GameTableBoard({
    required this.members,
    required this.perspective,
    required this.currentTurnUserId,
    required this.ownerId,
    required this.dealerUserId,
    required this.center,
    required this.onSeat,
    super.key,
  });

  final List<pb.RoomMember> members;
  final int perspective;
  final String currentTurnUserId;
  final String ownerId;
  final String dealerUserId;
  final Widget center;
  final ValueChanged<int>? onSeat;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;
      final seatWidth = math.min(
        width * (compact ? 0.26 : 0.16),
        DarkTokens.spacingS6 * 6.25,
      );
      final seatHeight = math.min(
        height * 0.22,
        DarkTokens.spacingS6 * (compact ? 2 : 2.75),
      );
      return Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: width * 0.11,
            right: width * 0.11,
            top: height * 0.18,
            bottom: height * 0.09,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  DarkTokens.redAccent.withValues(alpha: 0.5),
                  DarkTokens.bgBase,
                ),
                border: Border.all(color: DarkTokens.goldPrimary),
                borderRadius: BorderRadius.circular(DarkTokens.radiusBadge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DarkTokens.spacingS4),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: DarkTokens.goldDark.withValues(alpha: 0.35),
                    ),
                    borderRadius: BorderRadius.circular(DarkTokens.radiusBadge),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: width * (compact ? 0.28 : 0.25),
            right: width * (compact ? 0.28 : 0.25),
            top: height * 0.3,
            bottom: height * 0.12,
            child: center,
          ),
          for (var relative = 0; relative < 4; relative++)
            Positioned(
              left: switch (relative) {
                3 => DarkTokens.spacingS2,
                1 => width - seatWidth - DarkTokens.spacingS2,
                _ => (width - seatWidth) / 2,
              },
              top: switch (relative) {
                0 => height - seatHeight,
                2 => 0,
                _ => (height - seatHeight) / 2,
              },
              width: seatWidth,
              height: seatHeight,
              child: _seat(context, (perspective - 1 + relative) % 4 + 1),
            ),
        ],
      );
    },
  );

  Widget _seat(BuildContext context, int seat) {
    final member = members.where((member) => member.seatNo == seat).firstOrNull;
    final active =
        member != null &&
        member.userId == currentTurnUserId &&
        currentTurnUserId.isNotEmpty;
    final nickname = member == null
        ? '空位 $seat'
        : member.profile.nickname.isEmpty
        ? member.userId
        : member.profile.nickname;
    return Semantics(
      label: '座位 $seat，$nickname',
      child: InkWell(
        key: ValueKey('table-seat-$seat'),
        borderRadius: BorderRadius.circular(DarkTokens.radiusPanel),
        onTap: member == null && onSeat != null ? () => onSeat!(seat) : null,
        child: Container(
          padding: const EdgeInsets.all(DarkTokens.spacingS2),
          decoration: BoxDecoration(
            color: DarkTokens.bgPanel,
            border: Border.all(
              color: active ? DarkTokens.goldPrimary : DarkTokens.cardBack,
            ),
            borderRadius: BorderRadius.circular(DarkTokens.radiusPanel),
          ),
          child: Row(
            children: [
              if (MediaQuery.sizeOf(context).width > 600)
                Padding(
                  padding: const EdgeInsets.only(right: DarkTokens.spacingS2),
                  child: DesignIcon(
                    name: member?.userId == ownerId
                        ? DesignIconName.host
                        : DesignIconName.seat,
                    enabled: member != null,
                    size: DarkTokens.spacingS6,
                  ),
                ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: DarkTokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            member?.rank.isNotEmpty == true
                                ? member!.rank
                                : '$seat 号位${active ? ' · 出牌中' : ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (member?.userId == dealerUserId &&
                            seat != perspective)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: DarkTokens.spacingS1,
                            ),
                            child: Image.asset(
                              '../ui-design/asserts/ic_lighter/lighter.png',
                              key: ValueKey('dealer-marker-$seat'),
                              width: DarkTokens.spacingS5,
                              height: DarkTokens.spacingS5,
                              semanticLabel: '本轮庄家',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
