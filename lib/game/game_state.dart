import 'dart:math';

import 'cards/belote_card.dart';
import 'cards/deck.dart';

enum PlayerSeat { human, leftOpponent, partner, rightOpponent }

extension PlayerSeatLabel on PlayerSeat {
  String get label {
    return switch (this) {
      PlayerSeat.human => 'Vous',
      PlayerSeat.leftOpponent => 'Adversaire gauche',
      PlayerSeat.partner => 'Partenaire',
      PlayerSeat.rightOpponent => 'Adversaire droite',
    };
  }
}

enum GamePhase {
  choosingTrump,
  waitingForTrumpTaker,
  allPlayersPassed,
  playingTrick,
}

class PlayedCard {
  const PlayedCard({required this.player, required this.card});

  final PlayerSeat player;
  final BeloteCard card;
}

class GameState {
  const GameState({
    required this.hands,
    required this.turnedCard,
    required this.remainingDeck,
    this.humanSeat = PlayerSeat.human,
    this.phase = GamePhase.choosingTrump,
    this.trumpSuit,
    this.trumpTaker,
    this.passedSeats = const {},
    this.currentPlayer,
    this.currentTrick = const [],
  });

  final Map<PlayerSeat, List<BeloteCard>> hands;
  final BeloteCard turnedCard;
  final List<BeloteCard> remainingDeck;
  final PlayerSeat humanSeat;
  final GamePhase phase;
  final Suit? trumpSuit;
  final PlayerSeat? trumpTaker;
  final Set<PlayerSeat> passedSeats;
  final PlayerSeat? currentPlayer;
  final List<PlayedCard> currentTrick;

  List<BeloteCard> get humanHand => hands[humanSeat] ?? const [];

  List<BeloteCard> playableCards(PlayerSeat seat) {
    if (phase != GamePhase.playingTrick || currentPlayer != seat) {
      return const [];
    }

    return hands[seat] ?? const [];
  }

  GameState passTrump({PlayerSeat seat = PlayerSeat.human}) {
    if (phase != GamePhase.choosingTrump &&
        phase != GamePhase.waitingForTrumpTaker) {
      throw StateError('Trump choice is no longer available.');
    }

    final updatedPassedSeats = {...passedSeats, seat};
    final nextPhase = updatedPassedSeats.length == PlayerSeat.values.length
        ? GamePhase.allPlayersPassed
        : GamePhase.waitingForTrumpTaker;

    return GameState(
      hands: hands,
      turnedCard: turnedCard,
      remainingDeck: remainingDeck,
      humanSeat: humanSeat,
      phase: nextPhase,
      trumpSuit: trumpSuit,
      trumpTaker: trumpTaker,
      passedSeats: updatedPassedSeats,
      currentPlayer: currentPlayer,
      currentTrick: currentTrick,
    );
  }

  GameState passRemainingPlayers() {
    var updatedState = this;
    for (final seat in PlayerSeat.values) {
      if (updatedState.phase == GamePhase.allPlayersPassed ||
          updatedState.passedSeats.contains(seat)) {
        continue;
      }

      updatedState = updatedState.passTrump(seat: seat);
    }

    return updatedState;
  }

  GameState chooseTrump({PlayerSeat taker = PlayerSeat.human}) {
    if (phase != GamePhase.choosingTrump &&
        phase != GamePhase.waitingForTrumpTaker) {
      throw StateError('Trump has already been selected.');
    }
    if (passedSeats.contains(taker)) {
      throw StateError('A player who passed cannot take this trump card.');
    }

    return GameState(
      hands: _completeHandsAfterTrumpTaken(taker),
      turnedCard: turnedCard,
      remainingDeck: const [],
      humanSeat: humanSeat,
      phase: GamePhase.playingTrick,
      trumpSuit: turnedCard.suit,
      trumpTaker: taker,
      passedSeats: passedSeats,
      currentPlayer: humanSeat,
    );
  }

  GameState playCard(BeloteCard card, {PlayerSeat seat = PlayerSeat.human}) {
    if (phase != GamePhase.playingTrick) {
      throw StateError('Cards cannot be played before the trick phase.');
    }
    if (currentPlayer != seat) {
      throw StateError('It is not this player turn.');
    }

    final playerHand = hands[seat] ?? const [];
    if (!playerHand.contains(card)) {
      throw ArgumentError.value(card, 'card', 'Card is not in player hand.');
    }

    final updatedHands = {
      for (final playerSeat in PlayerSeat.values)
        playerSeat: [...hands[playerSeat] ?? const <BeloteCard>[]],
    };
    updatedHands[seat]!.remove(card);

    return GameState(
      hands: updatedHands,
      turnedCard: turnedCard,
      remainingDeck: remainingDeck,
      humanSeat: humanSeat,
      phase: phase,
      trumpSuit: trumpSuit,
      trumpTaker: trumpTaker,
      passedSeats: passedSeats,
      currentPlayer: _nextSeatAfter(seat),
      currentTrick: [
        ...currentTrick,
        PlayedCard(player: seat, card: card),
      ],
    );
  }

  Map<PlayerSeat, List<BeloteCard>> _completeHandsAfterTrumpTaken(
    PlayerSeat taker,
  ) {
    final completedHands = {
      for (final seat in PlayerSeat.values)
        seat: [...hands[seat] ?? const <BeloteCard>[]],
    };
    completedHands[taker]!.add(turnedCard);

    var deckIndex = 0;
    for (final seat in PlayerSeat.values) {
      final cardsToDeal = seat == taker ? 2 : 3;
      completedHands[seat]!.addAll(
        remainingDeck.sublist(deckIndex, deckIndex + cardsToDeal),
      );
      deckIndex += cardsToDeal;
    }

    return completedHands;
  }
}

PlayerSeat _nextSeatAfter(PlayerSeat seat) {
  final nextIndex =
      (PlayerSeat.values.indexOf(seat) + 1) % PlayerSeat.values.length;
  return PlayerSeat.values[nextIndex];
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
