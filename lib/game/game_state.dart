import 'dart:math';

import 'cards/belote_card.dart';
import 'cards/deck.dart';

enum PlayerSeat { human, leftOpponent, partner, rightOpponent }

enum GamePhase { choosingTrump, waitingForTrumpTaker, playingTrick }

class GameState {
  const GameState({
    required this.hands,
    required this.turnedCard,
    required this.remainingDeck,
    this.humanSeat = PlayerSeat.human,
    this.phase = GamePhase.choosingTrump,
    this.trumpSuit,
  });

  final Map<PlayerSeat, List<BeloteCard>> hands;
  final BeloteCard turnedCard;
  final List<BeloteCard> remainingDeck;
  final PlayerSeat humanSeat;
  final GamePhase phase;
  final Suit? trumpSuit;

  List<BeloteCard> get humanHand => hands[humanSeat] ?? const [];

  GameState passTrump() {
    if (phase != GamePhase.choosingTrump) {
      throw StateError('Trump choice is no longer available.');
    }

    return GameState(
      hands: hands,
      turnedCard: turnedCard,
      remainingDeck: remainingDeck,
      humanSeat: humanSeat,
      phase: GamePhase.waitingForTrumpTaker,
      trumpSuit: trumpSuit,
    );
  }

  GameState chooseTrump() {
    if (phase != GamePhase.choosingTrump) {
      throw StateError('Trump has already been selected.');
    }

    return GameState(
      hands: hands,
      turnedCard: turnedCard,
      remainingDeck: remainingDeck,
      humanSeat: humanSeat,
      phase: GamePhase.playingTrick,
      trumpSuit: turnedCard.suit,
    );
  }
}

GameState createInitialGameState({Random? random}) {
  final initialDeal = dealInitialHandsAndTurnCard(
    createShuffledDeck(random: random),
  );

  return GameState(
    hands: {
      for (var index = 0; index < PlayerSeat.values.length; index += 1)
        PlayerSeat.values[index]: initialDeal.hands[index],
    },
    turnedCard: initialDeal.turnedCard,
    remainingDeck: initialDeal.remainingDeck,
  );
}
