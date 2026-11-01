import 'dart:math';

import 'package:eighty_point_huai_an/src/domain/robot_decision.dart';
import 'package:flutter_test/flutter_test.dart';

Card c(String value) => Card.parse(value);
List<Card> cs(String values) => values.split(' ').map(c).toList();
Hand hand(String values, {int level = 2, Suit trump = Suit.spades}) =>
    Hand(cs(values), levelRank: level, trumpSuit: trump);
Trick single(String lead, {String? winner}) =>
    Trick(leadCards: [c(lead)], winningCards: [c(winner ?? lead)]);
void owns(Hand hand, Iterable<Card> selected) {
  expect(selected, isNotEmpty);
  expect(selected.toSet().length, selected.length);
  expect(selected.every(hand.cards.contains), isTrue);
}

void main() {
  group('typed visible inputs', () {
    test('stable wire identities round trip including both jokers', () {
      for (final value in [
        'clubs:2:0',
        'diamonds:14:1',
        'hearts:5:0',
        'spades:13:1',
        'joker:15:0',
        'joker:16:1',
      ]) {
        expect(c(value).toString(), value);
        expect(c(value), c(value));
      }
    });

    test('reject malformed, noncanonical and impossible identities', () {
      for (final value in [
        'clubs:02:0',
        'clubs:15:0',
        'joker:14:0',
        'none:2:0',
        'clubs:2:2',
        'clubs:1:0',
        'clubs:2:-1',
        'Clubs:2:0',
        'clubs:2:0 ',
      ]) {
        expect(() => c(value), throwsFormatException, reason: value);
      }
    });

    test('inputs are immutable, physical copies are distinct', () {
      final source = cs('clubs:8:0 clubs:8:1');
      final input = Hand(source, levelRank: 2);
      source.clear();
      expect(input.cards.length, 2);
      expect(() => input.cards.clear(), throwsUnsupportedError);
      expect(() => hand('clubs:8:0 clubs:8:0'), throwsArgumentError);
      expect(() => hand('clubs:8:0', level: 15), throwsArgumentError);
      expect(() => hand('clubs:8:0', trump: Suit.joker), throwsArgumentError);
    });

    test('trump groups and rank hierarchy match visible rules', () {
      final h = hand(
        'hearts:5:0 joker:16:0 joker:15:0 spades:2:0 '
        'clubs:2:0 diamonds:2:0 spades:14:0 clubs:14:0',
      );
      final ranks = h.cards.map(h.strength).toList();
      expect(ranks[0], greaterThan(ranks[1]));
      expect(ranks[1], greaterThan(ranks[2]));
      expect(ranks[2], greaterThan(ranks[3]));
      expect(ranks[3], greaterThan(ranks[4]));
      expect(ranks[4], ranks[5]);
      expect(ranks[5], greaterThan(ranks[6]));
      expect(h.effectiveSuit(c('clubs:2:0')), Suit.none);
      final noTrump = hand('hearts:5:0 joker:15:0', trump: Suit.none);
      expect(noTrump.isTrump(noTrump.cards.first), isFalse);
      expect(noTrump.isTrump(noTrump.cards.last), isTrue);
    });
  });

  group('decideTrump', () {
    test('immediately declares using any available allowed level card', () {
      final h = hand('clubs:2:0 diamonds:2:0 clubs:3:0');
      final action = decideTrump(h, TrumpState(canDeclare: true));
      expect(action.kind, TrumpActionKind.declare);
      expect(action.suit, isIn([Suit.clubs, Suit.diamonds]));
      expect(action.cards.single.rank, h.levelRank);
      owns(h, action.cards);
      final restricted = decideTrump(
        h,
        TrumpState(canDeclare: true, allowedSuits: [Suit.diamonds]),
      );
      expect(restricted.suit, Suit.diamonds);
    });

    test('no opportunity or no phase permission passes', () {
      final h = hand('clubs:8:0');
      expect(
        decideTrump(h, TrumpState(canDeclare: true, canCounter: true)).kind,
        TrumpActionKind.pass,
      );
      expect(
        decideTrump(hand('clubs:2:0 clubs:2:1'), TrumpState()).kind,
        TrumpActionKind.pass,
      );
      expect(
        decideTrump(Hand([], levelRank: 2), TrumpState()).kind,
        TrumpActionKind.pass,
      );
    });

    test(
      'counter precedes declare; same-size level counter cannot overcall',
      () {
        final h = hand('clubs:2:0 clubs:2:1 diamonds:2:0');
        final action = decideTrump(
          h,
          TrumpState(canDeclare: true, canCounter: true),
        );
        expect(action.kind, TrumpActionKind.counter);
        expect(action.counterKind, CounterKind.levelPair);
        owns(h, action.cards);
        expect(
          decideTrump(
            h,
            TrumpState(
              canDeclare: true,
              canCounter: true,
              currentCounter: CounterKind.levelPair,
            ),
          ).kind,
          TrumpActionKind.declare,
        );
      },
    );

    test('joker counter ladder and strongest-current pass', () {
      final h = hand('joker:15:0 joker:15:1 joker:16:0 joker:16:1');
      final small = decideTrump(h, TrumpState(canCounter: true));
      expect(small.counterKind, CounterKind.smallJokerPair);
      expect(small.suit, Suit.none);
      final big = decideTrump(
        h,
        TrumpState(
          canCounter: true,
          currentCounter: CounterKind.smallJokerPair,
        ),
      );
      expect(big.counterKind, CounterKind.bigJokerPair);
      expect(big.suit, Suit.none);
      expect(
        decideTrump(
          h,
          TrumpState(canCounter: true, currentCounter: CounterKind.redFivePair),
        ).kind,
        TrumpActionKind.pass,
      );
    });

    test('red-five counter requires ownership of both copies', () {
      final h = hand('hearts:5:0 hearts:5:1 clubs:8:0');
      final action = decideTrump(
        h,
        TrumpState(
          canCounter: true,
          currentCounter: CounterKind.bigJokerPair,
          allowedSuits: [Suit.clubs],
        ),
      );
      expect(action.counterKind, CounterKind.redFivePair);
      expect(action.suit, Suit.clubs);
      expect(action.cards, cs('hearts:5:0 clubs:8:0'));
      expect(
        decideTrump(
          hand('hearts:5:0 clubs:8:0'),
          TrumpState(canCounter: true),
        ).kind,
        TrumpActionKind.pass,
      );
    });

    test('red five pair remains the highest counter when level is five', () {
      final action = decideTrump(
        hand('hearts:5:0 hearts:5:1 clubs:8:0', level: 5),
        TrumpState(
          canCounter: true,
          currentCounter: CounterKind.bigJokerPair,
          allowedSuits: [Suit.clubs],
        ),
      );
      expect(action.counterKind, CounterKind.redFivePair);
      expect(action.suit, Suit.clubs);
      final unrestricted = decideTrump(
        hand('hearts:5:0 hearts:5:1', level: 5),
        TrumpState(canCounter: true),
      );
      expect(unrestricted.counterKind, CounterKind.redFivePair);
      expect(unrestricted.suit, Suit.none);
    });
  });

  group('followSuit', () {
    test('beats with smallest winning card, even a point card or teammate', () {
      final h = hand('clubs:6:0 clubs:10:0 clubs:13:0 spades:3:0');
      final action = followSuit(
        h,
        single('clubs:9:1'),
        SeenInfo(teammateControlsTrick: true),
      );
      expect(action.cards, cs('clubs:10:0'));
    });

    test(
      'feeds 5 before 10 before K when teammate controls or showed void',
      () {
        for (final seen in [
          SeenInfo(teammateControlsTrick: true),
          SeenInfo(teammateVoidSuits: [Suit.clubs]),
        ]) {
          final action = followSuit(
            hand('clubs:4:0 clubs:5:0 clubs:10:0 clubs:13:0'),
            single('clubs:14:1'),
            seen,
          );
          expect(action.cards, cs('clubs:5:0'));
        }
        expect(
          followSuit(
            hand('clubs:4:0 clubs:10:0 clubs:13:0'),
            single('clubs:14:1'),
            SeenInfo(teammateControlsTrick: true),
          ).cards,
          cs('clubs:10:0'),
        );
      },
    );

    test('cannot win: discard small nonpoint, or smallest forced point', () {
      expect(
        followSuit(
          hand('clubs:5:0 clubs:6:0 clubs:10:0'),
          single('clubs:14:1'),
          SeenInfo(),
        ).cards,
        cs('clubs:6:0'),
      );
      expect(
        followSuit(
          hand('clubs:5:0 clubs:10:0 clubs:13:0'),
          single('clubs:14:1'),
          SeenInfo(),
        ).cards,
        cs('clubs:5:0'),
      );
    });

    test('void: ruffs with smallest winning trump, not a smaller loser', () {
      final h = hand('spades:3:0 spades:9:0 spades:11:0 diamonds:4:0');
      expect(
        followSuit(h, single('clubs:14:1'), SeenInfo()).cards,
        cs('spades:3:0'),
      );
      expect(
        followSuit(
          h,
          single('clubs:14:1', winner: 'spades:8:1'),
          SeenInfo(),
        ).cards,
        cs('spades:9:0'),
      );
      expect(
        followSuit(
          h,
          single('clubs:14:1', winner: 'spades:14:1'),
          SeenInfo(),
        ).cards,
        cs('diamonds:4:0'),
      );
    });

    test('void without trump discards nonpoint; level-only fallback works', () {
      expect(
        followSuit(
          hand('diamonds:5:0 hearts:4:0'),
          single('clubs:14:1'),
          SeenInfo(),
        ).cards,
        cs('hearts:4:0'),
      );
      final h = hand('clubs:2:0 clubs:2:1');
      owns(h, followSuit(h, single('diamonds:3:0'), SeenInfo()).cards);
    });

    test('must follow effective trump group, not printed suit', () {
      final h = hand('clubs:2:0 clubs:14:0');
      expect(
        followSuit(h, single('spades:3:1'), SeenInfo()).cards,
        cs('clubs:2:0'),
      );
      expect(
        followSuit(h, single('clubs:3:1'), SeenInfo()).cards,
        cs('clubs:14:0'),
      );
    });

    test('off-suit cannot beat trump; equal off-level ranks do not win', () {
      final h = hand('clubs:14:0 hearts:3:0');
      expect(
        followSuit(h, single('spades:4:1'), SeenInfo()).cards,
        cs('hearts:3:0'),
      );
      expect(
        followSuit(
          hand('clubs:2:0 spades:2:0'),
          single('diamonds:2:1'),
          SeenInfo(),
        ).cards,
        cs('spades:2:0'),
      );
    });

    test(
      'multi-card responses enumerate legal pairs without splitting them',
      () {
        final h = hand('clubs:8:0 clubs:8:1 clubs:10:0 clubs:10:1 clubs:3:0');
        final trick = Trick(leadCards: cs('clubs:7:0 clubs:7:1'));
        expect(
          followSuit(h, trick, SeenInfo()).cards,
          cs('clubs:8:0 clubs:8:1'),
        );
      },
    );

    test('current winner is computed from all public plays', () {
      final h = hand('clubs:14:0 spades:2:0');
      expect(
        currentWinningPlay(h, [
          cs('clubs:10:0'),
          cs('spades:2:0'),
          cs('clubs:14:0'),
        ]),
        cs('spades:2:0'),
      );
    });

    test('partial suit multi-card response retains every required card', () {
      final h = hand('clubs:3:0 spades:4:0 diamonds:5:0');
      final trick = Trick(
        leadCards: cs('clubs:7:0 clubs:7:1'),
        legalResponses: [
          cs('clubs:3:0 spades:4:0'),
          cs('clubs:3:0 diamonds:5:0'),
        ],
      );
      final action = followSuit(h, trick, SeenInfo());
      owns(h, action.cards);
      expect(action.cards, contains(c('clubs:3:0')));
      expect(action.cards.length, 2);
    });

    test('unpaired high responses do not falsely count as a winning pair', () {
      final h = hand('clubs:14:0 clubs:4:0 clubs:5:0');
      final action = followSuit(
        h,
        Trick(
          leadCards: cs('clubs:13:0 clubs:13:1'),
          legalResponses: [
            cs('clubs:14:0 clubs:4:0'),
            cs('clubs:5:0 clubs:4:0'),
          ],
        ),
        SeenInfo(teammateControlsTrick: true),
      );
      expect(action.cards, cs('clubs:5:0 clubs:4:0'));
    });

    test('no-trump red five is an ordinary heart and can be followed', () {
      final h = hand('hearts:5:0 hearts:8:0 joker:15:0', trump: Suit.none);
      expect(
        followSuit(h, single('hearts:4:1'), SeenInfo()).cards,
        cs('hearts:5:0'),
      );
    });

    test('invalid contexts fail explicitly rather than inventing actions', () {
      expect(
        () =>
            followSuit(Hand([], levelRank: 2), single('clubs:3:0'), SeenInfo()),
        throwsStateError,
      );
      final h = hand('clubs:8:0 clubs:8:1 spades:3:0');
      final generated = followSuit(
        h,
        Trick(leadCards: cs('clubs:7:0 clubs:7:1')),
        SeenInfo(),
      );
      expect(generated.cards.length, 2);
      expect(generated.cards.every(h.cards.contains), isTrue);
      for (final choice in [
        cs('clubs:8:0'),
        cs('clubs:8:0 spades:3:0'),
        cs('clubs:9:0 clubs:9:1'),
      ]) {
        expect(
          () => followSuit(
            h,
            Trick(
              leadCards: cs('clubs:7:0 clubs:7:1'),
              legalResponses: [choice],
            ),
            SeenInfo(),
          ),
          throwsArgumentError,
        );
      }
    });
  });

  group('lead priority ladder', () {
    test('510k precedes throws/pairs and carries only provably high units', () {
      final h = hand(
        'clubs:5:0 clubs:10:0 clubs:13:0 clubs:14:0 clubs:4:0 '
        'spades:8:0 spades:8:1',
      );
      final action = lead(h, SeenInfo());
      expect(action.kind, LeadKind.fiveTenKing);
      expect(action.cards, cs('clubs:5:0 clubs:10:0 clubs:13:0 clubs:14:0'));
      owns(h, action.cards);
    });

    test('main 510k may carry副牌 but never additional trumps', () {
      final h = hand(
        'spades:5:0 spades:10:0 spades:13:0 '
        'hearts:5:0 clubs:14:0 diamonds:3:0',
      );
      final action = lead(h, SeenInfo());
      expect(action.kind, LeadKind.fiveTenKing);
      expect(action.cards, contains(c('clubs:14:0')));
      expect(action.cards, isNot(contains(c('hearts:5:0'))));
      expect(action.cards, isNot(contains(c('diamonds:3:0'))));
    });

    test('safe large throw precedes teammate void pair and trump pair', () {
      final h = hand(
        'clubs:14:0 clubs:14:1 clubs:13:0 '
        'diamonds:7:0 diamonds:7:1 spades:8:0 spades:8:1',
      );
      final action = lead(h, SeenInfo(teammateVoidSuits: [Suit.diamonds]));
      expect(action.kind, LeadKind.throwCards);
      expect(
        action.cards.toSet(),
        cs('clubs:14:0 clubs:14:1 clubs:13:0').toSet(),
      );
    });

    test('long low suit alone never establishes a safe throw', () {
      final h = hand('clubs:3:0 clubs:4:0 clubs:6:0 clubs:7:0');
      expect(lead(h, SeenInfo()).kind, LeadKind.single);
    });

    test('only this-hand played cards can prove a newly high throw', () {
      final h = hand('clubs:13:0 clubs:12:0');
      expect(lead(h, SeenInfo()).kind, LeadKind.single);
      final action = lead(
        h,
        SeenInfo(playedCards: cs('clubs:14:0 clubs:14:1')),
      );
      // The other king is still unseen, so the queen cannot be safely thrown.
      expect(action.kind, LeadKind.single);
      final proven = lead(
        h,
        SeenInfo(playedCards: cs('clubs:14:0 clubs:14:1 clubs:13:1')),
      );
      expect(proven.kind, LeadKind.throwCards);
      expect(proven.cards.toSet(), h.cards.toSet());
    });

    test('void副牌 pair precedes trump pair only with genuine void evidence', () {
      final h = hand('clubs:8:0 clubs:8:1 spades:7:0 spades:7:1');
      expect(
        lead(h, SeenInfo(teammateVoidSuits: [Suit.clubs])).cards,
        cs('clubs:8:0 clubs:8:1'),
      );
      expect(lead(h, SeenInfo()).cards, cs('spades:7:0 spades:7:1'));
      expect(
        lead(h, SeenInfo(teammateVoidSuits: [Suit.diamonds])).cards,
        cs('spades:7:0 spades:7:1'),
      );
    });

    test('no pair falls through to small trump, then副牌 single', () {
      expect(
        lead(
          hand('clubs:8:0 spades:9:0 spades:3:0 joker:16:0'),
          SeenInfo(),
        ).cards,
        cs('spades:3:0'),
      );
      final h = hand('clubs:8:0 diamonds:4:0');
      final action = lead(h, SeenInfo());
      expect(action.kind, LeadKind.single);
      owns(h, action.cards);
      expect(lead(hand('hearts:5:0'), SeenInfo()).cards, cs('hearts:5:0'));
    });

    test('empty hand and stale played-card overlap reject explicitly', () {
      expect(() => lead(Hand([], levelRank: 2), SeenInfo()), throwsStateError);
      expect(
        () => lead(hand('clubs:3:0'), SeenInfo(playedCards: cs('clubs:3:0'))),
        throwsArgumentError,
      );
    });
  });

  group('selectBottom', () {
    test('concentrates eight cards in one nontrump suit when possible', () {
      final h = hand(
        'clubs:3:0 clubs:4:0 clubs:5:0 clubs:6:0 clubs:7:0 '
        'clubs:8:0 clubs:9:0 clubs:10:0 diamonds:3:0 spades:3:0',
      );
      final result = selectBottom(h, Suit.spades, true);
      expect(result.length, 8);
      expect(result.every((c) => c.suit == Suit.clubs), isTrue);
      owns(h, result);
    });

    test('never buries level, red five, or an ace in the selected suit', () {
      final h = hand(
        'clubs:2:0 hearts:5:0 clubs:14:0 diamonds:14:0 '
        'clubs:3:0 clubs:4:0 clubs:6:0 clubs:7:0 '
        'diamonds:3:0 diamonds:4:0 hearts:3:0 spades:3:0',
      );
      final result = selectBottom(h, Suit.spades, true);
      expect(result.length, 8);
      expect(
        result.every(
          (c) =>
              c.rank != 2 &&
              !c.isRedFive &&
              !(c.suit == Suit.clubs && c.rank == 14),
        ),
        isTrue,
      );
      owns(h, result);
    });

    test('dealer may top up with an ace from another suit', () {
      final h = hand(
        'clubs:3:0 clubs:4:0 clubs:6:0 clubs:7:0 clubs:8:0 '
        'clubs:9:0 clubs:10:0 diamonds:14:0',
      );
      final result = selectBottom(h, Suit.spades, true);
      expect(result.length, 8);
      expect(result, contains(c('diamonds:14:0')));
      expect(result, isNot(contains(c('clubs:14:0'))));
    });

    test('nondealer may bury ace; explicit trump argument controls suit', () {
      final h = hand(
        'clubs:14:0 clubs:3:0 clubs:4:0 clubs:6:0 '
        'clubs:7:0 clubs:8:0 clubs:9:0 clubs:11:0',
        trump: Suit.clubs,
      );
      final result = selectBottom(h, Suit.spades, false);
      expect(result, contains(c('clubs:14:0')));
      expect(result.length, 8);
    });

    test('top-up favors small nonpoint off-suits over points and trumps', () {
      final h = hand(
        'clubs:3:0 clubs:4:0 clubs:6:0 clubs:7:0 clubs:8:0 clubs:9:0 '
        'diamonds:5:0 hearts:3:0 hearts:4:0 spades:3:0',
      );
      final result = selectBottom(h, Suit.spades, true);
      expect(result.length, 8);
      expect(result, containsAll(cs('hearts:3:0 hearts:4:0')));
      expect(result, isNot(contains(c('diamonds:5:0'))));
      expect(result, isNot(contains(c('spades:3:0'))));
    });

    test(
      'impossible protected-card constraints fail, never silently violate',
      () {
        expect(
          () => selectBottom(
            hand(
              'clubs:2:0 clubs:2:1 diamonds:2:0 diamonds:2:1 '
              'hearts:2:0 hearts:2:1 spades:2:0 spades:2:1',
            ),
            Suit.spades,
            true,
          ),
          throwsStateError,
        );
        expect(
          () => selectBottom(hand('clubs:3:0'), Suit.spades, true),
          throwsStateError,
        );
      },
    );
  });

  test(
    'seeded hands preserve ownership, follow obligation and determinism',
    () {
      final deck = [
        for (final suit in ordinarySuits)
          for (var rank = 2; rank <= 14; rank++)
            for (var copy = 0; copy < 2; copy++) Card(suit, rank, copy),
        for (final rank in [15, 16])
          for (var copy = 0; copy < 2; copy++) Card(Suit.joker, rank, copy),
      ];
      final random = Random(80);
      for (var i = 0; i < 80; i++) {
        deck.shuffle(random);
        final h = Hand(
          deck.take(25),
          levelRank: 2 + i % 13,
          trumpSuit: trumpSuits[i % trumpSuits.length],
        );
        final seen = SeenInfo();
        final trick = Trick(leadCards: [deck[25]]);
        final action = followSuit(h, trick, seen);
        owns(h, action.cards);
        final suit = h.effectiveSuit(trick.leadCards.single);
        if (h.cards.any((c) => h.effectiveSuit(c) == suit)) {
          expect(h.effectiveSuit(action.cards.single), suit);
        }
        final attack = lead(h, seen);
        owns(h, attack.cards);
        expect(lead(h, seen).cards, attack.cards);
        final reversed = Hand(
          h.cards.reversed,
          levelRank: h.levelRank,
          trumpSuit: h.trumpSuit,
        );
        expect(lead(reversed, seen).cards, attack.cards);
        expect(followSuit(reversed, trick, seen).cards, action.cards);
        final bottom = selectBottom(h, h.trumpSuit, true);
        owns(h, bottom);
        expect(bottom.length, 8);
        expect(
          bottom.every(
            (c) =>
                c.rank != h.levelRank &&
                !c.isRedFive &&
                !(c.suit == Suit.clubs && c.rank == 14),
          ),
          isTrue,
        );
      }
    },
  );
}
