import 'dart:math';

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

    test('only exposes playable cards for the current player', () {
      final gameState = createInitialGameState(random: Random(1)).chooseTrump();
      final updatedState = gameState.playCard(gameState.humanHand.first);

      expect(gameState.playableCards(PlayerSeat.human), gameState.humanHand);
      expect(gameState.playableCards(PlayerSeat.leftOpponent), isEmpty);
      expect(updatedState.playableCards(PlayerSeat.human), isEmpty);
      expect(
        updatedState.playableCards(PlayerSeat.leftOpponent),
        updatedState.hands[PlayerSeat.leftOpponent],
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
