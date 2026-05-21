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
        expect(updatedState.hands, gameState.hands);
        expect(updatedState.humanHand, gameState.humanHand);
      },
    );

    test('rejects trump selection after trump is already selected', () {
      final gameState = createInitialGameState(random: Random(1)).chooseTrump();

      expect(gameState.chooseTrump, throwsStateError);
    });

    test('passes on the turned card without selecting trump', () {
      final gameState = createInitialGameState(random: Random(1));

      final updatedState = gameState.passTrump();

      expect(updatedState.trumpSuit, isNull);
      expect(updatedState.phase, GamePhase.waitingForTrumpTaker);
      expect(updatedState.hands, gameState.hands);
      expect(updatedState.turnedCard, gameState.turnedCard);
    });

    test('rejects passing after trump is already selected', () {
      final gameState = createInitialGameState(random: Random(1)).chooseTrump();

      expect(gameState.passTrump, throwsStateError);
    });
  });
}
