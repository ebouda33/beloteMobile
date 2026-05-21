import 'dart:math';

import 'cards/belote_card.dart';
import 'cards/deck.dart';

enum PlayerSeat { human, leftOpponent, partner, rightOpponent }

enum GamePhase { choosingTrump }

class GameState {
  const GameState({
    required this.hands,
    this.humanSeat = PlayerSeat.human,
    this.phase = GamePhase.choosingTrump,
    this.trumpSuit,
  });

  final Map<PlayerSeat, List<BeloteCard>> hands;
  final PlayerSeat humanSeat;
  final GamePhase phase;
  final Suit? trumpSuit;

  List<BeloteCard> get humanHand => hands[humanSeat] ?? const [];
}

GameState createInitialGameState({Random? random}) {
  final dealtHands = dealFourHands(createShuffledDeck(random: random));

  return GameState(
    hands: {
      for (var index = 0; index < PlayerSeat.values.length; index += 1)
        PlayerSeat.values[index]: dealtHands[index],
    },
  );
}
