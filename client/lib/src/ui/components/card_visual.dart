import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'design_icon.dart';

enum CardSuit {
  spades('♠', 'spades'),
  hearts('♥', 'hearts'),
  clubs('♣', 'clubs'),
  diamonds('♦', 'diamonds'),
  joker('', null);

  const CardSuit(this.symbol, this.assetName);

  final String symbol;
  final String? assetName;

  Color get color => switch (this) {
    CardSuit.hearts || CardSuit.diamonds => DarkTokens.suitRed,
    CardSuit.spades || CardSuit.clubs => DarkTokens.suitBlack,
    CardSuit.joker => DarkTokens.goldDark,
  };
}

enum CardRank {
  two('2', '2'),
  three('3', '3'),
  four('4', '4'),
  five('5', '5'),
  six('6', '6'),
  seven('7', '7'),
  eight('8', '8'),
  nine('9', '9'),
  ten('10', '10'),
  jack('J', 'jack'),
  queen('Q', 'queen'),
  king('K', 'king'),
  ace('A', 'ace'),
  smallJoker('小王', 'black_joker'),
  bigJoker('大王', 'red_joker');

  const CardRank(this.label, this.assetName);

  final String label;
  final String assetName;
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

  String get assetPath {
    if (rank == CardRank.smallJoker || rank == CardRank.bigJoker) {
      return 'assets/cards/${rank.assetName}.png';
    }

    final cardSuit = suit.assetName;
    if (cardSuit == null) {
      throw StateError('A non-joker card must have a suit.');
    }
    return 'assets/cards/${rank.assetName}_of_$cardSuit.png';
  }

  @override
  Widget build(BuildContext context) {
    final label = '${rank.label}${suit.symbol}';
    return Semantics(
      label: label,
      child: AspectRatio(
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

              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    assetPath,
                    fit: BoxFit.fill,
                    excludeFromSemantics: true,
                  ),
                  if (isLevelCard || isRedFive)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isRedFive
                              ? DarkTokens.redBright
                              : DarkTokens.goldDark,
                          width: DarkTokens.spacingS1 / 2,
                        ),
                        borderRadius: BorderRadius.circular(
                          DarkTokens.radiusCard,
                        ),
                      ),
                    ),
                  if (indicators.isNotEmpty)
                    Positioned(
                      top: DarkTokens.spacingS1,
                      right: DarkTokens.spacingS1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: indicators,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
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
