import 'dart:math';

import 'belote_card.dart';

List<BeloteCard> createDeck() {
  return [
    for (final suit in Suit.values)
      for (final rank in Rank.values) BeloteCard(suit: suit, rank: rank),
  ];
}

List<BeloteCard> createShuffledDeck({Random? random}) {
  return createDeck()..shuffle(random);
}

class InitialDeal {
  const InitialDeal({
    required this.hands,
    required this.turnedCard,
    required this.remainingDeck,
  });

  final List<List<BeloteCard>> hands;
  final BeloteCard turnedCard;
  final List<BeloteCard> remainingDeck;
}

InitialDeal dealInitialHandsAndTurnCard(List<BeloteCard> deck) {
  if (deck.length != 32) {
    throw ArgumentError.value(deck.length, 'deck.length', 'Expected 32 cards.');
  }

  final hands = List.generate(4, (_) => <BeloteCard>[]);
  for (var index = 0; index < 20; index += 1) {
    hands[index % 4].add(deck[index]);
  }

  return InitialDeal(
    hands: hands,
    turnedCard: deck[20],
    remainingDeck: deck.sublist(21),
  );
}

List<List<BeloteCard>> dealFourHands(List<BeloteCard> deck) {
  if (deck.length != 32) {
    throw ArgumentError.value(deck.length, 'deck.length', 'Expected 32 cards.');
  }

  final hands = List.generate(4, (_) => <BeloteCard>[]);
  for (var index = 0; index < deck.length; index += 1) {
    hands[index % 4].add(deck[index]);
  }
  return hands;
}
