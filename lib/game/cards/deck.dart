import 'belote_card.dart';

List<BeloteCard> createDeck() {
  return [
    for (final suit in Suit.values)
      for (final rank in Rank.values) BeloteCard(suit: suit, rank: rank),
  ];
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
