import 'dart:math';

import 'package:belote_mobile/game/cards/belote_card.dart';
import 'package:belote_mobile/game/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Game state', () {
    test('creates an initial game state with four five-card hands', () {
      final gameState = createInitialGameState(random: Random(1));

      expect(gameState.hands, hasLength(4));
      for (final seat in PlayerSeat.values) {
        expect(gameState.hands[seat], hasLength(5));
      }

      final visibleCards = [
        ...gameState.hands.values.expand((hand) => hand),
        gameState.turnedCard,
        ...gameState.remainingDeck,
      ];
      expect(visibleCards.toSet(), hasLength(32));
    });

    test('starts with a turned card and waits for trump selection', () {
      final gameState = createInitialGameState(random: Random(1));

      expect(gameState.humanSeat, PlayerSeat.human);
      expect(gameState.humanHand, gameState.hands[PlayerSeat.human]);
      expect(gameState.turnedCard, isNotNull);
      expect(gameState.remainingDeck, hasLength(11));
      expect(gameState.phase, GamePhase.choosingTrump);
      expect(gameState.trumpSuit, isNull);
    });

    test(
      'selects the turned card suit as trump and moves to first trick phase',
      () {
        final gameState = createInitialGameState(random: Random(1));

        final updatedState = gameState.chooseTrump();

        expect(updatedState.trumpSuit, gameState.turnedCard.suit);
        expect(updatedState.phase, GamePhase.playingTrick);
        expect(updatedState.trumpTaker, PlayerSeat.human);
        expect(updatedState.currentPlayer, PlayerSeat.human);
        expect(updatedState.currentTrick, isEmpty);
        expect(updatedState.remainingDeck, isEmpty);
        for (final seat in PlayerSeat.values) {
          expect(updatedState.hands[seat], hasLength(8));
        }
        expect(updatedState.humanHand, contains(gameState.turnedCard));

        final dealtCards = updatedState.hands.values.expand((hand) => hand);
        expect(dealtCards.toSet(), hasLength(32));
      },
    );

    test('can select trump for another player after earlier passes', () {
      final gameState = createInitialGameState(
        random: Random(1),
      ).passTrump().passTrump(seat: PlayerSeat.leftOpponent);

      final updatedState = gameState.chooseTrump(taker: PlayerSeat.partner);

      expect(updatedState.trumpSuit, gameState.turnedCard.suit);
      expect(updatedState.trumpTaker, PlayerSeat.partner);
      expect(updatedState.phase, GamePhase.playingTrick);
      expect(updatedState.currentPlayer, PlayerSeat.human);
      expect(
        updatedState.hands[PlayerSeat.partner],
        contains(gameState.turnedCard),
      );
      for (final seat in PlayerSeat.values) {
        expect(updatedState.hands[seat], hasLength(8));
      }
    });

    test('rejects trump selection after trump is already selected', () {
      final gameState = createInitialGameState(random: Random(1)).chooseTrump();

      expect(gameState.chooseTrump, throwsStateError);
    });

    test('rejects trump selection by a player who already passed', () {
      final gameState = createInitialGameState(random: Random(1)).passTrump();

      expect(gameState.chooseTrump, throwsStateError);
    });

    test('passes on the turned card without selecting trump', () {
      final gameState = createInitialGameState(random: Random(1));

      final updatedState = gameState.passTrump();

      expect(updatedState.trumpSuit, isNull);
      expect(updatedState.phase, GamePhase.waitingForTrumpTaker);
      expect(updatedState.hands, gameState.hands);
      expect(updatedState.turnedCard, gameState.turnedCard);
      expect(updatedState.passedSeats, {PlayerSeat.human});
    });

    test('moves to all players passed when every player rejects trump', () {
      final gameState = createInitialGameState(random: Random(1))
          .passTrump()
          .passTrump(seat: PlayerSeat.leftOpponent)
          .passTrump(seat: PlayerSeat.partner)
          .passTrump(seat: PlayerSeat.rightOpponent);

      expect(gameState.trumpSuit, isNull);
      expect(gameState.trumpTaker, isNull);
      expect(gameState.phase, GamePhase.allPlayersPassed);
      expect(gameState.passedSeats, PlayerSeat.values.toSet());
    });

    test('passes every remaining player for the current trump card', () {
      final gameState = createInitialGameState(
        random: Random(1),
      ).passTrump().passRemainingPlayers();

      expect(gameState.trumpSuit, isNull);
      expect(gameState.trumpTaker, isNull);
      expect(gameState.phase, GamePhase.allPlayersPassed);
      expect(gameState.passedSeats, PlayerSeat.values.toSet());
    });

    test('rejects passing after trump is already selected', () {
      final gameState = createInitialGameState(random: Random(1)).chooseTrump();

      expect(gameState.passTrump, throwsStateError);
    });

    test('plays a card for the current player and advances the turn', () {
      final gameState = createInitialGameState(random: Random(1)).chooseTrump();
      final card = gameState.humanHand.first;

      final updatedState = gameState.playCard(card);

      expect(updatedState.humanHand, hasLength(7));
      expect(updatedState.humanHand, isNot(contains(card)));
      expect(updatedState.currentTrick, hasLength(1));
      expect(updatedState.currentTrick.single.player, PlayerSeat.human);
      expect(updatedState.currentTrick.single.card, card);
      expect(updatedState.currentPlayer, PlayerSeat.leftOpponent);
    });

    test('automatically completes the current trick for opponent turns', () {
      final gameState = createInitialGameState(random: Random(1)).chooseTrump();
      final card = gameState.humanHand.first;

      final updatedState = gameState.playCard(card).playAutomaticTurns();

      expect(updatedState.humanHand, hasLength(7));
      expect(updatedState.hands[PlayerSeat.leftOpponent], hasLength(7));
      expect(updatedState.hands[PlayerSeat.partner], hasLength(7));
      expect(updatedState.hands[PlayerSeat.rightOpponent], hasLength(7));
      expect(updatedState.currentTrick, isEmpty);
      expect(updatedState.lastCompletedTrick, hasLength(4));
      expect(updatedState.lastCompletedTrick.first.player, PlayerSeat.human);
      expect(updatedState.lastTrickWinner, isNotNull);
      expect(updatedState.currentPlayer, updatedState.lastTrickWinner);
    });

    test('selects the trump card winner when a trick contains trump', () {
      const humanCard = BeloteCard(suit: Suit.clubs, rank: Rank.ace);
      const leftCard = BeloteCard(suit: Suit.clubs, rank: Rank.seven);
      const partnerCard = BeloteCard(suit: Suit.hearts, rank: Rank.seven);
      const rightCard = BeloteCard(suit: Suit.clubs, rank: Rank.ten);
      final gameState = GameState(
        hands: const {
          PlayerSeat.human: [humanCard],
          PlayerSeat.leftOpponent: [leftCard],
          PlayerSeat.partner: [partnerCard],
          PlayerSeat.rightOpponent: [rightCard],
        },
        turnedCard: const BeloteCard(suit: Suit.hearts, rank: Rank.ace),
        remainingDeck: const [],
        phase: GamePhase.playingTrick,
        trumpSuit: Suit.hearts,
        trumpTaker: PlayerSeat.human,
        currentPlayer: PlayerSeat.human,
      );

      final updatedState = gameState
          .playCard(humanCard)
          .playCard(leftCard, seat: PlayerSeat.leftOpponent)
          .playCard(partnerCard, seat: PlayerSeat.partner)
          .playCard(rightCard, seat: PlayerSeat.rightOpponent);

      expect(updatedState.lastTrickWinner, PlayerSeat.partner);
      expect(updatedState.currentPlayer, PlayerSeat.partner);
      expect(updatedState.currentTrick, isEmpty);
      expect(updatedState.lastCompletedTrick, hasLength(4));
      expect(updatedState.completedTrickCount, 1);
      expect(updatedState.wonTricks[Team.humanTeam], hasLength(1));
      expect(updatedState.wonTricks[Team.opponentTeam], isEmpty);
    });

    test('tracks won tricks and completes the round after eight tricks', () {
      var gameState = createInitialGameState(random: Random(1)).chooseTrump();

      while (gameState.phase == GamePhase.playingTrick) {
        final currentPlayer = gameState.currentPlayer!;
        final playableCards = gameState.playableCards(currentPlayer);
        if (playableCards.isEmpty) {
          break;
        }

        gameState = gameState.playCard(
          playableCards.first,
          seat: currentPlayer,
        );
      }

      expect(gameState.phase, GamePhase.roundComplete);
      expect(gameState.currentPlayer, isNull);
      expect(gameState.currentTrick, isEmpty);
      expect(gameState.completedTrickCount, 8);
      expect(
        (gameState.wonTricks[Team.humanTeam]?.length ?? 0) +
            (gameState.wonTricks[Team.opponentTeam]?.length ?? 0),
        8,
      );
      for (final seat in PlayerSeat.values) {
        expect(gameState.hands[seat], isEmpty);
      }
    });

    test('only exposes playable cards for the current player', () {
      final gameState = createInitialGameState(random: Random(1)).chooseTrump();
      final requestedSuit = gameState.humanHand.first.suit;
      final updatedState = gameState.playCard(gameState.humanHand.first);
      final leftOpponentHand = updatedState.hands[PlayerSeat.leftOpponent]!;
      final expectedLeftOpponentPlayableCards = leftOpponentHand
          .where((card) => card.suit == requestedSuit)
          .toList();

      expect(gameState.playableCards(PlayerSeat.human), gameState.humanHand);
      expect(gameState.playableCards(PlayerSeat.leftOpponent), isEmpty);
      expect(updatedState.playableCards(PlayerSeat.human), isEmpty);
      expect(
        updatedState.playableCards(PlayerSeat.leftOpponent),
        expectedLeftOpponentPlayableCards.isEmpty
            ? leftOpponentHand
            : expectedLeftOpponentPlayableCards,
      );
    });

    test('requires cutting when the player cannot follow suit', () {
      const humanCard = BeloteCard(suit: Suit.clubs, rank: Rank.ace);
      const trumpSeven = BeloteCard(suit: Suit.hearts, rank: Rank.seven);
      const trumpJack = BeloteCard(suit: Suit.hearts, rank: Rank.jack);
      const discard = BeloteCard(suit: Suit.spades, rank: Rank.ace);
      final gameState = GameState(
        hands: const {
          PlayerSeat.human: [],
          PlayerSeat.leftOpponent: [discard, trumpSeven, trumpJack],
          PlayerSeat.partner: [],
          PlayerSeat.rightOpponent: [],
        },
        turnedCard: const BeloteCard(suit: Suit.hearts, rank: Rank.ace),
        remainingDeck: const [],
        phase: GamePhase.playingTrick,
        trumpSuit: Suit.hearts,
        trumpTaker: PlayerSeat.human,
        currentPlayer: PlayerSeat.leftOpponent,
        currentTrick: const [
          PlayedCard(player: PlayerSeat.human, card: humanCard),
        ],
      );

      expect(gameState.playableCards(PlayerSeat.leftOpponent), [
        trumpSeven,
        trumpJack,
      ]);
    });

    test('allows discarding when the partner is currently winning', () {
      const humanCard = BeloteCard(suit: Suit.clubs, rank: Rank.seven);
      const partnerCard = BeloteCard(suit: Suit.clubs, rank: Rank.ace);
      const trumpSeven = BeloteCard(suit: Suit.hearts, rank: Rank.seven);
      const discard = BeloteCard(suit: Suit.spades, rank: Rank.ace);
      final gameState = GameState(
        hands: const {
          PlayerSeat.human: [],
          PlayerSeat.leftOpponent: [],
          PlayerSeat.partner: [],
          PlayerSeat.rightOpponent: [discard, trumpSeven],
        },
        turnedCard: const BeloteCard(suit: Suit.hearts, rank: Rank.ace),
        remainingDeck: const [],
        phase: GamePhase.playingTrick,
        trumpSuit: Suit.hearts,
        trumpTaker: PlayerSeat.human,
        currentPlayer: PlayerSeat.rightOpponent,
        currentTrick: const [
          PlayedCard(player: PlayerSeat.human, card: humanCard),
          PlayedCard(player: PlayerSeat.leftOpponent, card: partnerCard),
        ],
      );

      expect(gameState.playableCards(PlayerSeat.rightOpponent), [
        discard,
        trumpSeven,
      ]);
    });

    test('requires overtrumping when a higher trump is available', () {
      const humanCard = BeloteCard(suit: Suit.clubs, rank: Rank.ace);
      const opponentTrump = BeloteCard(suit: Suit.hearts, rank: Rank.nine);
      const lowerTrump = BeloteCard(suit: Suit.hearts, rank: Rank.seven);
      const higherTrump = BeloteCard(suit: Suit.hearts, rank: Rank.jack);
      const discard = BeloteCard(suit: Suit.spades, rank: Rank.ace);
      final gameState = GameState(
        hands: const {
          PlayerSeat.human: [],
          PlayerSeat.leftOpponent: [],
          PlayerSeat.partner: [discard, lowerTrump, higherTrump],
          PlayerSeat.rightOpponent: [],
        },
        turnedCard: const BeloteCard(suit: Suit.hearts, rank: Rank.ace),
        remainingDeck: const [],
        phase: GamePhase.playingTrick,
        trumpSuit: Suit.hearts,
        trumpTaker: PlayerSeat.human,
        currentPlayer: PlayerSeat.partner,
        currentTrick: const [
          PlayedCard(player: PlayerSeat.human, card: humanCard),
          PlayedCard(player: PlayerSeat.leftOpponent, card: opponentTrump),
        ],
      );

      expect(gameState.playableCards(PlayerSeat.partner), [higherTrump]);
    });

    test('requires overtrumping when trump is the requested suit', () {
      const humanTrump = BeloteCard(suit: Suit.hearts, rank: Rank.nine);
      const lowerTrump = BeloteCard(suit: Suit.hearts, rank: Rank.seven);
      const higherTrump = BeloteCard(suit: Suit.hearts, rank: Rank.jack);
      const discard = BeloteCard(suit: Suit.spades, rank: Rank.ace);
      final gameState = GameState(
        hands: const {
          PlayerSeat.human: [],
          PlayerSeat.leftOpponent: [discard, lowerTrump, higherTrump],
          PlayerSeat.partner: [],
          PlayerSeat.rightOpponent: [],
        },
        turnedCard: const BeloteCard(suit: Suit.hearts, rank: Rank.ace),
        remainingDeck: const [],
        phase: GamePhase.playingTrick,
        trumpSuit: Suit.hearts,
        trumpTaker: PlayerSeat.human,
        currentPlayer: PlayerSeat.leftOpponent,
        currentTrick: const [
          PlayedCard(player: PlayerSeat.human, card: humanTrump),
        ],
      );

      expect(gameState.playableCards(PlayerSeat.leftOpponent), [higherTrump]);
    });

    test('rejects playing a card that is in hand but not playable', () {
      const humanCard = BeloteCard(suit: Suit.clubs, rank: Rank.ace);
      const trumpSeven = BeloteCard(suit: Suit.hearts, rank: Rank.seven);
      const discard = BeloteCard(suit: Suit.spades, rank: Rank.ace);
      final gameState = GameState(
        hands: const {
          PlayerSeat.human: [],
          PlayerSeat.leftOpponent: [discard, trumpSeven],
          PlayerSeat.partner: [],
          PlayerSeat.rightOpponent: [],
        },
        turnedCard: const BeloteCard(suit: Suit.hearts, rank: Rank.ace),
        remainingDeck: const [],
        phase: GamePhase.playingTrick,
        trumpSuit: Suit.hearts,
        trumpTaker: PlayerSeat.human,
        currentPlayer: PlayerSeat.leftOpponent,
        currentTrick: const [
          PlayedCard(player: PlayerSeat.human, card: humanCard),
        ],
      );

      expect(
        () => gameState.playCard(discard, seat: PlayerSeat.leftOpponent),
        throwsArgumentError,
      );
    });

    test('rejects playing out of turn or with a missing card', () {
      final gameState = createInitialGameState(random: Random(1)).chooseTrump();
      final card = gameState.humanHand.first;

      expect(
        () => gameState.playCard(card, seat: PlayerSeat.leftOpponent),
        throwsStateError,
      );
      expect(
        () =>
            gameState.playCard(gameState.hands[PlayerSeat.leftOpponent]!.first),
        throwsArgumentError,
      );
    });
  });
}
