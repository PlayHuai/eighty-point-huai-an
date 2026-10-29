import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'design_icon.dart';

enum CardSuit {
  spades('♠'),
  hearts('♥'),
  clubs('♣'),
  diamonds('♦'),
  joker('');

  const CardSuit(this.symbol);

  final String symbol;

  Color get color => switch (this) {
    CardSuit.hearts || CardSuit.diamonds => DarkTokens.suitRed,
    CardSuit.spades || CardSuit.clubs => DarkTokens.suitBlack,
    CardSuit.joker => DarkTokens.goldDark,
  };
}

enum CardRank {
  two('2'),
  three('3'),
  four('4'),
  five('5'),
  six('6'),
  seven('7'),
  eight('8'),
  nine('9'),
  ten('10'),
  jack('J'),
  queen('Q'),
  king('K'),
  ace('A'),
  smallJoker('小王'),
  bigJoker('大王');

  const CardRank(this.label);

  final String label;
}

class CardVisual extends StatelessWidget {
  const CardVisual({
    required this.rank,
    required this.suit,
    this.isLevelCard = false,
    this.isRedFive = false,
    this.trumpSuit,
    super.key,
  });

  final CardRank rank;
  final CardSuit suit;
  final bool isLevelCard;
  final bool isRedFive;
  final CardSuit? trumpSuit;

  @override
  Widget build(BuildContext context) {
    final label = '${rank.label}${suit.symbol}';
    final card = AspectRatio(
      aspectRatio: DarkTokens.cardAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DarkTokens.radiusCard),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 64;
            final indicators = [
              if (isLevelCard) LevelCardHighlight(compact: compact),
              if (isRedFive) RedFiveHighlight(compact: compact),
              if (trumpSuit == suit && suit.symbol.isNotEmpty)
                TrumpCorner(suit: suit, compact: compact),
            ];
            final rankStyle = TextStyle(
              color: suit.color,
              fontSize: DarkTokens.fontSizeL6,
              fontWeight: FontWeight.w700,
              height: 1,
            );
            final suitStyle = TextStyle(
              color: suit.color,
              fontSize: compact ? DarkTokens.fontSizeL6 : DarkTokens.fontSizeL3,
              height: 1,
            );

            return DecoratedBox(
              decoration: BoxDecoration(
                color: DarkTokens.cardFace,
                border: Border.all(
                  color: isRedFive
                      ? DarkTokens.redBright
                      : DarkTokens.textSecondary,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DarkTokens.spacingS1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (compact && indicators.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(rank.label, style: rankStyle),
                          if (suit.symbol.isNotEmpty)
                            Text(suit.symbol, style: suitStyle),
                        ],
                      )
                    else
                      Text(rank.label, style: rankStyle),
                    if (compact && indicators.isNotEmpty)
                      const Spacer()
                    else if (suit.symbol.isNotEmpty)
                      Expanded(
                        child: Center(
                          child: Text(suit.symbol, style: suitStyle),
                        ),
                      )
                    else
                      Expanded(
                        child: Center(
                          child: Text(
                            rank.label,
                            style: TextStyle(
                              color: suit.color,
                              fontSize: DarkTokens.fontSizeL5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    if (indicators.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final indicator in indicators)
                              indicator,
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    return Semantics(label: label, child: card);
  }
}

class CardBack extends StatelessWidget {
  const CardBack({super.key});

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: DarkTokens.cardAspectRatio,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(DarkTokens.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(DarkTokens.spacingS1),
        decoration: BoxDecoration(
          color: DarkTokens.cardBack,
          border: Border.all(color: DarkTokens.goldPrimary),
          borderRadius: BorderRadius.circular(DarkTokens.radiusCard),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: DarkTokens.goldDark),
            borderRadius: BorderRadius.circular(DarkTokens.radiusCard),
          ),
          child: const Center(
            child: DesignIcon(
              name: DesignIconName.cardBack,
              enabled: true,
            ),
          ),
        ),
      ),
    ),
  );
}

class LevelCardHighlight extends StatelessWidget {
  const LevelCardHighlight({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) =>
      _CardBadge(
        label: '级牌',
        color: DarkTokens.goldDark,
        compact: compact,
      );
}

class RedFiveHighlight extends StatelessWidget {
  const RedFiveHighlight({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) =>
      _CardBadge(label: '红五', color: DarkTokens.redAccent, compact: compact);
}

class TrumpCorner extends StatelessWidget {
  const TrumpCorner({required this.suit, this.compact = false, super.key});

  final CardSuit suit;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: DarkTokens.spacingS1,
      vertical: compact ? 0 : DarkTokens.spacingS1 / 2,
    ),
    decoration: BoxDecoration(
      color: DarkTokens.goldPrimary,
      borderRadius: BorderRadius.circular(DarkTokens.radiusBadge),
    ),
    child: Text(
      suit.symbol,
      style: TextStyle(
        color: suit.color,
        fontSize: DarkTokens.fontSizeL6,
        height: 1,
      ),
    ),
  );
}

class _CardBadge extends StatelessWidget {
  const _CardBadge({
    required this.label,
    required this.color,
    this.compact = false,
  });

  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: DarkTokens.spacingS1,
      vertical: compact ? 0 : DarkTokens.spacingS1 / 2,
    ),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(DarkTokens.radiusBadge),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: DarkTokens.textPrimary,
        fontSize: DarkTokens.fontSizeL6,
        height: 1,
      ),
    ),
  );
}
