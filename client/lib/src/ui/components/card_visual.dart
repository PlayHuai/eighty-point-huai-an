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
    Widget card = AspectRatio(
      aspectRatio: DarkTokens.cardAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DarkTokens.radiusCard),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: DarkTokens.cardFace,
            border: Border.all(color: DarkTokens.textSecondary),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DarkTokens.spacingS1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rank.label,
                  style: TextStyle(
                    color: suit.color,
                    fontSize: DarkTokens.fontSizeL6,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                if (suit.symbol.isNotEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        suit.symbol,
                        style: TextStyle(
                          color: suit.color,
                          fontSize: DarkTokens.fontSizeL3,
                          height: 1,
                        ),
                      ),
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
              ],
            ),
          ),
        ),
      ),
    );

    if (isLevelCard) {
      card = LevelCardHighlight(child: card);
    }
    if (isRedFive) {
      card = RedFiveHighlight(child: card);
    }
    if (trumpSuit == suit && suit.symbol.isNotEmpty) {
      card = Stack(
        children: [
          card,
          Positioned(
            top: DarkTokens.spacingS1,
            right: DarkTokens.spacingS1,
            child: TrumpCorner(suit: suit),
          ),
        ],
      );
    }

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
  const LevelCardHighlight({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      Positioned(
        top: DarkTokens.spacingS1,
        right: DarkTokens.spacingS1,
        child: _CardBadge(label: '级牌', color: DarkTokens.goldDark),
      ),
    ],
  );
}

class RedFiveHighlight extends StatelessWidget {
  const RedFiveHighlight({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      Positioned.fill(
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: DarkTokens.redBright),
              borderRadius: BorderRadius.circular(DarkTokens.radiusCard),
            ),
          ),
        ),
      ),
      Positioned(
        top: DarkTokens.spacingS1,
        left: DarkTokens.spacingS1,
        child: _CardBadge(label: '红五', color: DarkTokens.redAccent),
      ),
    ],
  );
}

class TrumpCorner extends StatelessWidget {
  const TrumpCorner({required this.suit, super.key});

  final CardSuit suit;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: DarkTokens.spacingS1,
      vertical: DarkTokens.spacingS1 / 2,
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
  const _CardBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: DarkTokens.spacingS1,
      vertical: DarkTokens.spacingS1 / 2,
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
