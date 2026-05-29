import 'dart:math';

import 'cards/belote_card.dart';
import 'cards/deck.dart';

const targetScore = 501;

enum PlayerSeat { human, leftOpponent, partner, rightOpponent }

enum Team { humanTeam, opponentTeam }

enum AiLevel { debutant, expert }

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
    this.aiLevel = AiLevel.debutant,
    this.phase = GamePhase.choosingTrump,
    this.biddingRound = 1,
    this.biddingStarterSeat = PlayerSeat.human,
    this.trumpSuit,
    this.trumpTaker,
    this.passedSeats = const {},
    this.currentPlayer,
    this.currentTrick = const [],
    this.lastCompletedTrick = const [],
    this.lastTrickWinner,
    this.wonTricks = const {Team.humanTeam: [], Team.opponentTeam: []},
    this.roundBonusPoints = const {Team.humanTeam: 0, Team.opponentTeam: 0},
    this.beloteTeam,
    this.beloteRanksPlayed = const {},
    this.gameScore = const {Team.humanTeam: 0, Team.opponentTeam: 0},
  });

  final Map<PlayerSeat, List<BeloteCard>> hands;
  final BeloteCard turnedCard;
  final List<BeloteCard> remainingDeck;
  final PlayerSeat humanSeat;
  final AiLevel aiLevel;
  final GamePhase phase;
  final int biddingRound;
  final PlayerSeat biddingStarterSeat;
  final Suit? trumpSuit;
  final PlayerSeat? trumpTaker;
  final Set<PlayerSeat> passedSeats;
  final PlayerSeat? currentPlayer;
  final List<PlayedCard> currentTrick;
  final List<PlayedCard> lastCompletedTrick;
  final PlayerSeat? lastTrickWinner;
  final Map<Team, List<List<PlayedCard>>> wonTricks;
  final Map<Team, int> roundBonusPoints;
  final Team? beloteTeam;
  final Set<Rank> beloteRanksPlayed;
  final Map<Team, int> gameScore;

  List<BeloteCard> get humanHand => hands[humanSeat] ?? const [];

  List<Suit> get availableTrumpSuits {
    if (biddingRound == 1) {
      return [turnedCard.suit];
    }

    return [
      for (final suit in Suit.values)
        if (suit != turnedCard.suit) suit,
    ];
  }

  bool get isGameComplete {
    return gameScore.values.any((score) => score >= targetScore);
  }

  Team? get winningTeam {
    if (!isGameComplete) {
      return null;
    }

    final humanScore = gameScore[Team.humanTeam] ?? 0;
    final opponentScore = gameScore[Team.opponentTeam] ?? 0;
    if (humanScore == opponentScore) {
      final humanRoundScore = roundScore[Team.humanTeam] ?? 0;
      final opponentRoundScore = roundScore[Team.opponentTeam] ?? 0;
      if (humanRoundScore == opponentRoundScore) {
        return Team.humanTeam;
      }

      return humanRoundScore > opponentRoundScore
          ? Team.humanTeam
          : Team.opponentTeam;
    }

    return humanScore > opponentScore ? Team.humanTeam : Team.opponentTeam;
  }

  Map<Team, int> get roundPoints {
    final trump = trumpSuit;
    if (trump == null) {
      return const {Team.humanTeam: 0, Team.opponentTeam: 0};
    }

    return _roundPointsFor(
      trumpSuit: trump,
      lastTrickWinner: lastTrickWinner,
      wonTricks: wonTricks,
    );
  }

  Team? get takerTeam {
    final taker = trumpTaker;
    return taker == null ? null : _teamOf(taker);
  }

  bool? get isContractFulfilled {
    if (phase != GamePhase.roundComplete || takerTeam == null) {
      return null;
    }

    return (roundPoints[takerTeam!] ?? 0) >= 82;
  }

  Team? get capotTeam {
    return _capotTeamFor(phase: phase, wonTricks: wonTricks);
  }

  Team? get beloteBonusTeam {
    for (final team in Team.values) {
      if ((roundBonusPoints[team] ?? 0) > 0) {
        return team;
      }
    }

    return null;
  }

  Map<Team, int> get roundScore {
    return _addScores(
      _roundScoreFor(
        phase: phase,
        trumpSuit: trumpSuit,
        trumpTaker: trumpTaker,
        lastTrickWinner: lastTrickWinner,
        wonTricks: wonTricks,
      ),
      roundBonusPoints,
    );
  }

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
    if (currentPlayer != null && currentPlayer != seat) {
      throw StateError('It is not this player turn.');
    }

    final updatedPassedSeats = {...passedSeats, seat};
    if (updatedPassedSeats.length == PlayerSeat.values.length) {
      if (biddingRound == 1) {
        return GameState(
          hands: hands,
          turnedCard: turnedCard,
          remainingDeck: remainingDeck,
          humanSeat: humanSeat,
          aiLevel: aiLevel,
          phase: GamePhase.choosingTrump,
          biddingRound: 2,
          biddingStarterSeat: biddingStarterSeat,
          trumpSuit: trumpSuit,
          trumpTaker: trumpTaker,
          passedSeats: const {},
          currentPlayer: biddingStarterSeat,
          currentTrick: currentTrick,
          lastCompletedTrick: lastCompletedTrick,
          lastTrickWinner: lastTrickWinner,
          wonTricks: wonTricks,
          roundBonusPoints: roundBonusPoints,
          beloteTeam: beloteTeam,
          beloteRanksPlayed: beloteRanksPlayed,
          gameScore: gameScore,
        );
      }

      return _createRoundGameState(
        gameScore: gameScore,
        humanSeat: humanSeat,
        biddingStarterSeat: _nextSeatAfter(biddingStarterSeat),
        aiLevel: aiLevel,
      );
    }

    return GameState(
      hands: hands,
      turnedCard: turnedCard,
      remainingDeck: remainingDeck,
      humanSeat: humanSeat,
      aiLevel: aiLevel,
      phase: GamePhase.waitingForTrumpTaker,
      biddingRound: biddingRound,
      biddingStarterSeat: biddingStarterSeat,
      trumpSuit: trumpSuit,
      trumpTaker: trumpTaker,
      passedSeats: updatedPassedSeats,
      currentPlayer: _nextSeatAfter(seat),
      currentTrick: currentTrick,
      lastCompletedTrick: lastCompletedTrick,
      lastTrickWinner: lastTrickWinner,
      wonTricks: wonTricks,
      roundBonusPoints: roundBonusPoints,
      beloteTeam: beloteTeam,
      beloteRanksPlayed: beloteRanksPlayed,
      gameScore: gameScore,
    );
  }

  GameState passRemainingPlayers() {
    return resolveAutomaticTrumpTurns();
  }

  GameState resolveAutomaticTrumpTurns() {
    var updatedState = this;
    var guard = 0;

    while (updatedState.phase == GamePhase.choosingTrump ||
        updatedState.phase == GamePhase.waitingForTrumpTaker) {
      final currentPlayer = updatedState.currentPlayer;
      if (currentPlayer == null || currentPlayer == updatedState.humanSeat) {
        break;
      }

      final automaticTrumpSuit = _automaticTrumpSuitFor(
        updatedState,
        currentPlayer,
      );
      updatedState = automaticTrumpSuit == null
          ? updatedState.passTrump(seat: currentPlayer)
          : updatedState.chooseTrump(
              taker: currentPlayer,
              trumpSuit: automaticTrumpSuit,
            );

      guard += 1;
      if (guard >= PlayerSeat.values.length * 4) {
        break;
      }
    }

    return updatedState;
  }

  GameState chooseTrump({
    PlayerSeat taker = PlayerSeat.human,
    Suit? trumpSuit,
  }) {
    if (phase != GamePhase.choosingTrump &&
        phase != GamePhase.waitingForTrumpTaker) {
      throw StateError('Trump has already been selected.');
    }
    if (passedSeats.contains(taker)) {
      throw StateError('A player who passed cannot take this trump card.');
    }
    if (currentPlayer != null && currentPlayer != taker) {
      throw StateError('It is not this player turn.');
    }

    final selectedTrumpSuit = trumpSuit ?? turnedCard.suit;
    if (!availableTrumpSuits.contains(selectedTrumpSuit)) {
      throw ArgumentError.value(
        selectedTrumpSuit,
        'trumpSuit',
        'This suit cannot be selected in the current bidding round.',
      );
    }

    return GameState(
      hands: _sortHandsForTrump(
        _completeHandsAfterTrumpTaken(taker),
        selectedTrumpSuit,
      ),
      turnedCard: turnedCard,
      remainingDeck: const [],
      humanSeat: humanSeat,
      aiLevel: aiLevel,
      phase: GamePhase.playingTrick,
      biddingRound: biddingRound,
      biddingStarterSeat: biddingStarterSeat,
      trumpSuit: selectedTrumpSuit,
      trumpTaker: taker,
      passedSeats: passedSeats,
      currentPlayer: taker,
      wonTricks: wonTricks,
      roundBonusPoints: roundBonusPoints,
      beloteTeam: beloteTeam,
      beloteRanksPlayed: beloteRanksPlayed,
      gameScore: gameScore,
    );
  }

  GameState startNextRound({Random? random}) {
    if (phase != GamePhase.roundComplete &&
        phase != GamePhase.allPlayersPassed) {
      throw StateError(
        'A new round can only start after the current round ends.',
      );
    }
    if (isGameComplete) {
      throw StateError('The game is already complete.');
    }

    return _createRoundGameState(
      random: random,
      gameScore: gameScore,
      humanSeat: humanSeat,
      biddingStarterSeat: _nextSeatAfter(biddingStarterSeat),
      aiLevel: aiLevel,
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
    final updatedRoundBonusPoints = {
      for (final team in Team.values) team: roundBonusPoints[team] ?? 0,
    };
    var updatedBeloteTeam = beloteTeam;
    var updatedBeloteRanksPlayed = {...beloteRanksPlayed};
    final seatTeam = _teamOf(seat);
    final trump = trumpSuit!;
    if (card.suit == trump &&
        (card.rank == Rank.king || card.rank == Rank.queen)) {
      final otherRank = card.rank == Rank.king ? Rank.queen : Rank.king;
      final otherTrumpMarriageCard = BeloteCard(suit: trump, rank: otherRank);
      if (updatedBeloteTeam == seatTeam &&
          updatedBeloteRanksPlayed.contains(otherRank)) {
        updatedRoundBonusPoints[seatTeam] =
            (updatedRoundBonusPoints[seatTeam] ?? 0) + 20;
        updatedBeloteTeam = null;
        updatedBeloteRanksPlayed = {};
      } else if (playerHand.contains(otherTrumpMarriageCard)) {
        updatedBeloteTeam = seatTeam;
        updatedBeloteRanksPlayed = {card.rank};
      }
    }
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
    final updatedGameScore = isRoundComplete
        ? _addScores(
            gameScore,
            _roundScoreFor(
              phase: nextPhase,
              trumpSuit: trumpSuit!,
              trumpTaker: trumpTaker,
              lastTrickWinner: trickWinner,
              wonTricks: updatedWonTricks,
            ),
          )
        : gameScore;

    return GameState(
      hands: updatedHands,
      turnedCard: turnedCard,
      remainingDeck: remainingDeck,
      humanSeat: humanSeat,
      aiLevel: aiLevel,
      phase: nextPhase,
      biddingRound: biddingRound,
      biddingStarterSeat: biddingStarterSeat,
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
      roundBonusPoints: updatedRoundBonusPoints,
      beloteTeam: updatedBeloteTeam,
      beloteRanksPlayed: updatedBeloteRanksPlayed,
      gameScore: updatedGameScore,
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

  Map<PlayerSeat, List<BeloteCard>> _sortHandsForTrump(
    Map<PlayerSeat, List<BeloteCard>> hands,
    Suit trumpSuit,
  ) {
    return {
      for (final seat in PlayerSeat.values)
        seat: (() {
          final sortedHand = [...(hands[seat] ?? const <BeloteCard>[])];
          sortedHand.sort((first, second) {
            final suitComparison = _suitOrder(
              first.suit,
              trumpSuit,
            ).compareTo(_suitOrder(second.suit, trumpSuit));
            if (suitComparison != 0) {
              return suitComparison;
            }

            return second
                .strength(trumpSuit: trumpSuit)
                .compareTo(first.strength(trumpSuit: trumpSuit));
          });
          return sortedHand;
        })(),
    };
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

Team _opponentOf(Team team) {
  return switch (team) {
    Team.humanTeam => Team.opponentTeam,
    Team.opponentTeam => Team.humanTeam,
  };
}

int _suitOrder(Suit suit, Suit trumpSuit) {
  if (suit == trumpSuit) {
    return 0;
  }

  return 1 + Suit.values.indexOf(suit);
}

Map<Team, int> _roundScoreFor({
  required GamePhase phase,
  required Suit? trumpSuit,
  required PlayerSeat? trumpTaker,
  required PlayerSeat? lastTrickWinner,
  required Map<Team, List<List<PlayedCard>>> wonTricks,
}) {
  if (phase != GamePhase.roundComplete || trumpSuit == null) {
    return const {Team.humanTeam: 0, Team.opponentTeam: 0};
  }

  final capotWinner = _capotTeamFor(phase: phase, wonTricks: wonTricks);
  if (capotWinner != null) {
    return {
      for (final team in Team.values) team: team == capotWinner ? 252 : 0,
    };
  }

  final roundPoints = _roundPointsFor(
    trumpSuit: trumpSuit,
    lastTrickWinner: lastTrickWinner,
    wonTricks: wonTricks,
  );
  final takerTeam = trumpTaker == null ? null : _teamOf(trumpTaker);
  if (takerTeam == null || (roundPoints[takerTeam] ?? 0) >= 82) {
    return roundPoints;
  }

  final defendingTeam = _opponentOf(takerTeam);
  return {
    for (final team in Team.values) team: team == defendingTeam ? 162 : 0,
  };
}

Map<Team, int> _roundPointsFor({
  required Suit trumpSuit,
  required PlayerSeat? lastTrickWinner,
  required Map<Team, List<List<PlayedCard>>> wonTricks,
}) {
  return {
    for (final team in Team.values)
      team:
          _pointsForWonTricks(wonTricks[team] ?? const [], trumpSuit) +
          (lastTrickWinner != null && _teamOf(lastTrickWinner) == team
              ? 10
              : 0),
  };
}

Team? _capotTeamFor({
  required GamePhase phase,
  required Map<Team, List<List<PlayedCard>>> wonTricks,
}) {
  if (phase != GamePhase.roundComplete) {
    return null;
  }

  for (final team in Team.values) {
    if ((wonTricks[team]?.length ?? 0) == PlayerSeat.values.length * 2) {
      return team;
    }
  }

  return null;
}

Map<Team, int> _addScores(Map<Team, int> gameScore, Map<Team, int> roundScore) {
  return {
    for (final team in Team.values)
      team: (gameScore[team] ?? 0) + (roundScore[team] ?? 0),
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

int _pointsForWonTricks(List<List<PlayedCard>> tricks, Suit trumpSuit) {
  return tricks.expand((trick) => trick).fold(0, (total, playedCard) {
    return total + playedCard.card.points(trumpSuit: trumpSuit);
  });
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
  return _createRoundGameState(random: random);
}

GameState _createRoundGameState({
  Random? random,
  Map<Team, int> gameScore = const {Team.humanTeam: 0, Team.opponentTeam: 0},
  PlayerSeat humanSeat = PlayerSeat.human,
  PlayerSeat biddingStarterSeat = PlayerSeat.human,
  AiLevel aiLevel = AiLevel.debutant,
}) {
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
    humanSeat: humanSeat,
    aiLevel: aiLevel,
    biddingRound: 1,
    biddingStarterSeat: biddingStarterSeat,
    currentPlayer: biddingStarterSeat,
    gameScore: gameScore,
  );
}

Suit? _automaticTrumpSuitFor(GameState gameState, PlayerSeat seat) {
  switch (gameState.aiLevel) {
    case AiLevel.debutant:
      return _debutantTrumpSuitFor(gameState, seat);
    case AiLevel.expert:
      return _debutantTrumpSuitFor(gameState, seat);
  }
}

Suit? _debutantTrumpSuitFor(GameState gameState, PlayerSeat seat) {
  final availableSuits = gameState.availableTrumpSuits;
  if (availableSuits.isEmpty) {
    return null;
  }

  final prospectiveHand = [
    ...(gameState.hands[seat] ?? const <BeloteCard>[]),
    gameState.turnedCard,
  ];

  final rankedSuitScores = [
    for (final suit in availableSuits)
      MapEntry(suit, _debutantTrumpSuitScore(prospectiveHand, suit)),
  ]..sort((first, second) => second.value.compareTo(first.value));

  final bestScore = rankedSuitScores.first.value;
  final takeThreshold = gameState.biddingRound == 1 ? 24 : 17;
  if (bestScore < takeThreshold) {
    return null;
  }

  return rankedSuitScores.first.key;
}

int _debutantTrumpSuitScore(List<BeloteCard> hand, Suit trumpSuit) {
  var score = 0;
  var trumpCardCount = 0;
  var hasJack = false;
  var hasNine = false;

  for (final card in hand.where((card) => card.suit == trumpSuit)) {
    trumpCardCount += 1;
    score += card.strength(trumpSuit: trumpSuit);
    hasJack = hasJack || card.rank == Rank.jack;
    hasNine = hasNine || card.rank == Rank.nine;
  }

  score += trumpCardCount * 2;
  if (trumpCardCount >= 4) {
    score += 4;
  }
  if (hasJack) {
    score += 4;
  }
  if (hasNine) {
    score += 3;
  }

  return score;
}
