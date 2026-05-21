import 'dart:math';

import 'package:belote_mobile/game/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Game state', () {
    test('creates an initial game state with four complete hands', () {
      final gameState = createInitialGameState(random: Random(1));

      expect(gameState.hands, hasLength(4));
      for (final seat in PlayerSeat.values) {
        expect(gameState.hands[seat], hasLength(8));
      }

      final dealtCards = gameState.hands.values.expand((hand) => hand).toSet();
      expect(dealtCards, hasLength(32));
    });

    test('starts with the human player and waits for trump selection', () {
      final gameState = createInitialGameState(random: Random(1));

      expect(gameState.humanSeat, PlayerSeat.human);
      expect(gameState.humanHand, gameState.hands[PlayerSeat.human]);
      expect(gameState.phase, GamePhase.choosingTrump);
      expect(gameState.trumpSuit, isNull);
    });
  });
}
