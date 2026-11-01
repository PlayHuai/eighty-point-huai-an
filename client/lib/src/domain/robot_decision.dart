/// Pure, deterministic recommendations. Never sends or authorizes an action.
library;

import 'robot_types.dart';
export 'robot_types.dart';

TrumpAction decideTrump(Hand hand, TrumpState state) {
  final cards = _sorted(hand.cards, hand);
  if (state.canCounter) {
    for (final kind in CounterKind.values) {
      if (state.currentCounter != null &&
          kind.index <= state.currentCounter!.index) {
        continue;
      }
      if (kind == CounterKind.redFivePair) {
        final reds = cards.where((c) => c.isRedFive).toList();
        if (reds.length != 2) continue;
        // Ownership of both red fives is required, even though only one is
        // submitted together with a companion to choose the new trump suit.
        for (final companion in cards.where((c) => c != reds.first)) {
          final suit =
              companion.rank == hand.levelRank || companion.suit == Suit.joker
              ? Suit.none
              : companion.suit;
          if (state.allowedSuits.contains(suit)) {
            return TrumpAction(
              TrumpActionKind.counter,
              suit: suit,
              cards: [reds.first, companion],
              counterKind: kind,
            );
          }
        }
      } else {
        for (final pair in _pairs(cards)) {
          final rank = pair.first.rank;
          if (!(switch (kind) {
            CounterKind.levelPair =>
              rank == hand.levelRank && !pair.first.isRedFive,
            CounterKind.smallJokerPair => rank == 15,
            CounterKind.bigJokerPair => rank == 16,
            CounterKind.redFivePair => false,
          })) {
            continue;
          }
          final suit = rank >= 15 ? Suit.none : pair.first.suit;
          if (state.allowedSuits.contains(suit)) {
            return TrumpAction(
              TrumpActionKind.counter,
              suit: suit,
              cards: pair,
              counterKind: kind,
            );
          }
        }
      }
    }
  }
  if (state.canDeclare) {
    for (final card in cards) {
      if (card.rank == hand.levelRank &&
          state.allowedSuits.contains(card.suit)) {
        return TrumpAction(
          TrumpActionKind.declare,
          suit: card.suit,
          cards: [card],
        );
      }
    }
  }
  return TrumpAction(TrumpActionKind.pass);
}

FollowAction followSuit(Hand hand, Trick trick, SeenInfo seen) {
  _requireCards(hand);
  final leadSuit = hand.effectiveSuit(trick.leadCards.first);
  final held = hand.cards.where((c) => hand.effectiveSuit(c) == leadSuit);
  final count = trick.leadCards.length;
  if (hand.cards.length < count) {
    throw ArgumentError('Hand is shorter than the trick');
  }
  final List<List<Card>> choices;
  if (trick.legalResponses.isNotEmpty) {
    choices = trick.legalResponses.toList();
  } else if (count == 1) {
    choices = (held.isNotEmpty ? held : hand.cards).map((c) => [c]).toList();
  } else {
    choices = _legalResponses(hand, trick, leadSuit, held.toList());
  }
  final requiredSuitCount = held.length < count ? held.length : count;
  for (final choice in choices) {
    if (choice.length != count ||
        !choice.every(hand.cards.contains) ||
        choice.where((c) => hand.effectiveSuit(c) == leadSuit).length <
            requiredSuitCount) {
      throw ArgumentError('Response violates ownership, count or follow suit');
    }
  }

  final winners = choices
      .where((c) => _beats(c, trick.winningCards, leadSuit, hand))
      .toList();
  if (winners.isNotEmpty) {
    winners.sort((a, b) => _comparePlays(a, b, hand));
    return FollowAction(winners.first);
  }
  final teammateCanCollect =
      seen.teammateControlsTrick || seen.teammateVoidSuits.contains(leadSuit);
  choices.sort((a, b) {
    final preference = teammateCanCollect && held.isNotEmpty
        ? _feedScore(a).compareTo(_feedScore(b))
        : _discardScore(a, hand).compareTo(_discardScore(b, hand));
    return preference != 0 ? preference : _comparePlays(a, b, hand);
  });
  return FollowAction(choices.first);
}

List<Card> currentWinningPlay(Hand hand, Iterable<Iterable<Card>> plays) {
  final candidates = plays
      .map((play) => List<Card>.unmodifiable(play))
      .toList();
  if (candidates.isEmpty || candidates.any((play) => play.isEmpty)) {
    throw ArgumentError('At least one nonempty play is required');
  }
  final leadSuit = hand.effectiveSuit(candidates.first.first);
  var winner = candidates.first;
  for (final candidate in candidates.skip(1)) {
    if (_beats(candidate, winner, leadSuit, hand)) winner = candidate;
  }
  return winner;
}

