import assert from 'node:assert/strict';
import test from 'node:test';
import { is510K, isPair, isTractor, isTrump, points } from '../utils/cards.ts';
import type { Card, Trump } from '../utils/cards.ts';

const clubs = (rank: Card['rank'], copy: Card['copy']): Card => ({
  suit: 'clubs',
  rank,
  copy
});
const trump: Trump = { suit: 'spades', level: 2 };

test('red five and level cards are trump while ordinary off-suit cards are not', () => {
  assert.equal(isTrump({ suit: 'hearts', rank: 5, copy: 0 }, trump), true);
  assert.equal(isTrump({ suit: 'diamonds', rank: 2, copy: 0 }, trump), true);
  assert.equal(isTrump({ suit: 'diamonds', rank: 3, copy: 0 }, trump), false);
  assert.equal(isTrump({ suit: 'hearts', rank: 5, copy: 0 }, { suit: 'none', level: 2 }), false);
});

test('pair, tractor and 510K classification handles duplicate copies and level breaks', () => {
  assert.equal(isPair([clubs(7, 0), clubs(7, 1)]), true);
  assert.equal(isPair([clubs(7, 0), clubs(7, 0)]), false);
  assert.equal(isTractor([clubs(6, 0), clubs(6, 1), clubs(7, 0), clubs(7, 1)], trump), true);
  assert.equal(isTractor([clubs(2, 0), clubs(2, 1), clubs(3, 0), clubs(3, 1)], trump), false);
  assert.equal(is510K([clubs(5, 0), clubs(10, 0), clubs(13, 0)]), true);
  assert.equal(is510K([clubs(5, 0), clubs(10, 0), clubs(12, 0)]), false);
});

test('points count fives, tens and kings', () => {
  assert.equal(points([clubs(5, 0), clubs(10, 0), clubs(13, 1), clubs(11, 0)]), 25);
});
