import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'card_visual.dart';

class TableCard extends StatelessWidget {
  const TableCard({
    required this.card,
    this.level = '',
    this.trumpSuit = '',
    super.key,
  });

  final String card;
  final String level;
  final String trumpSuit;

  @override
  Widget build(BuildContext context) {
    final parts = card.split(':');
    final suit = switch (parts.first) {
      'clubs' => CardSuit.clubs,
      'diamonds' => CardSuit.diamonds,
      'hearts' => CardSuit.hearts,
      'spades' => CardSuit.spades,
      'joker' => CardSuit.joker,
      _ => null,
    };
    final number = parts.length == 3 ? int.tryParse(parts[1]) : null;
    if (suit == null || number == null || number < 2 || number > 16) {
      return const Center(child: Text('无效牌面'));
    }
    final rank = CardRank.values[number - 2];
    return CardVisual(
      rank: rank,
      suit: suit,
      isLevelCard: level == parts[1] || level == rank.label,
      isRedFive: suit == CardSuit.hearts && rank == CardRank.five,
      trumpSuit: switch (trumpSuit) {
        'clubs' => CardSuit.clubs,
        'diamonds' => CardSuit.diamonds,
        'hearts' => CardSuit.hearts,
        'spades' => CardSuit.spades,
        _ => null,
      },
    );
  }
}

class TableHand extends StatelessWidget {
  const TableHand({
    required this.cards,
    required this.selected,
    required this.hiddenCount,
    required this.onSelect,
    this.level = '',
    this.trumpSuit = '',
    super.key,
  });

  final List<String> cards;
  final Set<String> selected;
  final int hiddenCount;
  final ValueChanged<String>? onSelect;
  final String level;
  final String trumpSuit;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      final count = cards.isEmpty ? hiddenCount : cards.length;
      if (count == 0) return const Center(child: Text('暂无手牌'));
      final cardHeight = math.min(
        constraints.maxHeight - DarkTokens.spacingS5,
        DarkTokens.spacingS6 * (compact ? 2 : 3),
      );
      final cardWidth = cardHeight * DarkTokens.cardAspectRatio;
      final minStep = cardWidth * 0.42;
      final step = count == 1
          ? cardWidth
          : math.max(
              minStep,
              math.min(
                cardWidth * 0.72,
                (constraints.maxWidth - cardWidth) / (count - 1),
              ),
            );
      final totalWidth = cardWidth + step * (count - 1);
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: math.max(totalWidth, constraints.maxWidth),
          height: constraints.maxHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var index = 0; index < count; index++)
                Positioned(
                  left:
                      (math.max(totalWidth, constraints.maxWidth) -
                              totalWidth) /
                          2 +
                      step * index,
                  top:
                      DarkTokens.spacingS5 -
                      (cards.isNotEmpty && selected.contains(cards[index])
                          ? DarkTokens.spacingS4
                          : 0),
                  width: cardWidth,
                  height: cardHeight,
                  child: Transform.rotate(
                    angle: compact ? 0 : (index - (count - 1) / 2) * 0.006,
                    child: cards.isEmpty
                        ? const CardBack()
                        : Semantics(
                            selected: selected.contains(cards[index]),
                            button: onSelect != null,
                            child: GestureDetector(
                              key: ValueKey('hand-card-${cards[index]}'),
                              onTap: onSelect == null
                                  ? null
                                  : () => onSelect!(cards[index]),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: selected.contains(cards[index])
                                      ? Border.all(
                                          color: DarkTokens.goldBright,
                                          width: DarkTokens.spacingS1 / 2,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(
                                    DarkTokens.radiusCard,
                                  ),
                                ),
                                child: TableCard(
                                  card: cards[index],
                                  level: level,
                                  trumpSuit: trumpSuit,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class BottomCardsPanel extends StatefulWidget {
  const BottomCardsPanel({
    required this.cards,
    required this.publiclyRevealed,
    this.level = '',
    this.trumpSuit = '',
    super.key,
  });

  final List<String> cards;
  final bool publiclyRevealed;
  final String level;
  final String trumpSuit;

  @override
  State<BottomCardsPanel> createState() => _BottomCardsPanelState();
}

class _BottomCardsPanelState extends State<BottomCardsPanel> {
  bool _hovering = false;
  bool _pinned = false;

  @override
  Widget build(BuildContext context) {
    final reveal = widget.publiclyRevealed || _hovering || _pinned;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Semantics(
        label: reveal ? '底牌已展示' : '点击或悬停查看底牌',
        button: !widget.publiclyRevealed,
        child: GestureDetector(
          key: const ValueKey('bottom-cards-panel'),
          onTap: widget.publiclyRevealed
              ? null
              : () => setState(() => _pinned = !_pinned),
          child: Container(
            padding: const EdgeInsets.all(DarkTokens.spacingS3),
            decoration: BoxDecoration(
              color: DarkTokens.bgPanel,
              border: Border.all(color: DarkTokens.cardBack),
              borderRadius: BorderRadius.circular(DarkTokens.radiusPanel),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text('底牌 · ${widget.cards.length} 张'),
                    Text(widget.publiclyRevealed ? '已公开' : '已扣底 · 未公开'),
                  ],
                ),
                const SizedBox(height: DarkTokens.spacingS2),
                SizedBox(
                  height: DarkTokens.spacingS6,
                  child: Row(
                    children: [
                      for (final card in widget.cards)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DarkTokens.spacingS1 / 2,
                            ),
                            child: reveal
                                ? TableCard(
                                    card: card,
                                    level: widget.level,
                                    trumpSuit: widget.trumpSuit,
                                  )
                                : const CardBack(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
