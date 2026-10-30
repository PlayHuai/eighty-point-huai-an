export type Suit = 'clubs' | 'diamonds' | 'hearts' | 'spades' | 'none';
export type Rank = 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16;

export interface Card {
  suit: Suit;
  rank: Rank;
  copy: 0 | 1;
}

export interface Trump {
  suit: Suit | 'none';
  level: Rank;
}

export function isValidCard(card: Card): boolean {
  if (card.copy !== 0 && card.copy !== 1) {
    return false;
  }
  if (card.rank === 15 || card.rank === 16) {
    return card.suit === 'none';
  }
  return card.rank >= 2 && card.rank <= 14 &&
    ['clubs', 'diamonds', 'hearts', 'spades'].includes(card.suit);
}

export function isTrump(card: Card, trump: Trump): boolean {
  return isValidCard(card) && card.rank >= 2 && card.rank <= 16 &&
    (card.rank === 15 || card.rank === 16 || card.rank === trump.level ||
      (trump.suit !== 'none' &&
        (card.suit === trump.suit || (card.suit === 'hearts' && card.rank === 5))));
}

export function isPair(cards: Card[]): boolean {
  return cards.length === 2 && cards.every(isValidCard) &&
    cards[0].suit === cards[1].suit && cards[0].rank === cards[1].rank &&
    cards[0].copy !== cards[1].copy;
}

export function is510K(cards: Card[]): boolean {
  return cards.length === 3 && cards.every(isValidCard) &&
    cards.every((card) => card.suit === cards[0].suit) &&
    new Set(cards.map((card) => card.rank)).size === 3 &&
    [5, 10, 13].every((rank) => cards.some((card) => card.rank === rank));
}

export function isTractor(cards: Card[], trump: Trump): boolean {
  if (cards.length < 4 || cards.length % 2 !== 0 || !cards.every(isValidCard)) {
    return false;
  }
  const suit = cards[0].suit;
  if (cards.some((card) => card.suit !== suit || card.rank > 14)) {
    return false;
  }
  const ranks = new Map<number, number>();
  const copies = new Set<string>();
  for (const card of cards) {
    const id = `${card.rank}:${card.copy}`;
    if (copies.has(id)) {
      return false;
    }
    copies.add(id);
    ranks.set(card.rank, (ranks.get(card.rank) ?? 0) + 1);
  }
  const orderedRanks = [...ranks.keys()].sort((a, b) => a - b);
  return ranks.size * 2 === cards.length &&
    orderedRanks.every((rank, index) =>
      ranks.get(rank) === 2 && rank !== trump.level &&
      (index === 0 || rank === orderedRanks[index - 1] + 1));
}

export function points(cards: Card[]): number {
  if (!cards.every(isValidCard)) {
    throw new Error('invalid card');
  }
  return cards.reduce((total, card) => total +
    (card.rank === 5 ? 5 : card.rank === 10 || card.rank === 13 ? 10 : 0), 0);
}
