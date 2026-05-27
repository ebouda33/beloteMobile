import 'dart:math';

import 'cards/belote_card.dart';
import 'cards/deck.dart';

enum PlayerSeat { human, leftOpponent, partner, rightOpponent }

enum Team { humanTeam, opponentTeam }

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

extension TeamLabel on Team {
  String get label {
    return switch (this) {
      Team.humanTeam => 'Votre equipe',
      Team.opponentTeam => 'Equipe adverse',
    };
  }
}

enum GamePhase {
  choosingTrump,
  waitingForTrumpTaker,
  allPlayersPassed,
  playingTrick,
  roundComplete,
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
    this.lastCompletedTrick = const [],
    this.lastTrickWinner,
    this.wonTricks = const {Team.humanTeam: [], Team.opponentTeam: []},
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
  final List<PlayedCard> lastCompletedTrick;
  final PlayerSeat? lastTrickWinner;
  final Map<Team, List<List<PlayedCard>>> wonTricks;

  List<BeloteCard> get humanHand => hands[humanSeat] ?? const [];

  int get completedTrickCount {
    return wonTricks.values.fold(
      0,
      (total, teamTricks) => total + teamTricks.length,
    );
  }

  List<BeloteCard> playableCards(PlayerSeat seat) {
    if (phase != GamePhase.playingTrick || currentPlayer != seat) {
      return const [];
    }

    final hand = hands[seat] ?? const [];
    if (currentTrick.isEmpty) {
      return hand;
    }

    final trump = trumpSuit!;
    final requestedSuit = currentTrick.first.card.suit;
    final cardsInRequestedSuit = hand
        .where((card) => card.suit == requestedSuit)
        .toList();
    if (cardsInRequestedSuit.isNotEmpty) {
      if (requestedSuit == trump) {
        final higherTrumps = _cardsThatBeatCurrentWinner(cardsInRequestedSuit);
        if (higherTrumps.isNotEmpty) {
          return higherTrumps;
        }
      }

      return cardsInRequestedSuit;
    }

    if (_isPartnerCurrentlyWinning(seat)) {
      return hand;
    }

    final trumpCards = hand.where((card) => card.suit == trump).toList();
    if (trumpCards.isEmpty) {
      return hand;
    }

    final higherTrumps = _cardsThatBeatCurrentWinner(trumpCards);
    if (higherTrumps.isNotEmpty) {
      return higherTrumps;
    }

    return trumpCards;
  }

  bool _isPartnerCurrentlyWinning(PlayerSeat seat) {
    if (currentTrick.isEmpty) {
      return false;
    }

    return _partnerOf(seat) ==
        _winningPlayedCard(currentTrick, trumpSuit!).player;
  }

