/// Domain-only suits. [none] represents no-trump, never a physical card.
enum Suit { clubs, diamonds, hearts, spades, joker, none }

const ordinarySuits = [Suit.clubs, Suit.diamonds, Suit.hearts, Suit.spades];
const trumpSuits = [...ordinarySuits, Suit.none];

/// A physical card, including its identity within the two decks.
final class Card {
  Card(this.suit, this.rank, this.copy) {
    if (copy < 0 ||
        copy > 1 ||
        !(suit == Suit.joker
            ? rank == 15 || rank == 16
            : ordinarySuits.contains(suit) && rank >= 2 && rank <= 14)) {
      throw ArgumentError('Invalid suit:rank:copy card');
    }
  }

  factory Card.parse(String value) {
    final match = RegExp(
      r'^(clubs|diamonds|hearts|spades|joker):([2-9]|1[0-6]):([01])$',
    ).firstMatch(value);
    if (match == null) throw FormatException('Invalid card identity', value);
    try {
      return Card(
        Suit.values.byName(match[1]!),
        int.parse(match[2]!),
        int.parse(match[3]!),
      );
    } on ArgumentError {
      throw FormatException('Invalid card identity', value);
    }
  }

  final Suit suit;
  final int rank;
  final int copy;

  bool get isRedFive => suit == Suit.hearts && rank == 5;
  bool get isPoint => rank == 5 || rank == 10 || rank == 13;

  @override
  String toString() => '${suit.name}:$rank:$copy';

  @override
  bool operator ==(Object other) =>
      other is Card &&
      suit == other.suit &&
      rank == other.rank &&
      copy == other.copy;

  @override
  int get hashCode => Object.hash(suit, rank, copy);
}

List<Card> _uniqueCards(Iterable<Card> cards) {
  final result = List<Card>.unmodifiable(cards);
  if (result.toSet().length != result.length) {
    throw ArgumentError('Duplicate physical card');
  }
  return result;
}

/// Only the robot's currently visible hand and public trump context.
final class Hand {
  Hand(
    Iterable<Card> cards, {
    required this.levelRank,
    this.trumpSuit = Suit.none,
  }) : cards = _uniqueCards(cards) {
    if (levelRank < 2 || levelRank > 14 || trumpSuit == Suit.joker) {
      throw ArgumentError('Invalid trump context');
    }
  }

  final List<Card> cards;
  final int levelRank;
  final Suit trumpSuit;

  bool isTrump(Card card) =>
      card.suit == Suit.joker ||
      card.rank == levelRank ||
      (trumpSuit != Suit.none && (card.suit == trumpSuit || card.isRedFive));

  /// [Suit.none] denotes the effective trump group, including no-trump games.
  Suit effectiveSuit(Card card) => isTrump(card) ? Suit.none : card.suit;

  /// Strength only; different off-suits must not be compared as trick winners.
  int strength(Card card) {
    if (trumpSuit != Suit.none && card.isRedFive) return 600;
    if (card.rank == 16) return 500;
    if (card.rank == 15) return 400;
    if (card.rank == levelRank) {
      return card.suit == trumpSuit ? 300 : 200;
    }
    return (isTrump(card) ? 100 : 0) + card.rank;
  }
}

enum CounterKind { levelPair, smallJokerPair, bigJokerPair, redFivePair }

/// Phase/turn permissions are inputs, not inferred from card ownership.
final class TrumpState {
  TrumpState({
    this.canDeclare = false,
    this.canCounter = false,
    this.currentCounter,
    Iterable<Suit> allowedSuits = trumpSuits,
  }) : allowedSuits = Set<Suit>.unmodifiable(allowedSuits) {
    if (this.allowedSuits.contains(Suit.joker)) {
      throw ArgumentError('Joker is not a trump declaration suit');
    }
  }

  final bool canDeclare;
  final bool canCounter;
  final CounterKind? currentCounter;
  final Set<Suit> allowedSuits;
}

enum TrumpActionKind { pass, declare, counter }

final class TrumpAction {
  TrumpAction(
    this.kind, {
    this.suit = Suit.none,
    Iterable<Card> cards = const [],
    this.counterKind,
  }) : cards = _uniqueCards(cards);

  final TrumpActionKind kind;
  final Suit suit;
  final List<Card> cards;
  final CounterKind? counterKind;
}

/// Current trick only; no seat IDs or hidden hands are required.
///
/// For multi-card tricks [legalResponses] must contain rule-validated choices
/// (including shape obligations, throws and forced draws). This decision layer
/// ranks those choices; it deliberately does not port the authoritative engine.
/// Single-card tricks need no supplied choices.
final class Trick {
  Trick({
    required Iterable<Card> leadCards,
    Iterable<Card>? winningCards,
    Iterable<Iterable<Card>> legalResponses = const [],
  }) : leadCards = _uniqueCards(leadCards),
       winningCards = _uniqueCards(winningCards ?? leadCards),
       legalResponses = List<List<Card>>.unmodifiable(
         legalResponses.map(_uniqueCards),
       ) {
    if (this.leadCards.isEmpty ||
        this.winningCards.length != this.leadCards.length) {
      throw ArgumentError('A trick requires equal nonempty play sizes');
    }
  }

  final List<Card> leadCards;
  final List<Card> winningCards;
  final List<List<Card>> legalResponses;
}

/// Ephemeral, visible information from this hand only.
///
/// A played single is not evidence of a void. Populate [teammateVoidSuits]
/// only after an actual show-void; [Suit.none] means the trump group.
final class SeenInfo {
  SeenInfo({
    Iterable<Card> playedCards = const [],
    Iterable<Suit> teammateVoidSuits = const [],
    this.teammateControlsTrick = false,
  }) : playedCards = _uniqueCards(playedCards),
       teammateVoidSuits = Set<Suit>.unmodifiable(teammateVoidSuits);

  final List<Card> playedCards;
  final Set<Suit> teammateVoidSuits;
  final bool teammateControlsTrick;
}

final class FollowAction {
  FollowAction(Iterable<Card> cards) : cards = _uniqueCards(cards);
  final List<Card> cards;
}

enum LeadKind { fiveTenKing, throwCards, pair, single }

final class LeadAction {
  LeadAction(this.kind, Iterable<Card> cards) : cards = _uniqueCards(cards);
  final LeadKind kind;
  final List<Card> cards;
}