LeadAction lead(Hand hand, SeenInfo seen) {
  _requireCards(hand);
  if (seen.playedCards.any(hand.cards.contains)) {
    throw ArgumentError('Played cards cannot still be held');
  }
  final cards = _sorted(hand.cards, hand);
  for (final suit in ordinarySuits) {
    final combo = <Card>[];
    for (final rank in [5, 10, 13]) {
      final matches = cards.where((c) => c.suit == suit && c.rank == rank);
      if (matches.isNotEmpty) combo.add(matches.first);
    }
    if (combo.length != 3) continue;
    final main = suit == hand.trumpSuit;
    final available = cards.where(
      (c) => !combo.contains(c) && (main ? !hand.isTrump(c) : c.suit == suit),
    );
    final extras = _safeUnits(available, hand, seen).expand((c) => c);
    return LeadAction(LeadKind.fiveTenKing, [...combo, ...extras]);
  }
  for (final suit in [...ordinarySuits, Suit.none]) {
    final units = _safeUnits(
      cards.where((c) => hand.effectiveSuit(c) == suit),
      hand,
      seen,
    );
    if (units.length >= 2) {
      return LeadAction(LeadKind.throwCards, units.expand((c) => c));
    }
  }
  final pairs = _pairs(cards);
  for (final pair in pairs) {
    final suit = hand.effectiveSuit(pair.first);
    if (suit != Suit.none && seen.teammateVoidSuits.contains(suit)) {
      return LeadAction(LeadKind.pair, pair);
    }
  }
  for (final pair in pairs) {
    if (hand.isTrump(pair.first)) return LeadAction(LeadKind.pair, pair);
  }
  final trumps = cards.where(hand.isTrump);
  return LeadAction(LeadKind.single, [
    trumps.isNotEmpty ? trumps.first : cards.first,
  ]);
}

List<Card> selectBottom(Hand hand, Suit trumpSuit, bool isDealer) {
  if (trumpSuit == Suit.joker) throw ArgumentError('Invalid trump suit');
  final context = Hand(
    hand.cards,
    levelRank: hand.levelRank,
    trumpSuit: trumpSuit,
  );
  final eligible = hand.cards
      .where((c) => c.rank != hand.levelRank && !c.isRedFive)
      .toList();
  if (eligible.length < 8) {
    throw StateError('Cannot bury eight cards without protected cards');
  }
  int compareDiscard(Card a, Card b) {
    final score = _discardScore([
      a,
    ], context).compareTo(_discardScore([b], context));
    return score != 0 ? score : _compareCards(a, b, context);
  }

  final suits = ordinarySuits.where((s) => s != trumpSuit).toList();
  suits.sort((a, b) {
    final byCount = eligible
        .where((c) => c.suit == b)
        .length
        .compareTo(eligible.where((c) => c.suit == a).length);
    return byCount != 0 ? byCount : a.index.compareTo(b.index);
  });
  final primary = eligible.where((c) => c.suit == suits.first).toList()
    ..removeWhere((c) => isDealer && c.rank == 14)
    ..sort(compareDiscard);
  final selected = primary.take(8).toList();
  final rest =
      eligible
          .where(
            (c) =>
                !selected.contains(c) &&
                !(isDealer && c.suit == suits.first && c.rank == 14),
          )
          .toList()
        ..sort(compareDiscard);
  selected.addAll(rest.take(8 - selected.length));
  return List<Card>.unmodifiable(selected);
}

void _requireCards(Hand hand) {
  if (hand.cards.isEmpty) throw StateError('No play exists for an empty hand');
}

int _compareCards(Card a, Card b, Hand hand) {
  final strength = hand.strength(a).compareTo(hand.strength(b));
  if (strength != 0) return strength;
  final suit = a.suit.index.compareTo(b.suit.index);
  return suit != 0 ? suit : a.copy.compareTo(b.copy);
}

List<Card> _sorted(Iterable<Card> cards, Hand hand) =>
    cards.toList()..sort((a, b) => _compareCards(a, b, hand));

List<List<Card>> _pairs(Iterable<Card> cards) {
  final groups = <String, List<Card>>{};
  for (final card in cards) {
    groups.putIfAbsent('${card.suit.name}:${card.rank}', () => []).add(card);
  }
  return groups.values.where((g) => g.length == 2).toList();
}

bool _is510K(List<Card> cards) =>
    cards.length == 3 &&
    cards.every((c) => c.suit == cards.first.suit) &&
    cards.map((c) => c.rank).toSet().containsAll([5, 10, 13]);

bool _beats(
  List<Card> candidate,
  List<Card> incumbent,
  Suit leadSuit,
  Hand hand,
) {
  final candidateShape = _playShape(candidate, hand);
  final incumbentShape = _playShape(incumbent, hand);
  if (candidateShape == null || candidateShape != incumbentShape) return false;
  if (candidateShape == '510k') {
    return candidate.first.suit == hand.trumpSuit &&
        incumbent.first.suit != hand.trumpSuit;
  }
  final candidateSuit = hand.effectiveSuit(candidate.first);
  final incumbentSuit = hand.effectiveSuit(incumbent.first);
  if (!candidate.every((c) => hand.effectiveSuit(c) == candidateSuit)) {
    return false;
  }
  if (candidateSuit != Suit.none && candidateSuit != leadSuit) return false;
  if (candidateSuit != incumbentSuit) {
    return candidateSuit == Suit.none;
  }
  final high = candidate.map(hand.strength).reduce((a, b) => a > b ? a : b);
  final current = incumbent.map(hand.strength).reduce((a, b) => a > b ? a : b);
  return high > current;
}

