import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../generated/huai/v1/api.pb.dart' as pb;
import '../theme/app_theme.dart';
import 'design_icon.dart';
import 'turn_countdown.dart';
import 'card_visual.dart';
import 'table_cards.dart';

class GameTableBoard extends StatelessWidget {
  const GameTableBoard({
    required this.members,
    required this.perspective,
    required this.currentTurnUserId,
    required this.ownerId,
    required this.dealerUserId,
    required this.center,
    required this.onSeat,
    this.actionDeadline,
    this.serverTime,
    this.outsidePerspective = false,
    this.seatOnly = false,
    this.phase = '',
    this.readySeats = const [],
    this.bottomCards = const [],
    this.bottomPublic = false,
    this.bottomOverlay,
    this.onPerspective,
    super.key,
  });

  final List<pb.RoomMember> members;
  final int perspective;
  final String currentTurnUserId;
  final String ownerId;
  final String dealerUserId;
  final Widget center;
  final ValueChanged<int>? onSeat;
  final DateTime? actionDeadline;
  final DateTime? serverTime;
  final bool outsidePerspective;
  final bool seatOnly;
  final String phase;
  final List<int> readySeats;
  final List<String> bottomCards;
  final bool bottomPublic;
  final Widget? bottomOverlay;
  final ValueChanged<int>? onPerspective;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      if (seatOnly) return _seat(context, perspective, compact: compact);
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;
      final seatWidth = math.min(
        width * (compact ? 0.26 : 0.16),
        DarkTokens.spacingS6 * 6.25,
      );
      final seatHeight = math.min(
        height,
        math.max(
          DarkTokens.spacingS6 * 2,
          math.min(height * 0.22, DarkTokens.spacingS6 * (compact ? 2 : 2.75)),
        ),
      );
      return Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: DarkTokens.bgPanel,
                border: Border.all(color: DarkTokens.cardBack),
                borderRadius: BorderRadius.circular(DarkTokens.radiusPanel),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DarkTokens.spacingS4),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: DarkTokens.bgPanel),
                    borderRadius: BorderRadius.circular(DarkTokens.radiusBadge),
                  ),
                ),
              ),
            ),
          ),
          if (!compact && !{'hand_over', 'finished', 'void'}.contains(phase))
            Positioned(
              left: DarkTokens.spacingS4,
              top: DarkTokens.spacingS4,
              child: bottomCards.isNotEmpty
                  ? SizedBox(
                      width: DarkTokens.spacingS6 * 8,
                      child: BottomCardsPanel(
                        cards: bottomCards,
                        publiclyRevealed: bottomPublic,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.fromLTRB(
                        DarkTokens.spacingS2,
                        DarkTokens.spacingS2,
                        DarkTokens.spacingS2,
                        (DarkTokens.spacingS1 + DarkTokens.spacingS2) / 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: DarkTokens.cardBack),
                        borderRadius: BorderRadius.circular(
                          DarkTokens.radiusPanel,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('底牌'),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0; i < 8; i++)
                                SizedBox(
                                  width: DarkTokens.spacingS5,
                                  height: DarkTokens.spacingS6,
                                  child: i < bottomCards.length
                                      ? TableCard(card: bottomCards[i])
                                      : const CardBack(),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          Positioned(
            left: width * (compact ? 0.28 : 0.25),
            right: width * (compact ? 0.28 : 0.25),
            top: math.min(seatHeight + DarkTokens.spacingS3, height * 0.25),
            bottom: math.min(seatHeight + DarkTokens.spacingS3, height * 0.25),
            child: center,
          ),
          if (bottomOverlay != null)
            Positioned(
              left: width * (compact ? 0.1 : 0.25),
              right: width * (compact ? 0.1 : 0.25),
              bottom: (DarkTokens.spacingS2 + DarkTokens.spacingS3) / 2,
              child: bottomOverlay!,
            ),
          for (var relative = 0; relative < 4; relative++)
            if (relative != 0 || !outsidePerspective)
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
                child: _seat(
                  context,
                  (perspective - 1 + relative) % 4 + 1,
                  compact: compact,
                ),
              ),
        ],
      );
    },
  );

  Widget _seat(BuildContext context, int seat, {required bool compact}) {
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
        mouseCursor: member != null && onPerspective != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        onTap: member != null && onPerspective != null
            ? () => onPerspective!(seat)
            : member == null && onSeat != null
            ? () => onSeat!(seat)
            : null,
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
              if (!compact)
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
                            (phase == 'awaiting_ready' || phase == 'hand_over')
                                ? (readySeats.contains(seat) ? '已准备' : '等待准备')
                                : member?.rank.isNotEmpty == true
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
                              'assets/icons/ic_lighter/lighter.png',
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
              if (active && actionDeadline != null)
                TurnCountdown(
                  key: ValueKey('turn-countdown-$seat'),
                  deadline: actionDeadline!,
                  serverTime: serverTime,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