  List<BeloteCard> _cardsThatBeatCurrentWinner(List<BeloteCard> cards) {
    final currentWinner = _winningPlayedCard(currentTrick, trumpSuit!).card;
    return cards
        .where(
          (card) => _beats(
            challenger: card,
            currentWinner: currentWinner,
            requestedSuit: currentTrick.first.card.suit,
            trumpSuit: trumpSuit!,
          ),
        )
        .toList();
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
      lastCompletedTrick: lastCompletedTrick,
      lastTrickWinner: lastTrickWinner,
      wonTricks: wonTricks,
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
      wonTricks: wonTricks,
    );
  }

  GameState playAutomaticTurns() {
    var updatedState = this;
    var guard = 0;

    while (updatedState.phase == GamePhase.playingTrick &&
        updatedState.currentPlayer != null &&
        updatedState.currentPlayer != updatedState.humanSeat &&
        updatedState._hasCardsInAnyHand() &&
        guard < 32) {
      final seat = updatedState.currentPlayer!;
      final playableCards = updatedState.playableCards(seat);
      if (playableCards.isEmpty) {
        break;
      }

      updatedState = updatedState.playCard(
        updatedState._chooseAutomaticCard(playableCards),
        seat: seat,
      );
      guard += 1;

      if (updatedState.currentTrick.isEmpty) {
        break;
      }
    }

    return updatedState;
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
    if (!playableCards(seat).contains(card)) {
      throw ArgumentError.value(card, 'card', 'Card is not playable.');
    }

    final updatedHands = {
      for (final playerSeat in PlayerSeat.values)
        playerSeat: [...hands[playerSeat] ?? const <BeloteCard>[]],
    };
    updatedHands[seat]!.remove(card);
    final updatedTrick = [
      ...currentTrick,
      PlayedCard(player: seat, card: card),
    ];
    final trickWinner = updatedTrick.length == PlayerSeat.values.length
        ? _winnerOfTrick(updatedTrick, trumpSuit!)
        : null;
    final updatedWonTricks = trickWinner == null
        ? wonTricks
        : _addWonTrick(wonTricks, _teamOf(trickWinner), updatedTrick);
    final isRoundComplete =
        _completedTrickCount(updatedWonTricks) == PlayerSeat.values.length * 2;
    final nextPhase = isRoundComplete ? GamePhase.roundComplete : phase;

    return GameState(
      hands: updatedHands,
      turnedCard: turnedCard,
      remainingDeck: remainingDeck,
      humanSeat: humanSeat,
      phase: nextPhase,
      trumpSuit: trumpSuit,
      trumpTaker: trumpTaker,
      passedSeats: passedSeats,
      currentPlayer: isRoundComplete
          ? null
          : trickWinner ?? _nextSeatAfter(seat),
      currentTrick: trickWinner == null ? updatedTrick : const [],
      lastCompletedTrick: trickWinner == null
          ? lastCompletedTrick
          : updatedTrick,
      lastTrickWinner: trickWinner ?? lastTrickWinner,
      wonTricks: updatedWonTricks,
    );
  }

  bool _hasCardsInAnyHand() {
    return hands.values.any((hand) => hand.isNotEmpty);
  }

  BeloteCard _chooseAutomaticCard(List<BeloteCard> playableCards) {
    final trump = trumpSuit!;
    final sortedCards = [...playableCards]
      ..sort((first, second) {
        final pointsComparison = first
            .points(trumpSuit: trump)
            .compareTo(second.points(trumpSuit: trump));
        if (pointsComparison != 0) {
          return pointsComparison;
        }

        return first
            .strength(trumpSuit: trump)
            .compareTo(second.strength(trumpSuit: trump));
      });

    return sortedCards.first;
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

PlayerSeat _partnerOf(PlayerSeat seat) {
  return switch (seat) {
    PlayerSeat.human => PlayerSeat.partner,
    PlayerSeat.partner => PlayerSeat.human,
    PlayerSeat.leftOpponent => PlayerSeat.rightOpponent,
    PlayerSeat.rightOpponent => PlayerSeat.leftOpponent,
  };
}

Team _teamOf(PlayerSeat seat) {
  return switch (seat) {
    PlayerSeat.human || PlayerSeat.partner => Team.humanTeam,
    PlayerSeat.leftOpponent || PlayerSeat.rightOpponent => Team.opponentTeam,
  };
}

int _completedTrickCount(Map<Team, List<List<PlayedCard>>> wonTricks) {
  return wonTricks.values.fold(
    0,
    (total, teamTricks) => total + teamTricks.length,
  );
}

Map<Team, List<List<PlayedCard>>> _addWonTrick(
  Map<Team, List<List<PlayedCard>>> wonTricks,
  Team winningTeam,
  List<PlayedCard> trick,
) {
  return {
    for (final team in Team.values)
      team: [
        ...(wonTricks[team] ?? const <List<PlayedCard>>[]),
        if (team == winningTeam) trick,
      ],
  };
}

PlayerSeat _winnerOfTrick(List<PlayedCard> trick, Suit trumpSuit) {
  if (trick.length != PlayerSeat.values.length) {
    throw ArgumentError.value(
      trick.length,
      'trick.length',
      'Expected 4 cards.',
    );
  }

  return _winningPlayedCard(trick, trumpSuit).player;
}

PlayedCard _winningPlayedCard(List<PlayedCard> trick, Suit trumpSuit) {
  final requestedSuit = trick.first.card.suit;
  var winningCard = trick.first;
  for (final playedCard in trick.skip(1)) {
    if (_beats(
      challenger: playedCard.card,
      currentWinner: winningCard.card,
      requestedSuit: requestedSuit,
      trumpSuit: trumpSuit,
    )) {
      winningCard = playedCard;
    }
  }

  return winningCard;
}

bool _beats({
  required BeloteCard challenger,
  required BeloteCard currentWinner,
  required Suit requestedSuit,
  required Suit trumpSuit,
}) {
  if (challenger.suit == currentWinner.suit) {
    return challenger.strength(trumpSuit: trumpSuit) >
        currentWinner.strength(trumpSuit: trumpSuit);
  }

  if (challenger.suit == trumpSuit && currentWinner.suit != trumpSuit) {
    return true;
  }

  if (currentWinner.suit == trumpSuit) {
    return false;
  }

  return challenger.suit == requestedSuit &&
      currentWinner.suit != requestedSuit;
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