List<List<Card>> _legalResponses(
  Hand hand,
  Trick trick,
  Suit leadSuit,
  List<Card> held,
) {
  final count = trick.leadCards.length;
  final requiredSuitCount = held.length < count ? held.length : count;
  final sorted = _sorted(hand.cards, hand);
  final choices = <List<Card>>[];

  bool isLegal(List<Card> cards) {
    if (cards.length != count ||
        cards.where((c) => hand.effectiveSuit(c) == leadSuit).length <
            requiredSuitCount) {
      return false;
    }
    if (held.isEmpty && cards.every(hand.isTrump)) {
      return _playShape(cards, hand) == _playShape(trick.leadCards, hand);
    }
    return true;
  }

  if (count > 6) {
    final chosen = <Card>[...held.take(count)];
    for (final card in sorted) {
      if (chosen.length == count) break;
      if (!chosen.contains(card)) chosen.add(card);
    }
    if (isLegal(chosen)) return [chosen];
  }

  const maxCandidates = 50000;
  void visit(int start, List<Card> selected) {
    if (choices.length >= maxCandidates) return;
    if (selected.length == count) {
      if (isLegal(selected)) choices.add(List<Card>.unmodifiable(selected));
      return;
    }
    final remaining = count - selected.length;
    for (var index = start; index <= sorted.length - remaining; index++) {
      selected.add(sorted[index]);
      visit(index + 1, selected);
      selected.removeLast();
      if (choices.length >= maxCandidates) return;
    }
  }

  visit(0, []);
  if (choices.isEmpty) {
    throw StateError('No legal response exists for the current trick');
  }
  return choices;
}

String? _playShape(List<Card> cards, Hand hand) {
  if (cards.isEmpty) return null;
  if (cards.length == 1) return 'single';
  if (cards.length == 2) return _pairs(cards).isNotEmpty ? 'pair' : null;
  if (_is510K(cards)) return '510k';
  final pairs = _pairs(cards);
  if (cards.length == 4 && pairs.length == 2) {
    return _isTractor(cards, hand) ? 'tractor:2' : 'two-pairs';
  }
  if (_isTractor(cards, hand)) return 'tractor:${cards.length ~/ 2}';
  return null;
}

bool _isTractor(List<Card> cards, Hand hand) {
  if (cards.length < 4 || cards.length.isOdd) return false;
  final suit = cards.first.suit;
  if (cards.any((card) => card.suit != suit || card.rank == hand.levelRank)) {
    return false;
  }
  final pairs = _pairs(cards);
  if (pairs.length * 2 != cards.length) return false;
  final ranks = pairs.map((pair) => pair.first.rank).toList()..sort();
  for (var index = 1; index < ranks.length; index++) {
    if (ranks[index] != ranks[index - 1] + 1) return false;
  }
  return true;
}

int _comparePlays(List<Card> a, List<Card> b, Hand hand) {
  final left = _sorted(a, hand).reversed.toList();
  final right = _sorted(b, hand).reversed.toList();
  for (var i = 0; i < left.length; i++) {
    final order = _compareCards(left[i], right[i], hand);
    if (order != 0) return order;
  }
  return 0;
}

int _feedScore(List<Card> cards) {
  // Prefer 5, then 10, then K. Non-point cards are a fallback.
  return cards.fold(
    0,
    (sum, c) =>
        sum +
        switch (c.rank) {
          5 => 0,
          10 => 1,
          13 => 2,
          _ => 100,
        },
  );
}

int _discardScore(List<Card> cards, Hand hand) => cards.fold(
  0,
  (sum, c) =>
      sum +
      (c.isRedFive || c.rank == hand.levelRank ? 10000 : 0) +
      (hand.isTrump(c) ? 1000 : 0) +
      (c.isPoint ? 100 : 0),
);

/// Proves each throw unit unbeatable against every still-unseen physical card.
/// Unlike guessing from a long suit, this uses no opponent hand information.
List<List<Card>> _safeUnits(
  Iterable<Card> available,
  Hand hand,
  SeenInfo seen,
) {
  final known = {...hand.cards, ...seen.playedCards};
  final unknown = <Card>[
    for (final suit in ordinarySuits)
      for (var rank = 2; rank <= 14; rank++)
        for (var copy = 0; copy < 2; copy++) Card(suit, rank, copy),
    for (final rank in [15, 16])
      for (var copy = 0; copy < 2; copy++) Card(Suit.joker, rank, copy),
  ].where((c) => !known.contains(c)).toList();
  final cards = available.toList();
  final pairs = _pairs(cards);
  final units = <List<Card>>[
    ...pairs,
    for (final card in cards)
      if (!pairs.any((p) => p.contains(card))) [card],
  ];
  return units.where((unit) {
    final card = unit.first;
    final higher = unknown.where(
      (c) =>
          hand.effectiveSuit(c) == hand.effectiveSuit(card) &&
          hand.strength(c) > hand.strength(card),
    );
    if (unit.length == 1) return higher.isEmpty;
    return _pairs(higher).isEmpty;
  }).toList();
}
