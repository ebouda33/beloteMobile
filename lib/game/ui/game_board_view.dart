import 'package:flutter/material.dart';

import '../cards/belote_card.dart';
import '../game_state.dart';

part 'game_board_view_parts.dart';

class GameBoardView extends StatelessWidget {
  const GameBoardView({
    super.key,
    required this.gameState,
    required this.onCardTap,
    required this.showOpponentCards,
    required this.showLastTrick,
    required this.onToggleLastTrick,
    required this.onStartNextRound,
    required this.onToggleOpponentCards,
    required this.showOpponentCardsActionLabel,
  });

  final GameState gameState;
  final ValueChanged<BeloteCard> onCardTap;
  final bool showOpponentCards;
  final bool showLastTrick;
  final VoidCallback onToggleLastTrick;
  final VoidCallback onStartNextRound;
  final VoidCallback onToggleOpponentCards;
  final String showOpponentCardsActionLabel;

  static const Color _forestDeep = Color(0xFF182A23);
  static const Color _forest = Color(0xFF243C32);
  static const Color _paper = Color(0xFFF4E8D6);
  static const Color _brass = Color(0xFFC4A15A);
  static const Color _burgundy = Color(0xFF7A3636);

  @override
  Widget build(BuildContext context) {
    final playableCards = gameState.playableCards(gameState.humanSeat);

    return Container(
      key: const ValueKey('game-table'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_forest, _forestDeep],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _brass.withValues(alpha: 0.72), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x262B251F),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tapis de jeu',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _paper,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    showOpponentCards
                        ? 'Les cartes adverses sont visibles.'
                        : 'Les cartes adverses restent cachees.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFD8CCB7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _ScoreNotebook(gameState: gameState),
              if (gameState.phase == GamePhase.roundComplete &&
                  !gameState.isGameComplete)
                FilledButton.icon(
                  key: const ValueKey('next-round-button'),
                  onPressed: onStartNextRound,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Nouvelle manche'),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  FilledButton.tonalIcon(
                    key: const ValueKey('toggle-opponent-cards'),
                    onPressed: onToggleOpponentCards,
                    icon: Icon(
                      showOpponentCards
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    label: Text(showOpponentCardsActionLabel),
                  ),
                  FilledButton.tonalIcon(
                    key: const ValueKey('toggle-last-trick'),
                    onPressed: onToggleLastTrick,
                    icon: Icon(
                      showLastTrick
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    label: Text(
                      showLastTrick ? 'Cacher le dernier pli' : 'Dernier pli',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A4638), Color(0xFF1A2E25)],
              ),
              border: Border.all(color: _brass.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                _SeatHand(
                  key: const ValueKey('partner-hand'),
                  title: PlayerSeat.partner.label,
                  cards: gameState.hands[PlayerSeat.partner] ?? const [],
                  faceDown: !showOpponentCards,
                  orientation: Axis.horizontal,
                  isDealer: gameState.dealerSeat == PlayerSeat.partner,
                  active: gameState.currentPlayer == PlayerSeat.partner,
                  isTrumpTaker: gameState.trumpTaker == PlayerSeat.partner,
                  trumpSuit: gameState.trumpSuit,
                  speechBubble: gameState.speechBubbleForSeat(
                    PlayerSeat.partner,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _SeatHand(
                          key: const ValueKey('left-opponent-hand'),
                          title: PlayerSeat.leftOpponent.label,
                          cards:
                              gameState.hands[PlayerSeat.leftOpponent] ??
                              const [],
                          faceDown: !showOpponentCards,
                          orientation: Axis.vertical,
                          compact: true,
                          isDealer:
                              gameState.dealerSeat == PlayerSeat.leftOpponent,
                          active:
                              gameState.currentPlayer ==
                              PlayerSeat.leftOpponent,
                          isTrumpTaker:
                              gameState.trumpTaker == PlayerSeat.leftOpponent,
                          trumpSuit: gameState.trumpSuit,
                          speechBubble: gameState.speechBubbleForSeat(
                            PlayerSeat.leftOpponent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _TrickArea(
                        gameState: gameState,
                        showLastTrick: showLastTrick,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _SeatHand(
                          key: const ValueKey('right-opponent-hand'),
                          title: PlayerSeat.rightOpponent.label,
                          cards:
                              gameState.hands[PlayerSeat.rightOpponent] ??
                              const [],
                          faceDown: !showOpponentCards,
                          orientation: Axis.vertical,
                          compact: true,
                          isDealer:
                              gameState.dealerSeat == PlayerSeat.rightOpponent,
                          active:
                              gameState.currentPlayer ==
                              PlayerSeat.rightOpponent,
                          isTrumpTaker:
                              gameState.trumpTaker == PlayerSeat.rightOpponent,
                          trumpSuit: gameState.trumpSuit,
                          speechBubble: gameState.speechBubbleForSeat(
                            PlayerSeat.rightOpponent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SeatHand(
                  key: const ValueKey('human-hand'),
                  title: PlayerSeat.human.label,
                  cards: gameState.humanHand,
                  faceDown: false,
                  orientation: Axis.horizontal,
                  isDealer: gameState.dealerSeat == gameState.humanSeat,
                  active: gameState.currentPlayer == gameState.humanSeat,
                  isTrumpTaker: gameState.trumpTaker == gameState.humanSeat,
                  trumpSuit: gameState.trumpSuit,
                  playableCards: playableCards.toSet(),
                  onCardTap: onCardTap,
                  speechBubble: gameState.speechBubbleForSeat(
                    gameState.humanSeat,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
