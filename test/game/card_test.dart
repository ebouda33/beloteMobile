import 'dart:math';

import 'package:belote_mobile/game/cards/belote_card.dart';
import 'package:belote_mobile/game/cards/deck.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Belote cards', () {
    test('creates a 32-card deck with stable unique identifiers', () {
      final deck = createDeck();

      expect(deck, hasLength(32));
      expect(deck.map((card) => card.id).toSet(), hasLength(32));
    });

    test('contains all suits and ranks', () {
      final deck = createDeck();

      for (final suit in Suit.values) {
        expect(deck.where((card) => card.suit == suit), hasLength(8));
      }

      for (final rank in Rank.values) {
        expect(deck.where((card) => card.rank == rank), hasLength(4));
      }
    });

    test('creates a shuffled deck without changing the cards', () {
      final orderedDeck = createDeck();
      final shuffledDeck = createShuffledDeck(random: Random(1));

      expect(shuffledDeck, hasLength(32));
      expect(shuffledDeck.toSet(), orderedDeck.toSet());
      expect(shuffledDeck, isNot(orderedDeck));
    });

    test('uses expected non-trump card points', () {
      const trumpSuit = Suit.hearts;

      expect(
        const BeloteCard(
          suit: Suit.clubs,
          rank: Rank.ace,
        ).points(trumpSuit: trumpSuit),
        11,
      );
      expect(
        const BeloteCard(
          suit: Suit.clubs,
          rank: Rank.ten,
        ).points(trumpSuit: trumpSuit),
        10,
      );
      expect(
        const BeloteCard(
          suit: Suit.clubs,
          rank: Rank.jack,
        ).points(trumpSuit: trumpSuit),
        2,
      );
      expect(
        const BeloteCard(
          suit: Suit.clubs,
          rank: Rank.nine,
        ).points(trumpSuit: trumpSuit),
        0,
      );
    });

    test('uses expected trump card points', () {
      const trumpSuit = Suit.hearts;

      expect(
        const BeloteCard(
          suit: Suit.hearts,
          rank: Rank.jack,
        ).points(trumpSuit: trumpSuit),
        20,
      );
      expect(
        const BeloteCard(
          suit: Suit.hearts,
          rank: Rank.nine,
        ).points(trumpSuit: trumpSuit),
        14,
      );
      expect(
        const BeloteCard(
          suit: Suit.hearts,
          rank: Rank.ace,
        ).points(trumpSuit: trumpSuit),
        11,
      );
      expect(
        const BeloteCard(
          suit: Suit.hearts,
          rank: Rank.seven,
        ).points(trumpSuit: trumpSuit),
        0,
      );
    });

    test('orders card strength differently for trump and non-trump suits', () {
      const trumpSuit = Suit.hearts;
      const trumpJack = BeloteCard(suit: Suit.hearts, rank: Rank.jack);
      const trumpNine = BeloteCard(suit: Suit.hearts, rank: Rank.nine);
      const nonTrumpAce = BeloteCard(suit: Suit.clubs, rank: Rank.ace);
      const nonTrumpTen = BeloteCard(suit: Suit.clubs, rank: Rank.ten);

      expect(
        trumpJack.strength(trumpSuit: trumpSuit),
        greaterThan(trumpNine.strength(trumpSuit: trumpSuit)),
      );
      expect(
        nonTrumpAce.strength(trumpSuit: trumpSuit),
        greaterThan(nonTrumpTen.strength(trumpSuit: trumpSuit)),
      );
    });
  });

  group('Deck dealing', () {
    test('deals initial five-card hands and turns one card for trump', () {
      final deck = createDeck();
      final initialDeal = dealInitialHandsAndTurnCard(deck);

      expect(initialDeal.hands, hasLength(4));
      for (final hand in initialDeal.hands) {
        expect(hand, hasLength(5));
      }
      expect(initialDeal.turnedCard, deck[20]);
      expect(initialDeal.remainingDeck, hasLength(11));

      final visibleCards = [
        ...initialDeal.hands.expand((hand) => hand),
        initialDeal.turnedCard,
        ...initialDeal.remainingDeck,
      ];
      expect(visibleCards.toSet(), deck.toSet());
    });

    test('deals four hands of eight cards without losing cards', () {
      final deck = createDeck();
      final hands = dealFourHands(deck);

      expect(hands, hasLength(4));
      for (final hand in hands) {
        expect(hand, hasLength(8));
      }

      final dealtCards = hands.expand((hand) => hand).toSet();
      expect(dealtCards, hasLength(32));
      expect(dealtCards.containsAll(deck), isTrue);
    });

    test('rejects decks that do not contain 32 cards', () {
      final deck = createDeck().take(31).toList();

      expect(() => dealFourHands(deck), throwsArgumentError);
    });
  });
}
