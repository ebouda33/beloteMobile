import 'package:flutter/material.dart';

import '../cards/belote_card.dart';
import '../game_state.dart';

class GameBoardView extends StatelessWidget {
  const GameBoardView({
    super.key,
    required this.gameState,
    required this.onCardTap,
  });

  final GameState gameState;
  final ValueChanged<BeloteCard> onCardTap;

  static const Color _forestDeep = Color(0xFF182A23);
  static const Color _forest = Color(0xFF243C32);
  static const Color _paper = Color(0xFFF4E8D6);
  static const Color _brass = Color(0xFFC4A15A);
  static const Color _burgundy = Color(0xFF7A3636);

  @override
  Widget build(BuildContext context) {
    final playableCards = gameState.playableCards(gameState.humanSeat);
    final trumpLabel = gameState.trumpSuit == null
        ? 'Atout a choisir'
        : 'Atout : ${gameState.trumpSuit!.label}';

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
              const Column(
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
                    'Les cartes adverses restent cachees.',
                    style: TextStyle(fontSize: 13, color: Color(0xFFD8CCB7)),
                  ),
                ],
              ),
              _StatusBadge(
                text: trumpLabel,
                background: _brass.withValues(alpha: 0.14),
                border: _brass.withValues(alpha: 0.55),
                foreground: _paper,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SeatHand(
            key: const ValueKey('partner-hand'),
            title: PlayerSeat.partner.label,
            count: gameState.hands[PlayerSeat.partner]?.length ?? 0,
            cards: gameState.hands[PlayerSeat.partner] ?? const [],
            faceDown: true,
            orientation: Axis.horizontal,
            active: gameState.currentPlayer == PlayerSeat.partner,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SeatHand(
                  key: const ValueKey('left-opponent-hand'),
                  title: PlayerSeat.leftOpponent.label,
                  count: gameState.hands[PlayerSeat.leftOpponent]?.length ?? 0,
                  cards: gameState.hands[PlayerSeat.leftOpponent] ?? const [],
                  faceDown: true,
                  orientation: Axis.vertical,
                  compact: true,
                  active: gameState.currentPlayer == PlayerSeat.leftOpponent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _TrickArea(gameState: gameState)),
              const SizedBox(width: 12),
              Expanded(
                child: _SeatHand(
                  key: const ValueKey('right-opponent-hand'),
                  title: PlayerSeat.rightOpponent.label,
                  count: gameState.hands[PlayerSeat.rightOpponent]?.length ?? 0,
                  cards: gameState.hands[PlayerSeat.rightOpponent] ?? const [],
                  faceDown: true,
                  orientation: Axis.vertical,
                  compact: true,
                  active: gameState.currentPlayer == PlayerSeat.rightOpponent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SeatHand(
            key: const ValueKey('human-hand'),
            title: PlayerSeat.human.label,
            count: gameState.humanHand.length,
            cards: gameState.humanHand,
            faceDown: false,
            orientation: Axis.horizontal,
            active: gameState.currentPlayer == gameState.humanSeat,
            playableCards: playableCards.toSet(),
            onCardTap: onCardTap,
          ),
        ],
      ),
    );
  }
}

class _SeatHand extends StatelessWidget {
  const _SeatHand({
    super.key,
    required this.title,
    required this.count,
    required this.cards,
    required this.faceDown,
    required this.orientation,
    required this.active,
    this.compact = false,
    this.playableCards = const {},
    this.onCardTap,
  });

  final String title;
  final int count;
  final List<BeloteCard> cards;
  final bool faceDown;
  final Axis orientation;
  final bool active;
  final bool compact;
  final Set<BeloteCard> playableCards;
  final ValueChanged<BeloteCard>? onCardTap;

  @override
  Widget build(BuildContext context) {
    final visibleCards = cards
        .map(
          (card) => PlayingCardView(
            card: card,
            faceDown: faceDown,
            compact: compact,
            playable: playableCards.contains(card),
            onTap: onCardTap == null || faceDown
                ? null
                : () => onCardTap!(card),
          ),
        )
        .toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: active ? const Color(0x1AC4A15A) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? const Color(0xFFC4A15A).withValues(alpha: 0.65)
              : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: GameBoardView._paper,
                  ),
                ),
                _StatusBadge(
                  text: '$count cartes',
                  background: const Color(0x143C5C45),
                  border: const Color(0x52D8CCB7),
                  foreground: const Color(0xFFEFE7D7),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!faceDown && orientation == Axis.horizontal)
              Wrap(spacing: 8, runSpacing: 8, children: visibleCards)
            else
              _CardStack(
                cards: visibleCards,
                orientation: orientation,
                compact: compact,
              ),
          ],
        ),
      ),
    );
  }
}

class _TrickArea extends StatelessWidget {
  const _TrickArea({required this.gameState});

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    final showTurnedCard =
        gameState.phase == GamePhase.choosingTrump ||
        gameState.phase == GamePhase.waitingForTrumpTaker;
    final playedCards = showTurnedCard
        ? const <PlayedCard>[]
        : gameState.currentTrick.isNotEmpty
        ? gameState.currentTrick
        : gameState.lastCompletedTrick;

    return SizedBox(
      height: 240,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF214132),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: GameBoardView._brass.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  'Pli',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: GameBoardView._paper,
                  ),
                ),
                if (gameState.currentPlayer case final currentPlayer?)
                  _StatusBadge(
                    text: 'A ${currentPlayer.label}',
                    background: GameBoardView._brass.withValues(alpha: 0.14),
                    border: GameBoardView._brass.withValues(alpha: 0.45),
                    foreground: GameBoardView._paper,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Center(
                child: showTurnedCard
                    ? PlayingCardView(
                        key: const ValueKey('turned-card'),
                        card: gameState.turnedCard,
                      )
                    : playedCards.isEmpty
                    ? const Text(
                        'Le centre du tapis s anime ici.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFD8CCB7),
                          fontSize: 14,
                        ),
                      )
                    : Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final playedCard in playedCards)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PlayingCardView(
                                  card: playedCard.card,
                                  compact: true,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  playedCard.player.label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFD8CCB7),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardStack extends StatelessWidget {
  const _CardStack({
    required this.cards,
    required this.orientation,
    required this.compact,
  });

  final List<Widget> cards;
  final Axis orientation;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const SizedBox(height: 54);
    }

    final overlap = compact ? 14.0 : 18.0;
    final cardWidth = compact ? 42.0 : 56.0;
    final cardHeight = compact ? 60.0 : 82.0;
    final extent = orientation == Axis.horizontal
        ? cardWidth + (cards.length - 1) * overlap
        : cardHeight + (cards.length - 1) * overlap;

    return SizedBox(
      width: orientation == Axis.horizontal ? extent : cardWidth,
      height: orientation == Axis.horizontal ? cardHeight : extent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = 0; index < cards.length; index++)
            Positioned(
              left: orientation == Axis.horizontal ? index * overlap : 0,
              top: orientation == Axis.vertical ? index * overlap : 0,
              child: cards[index],
            ),
        ],
      ),
    );
  }
}

class PlayingCardView extends StatelessWidget {
  const PlayingCardView({
    super.key,
    required this.card,
    this.faceDown = false,
    this.compact = false,
    this.playable = false,
    this.onTap,
  });

  final BeloteCard card;
  final bool faceDown;
  final bool compact;
  final bool playable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 42.0 : 56.0;
    final height = compact ? 60.0 : 82.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width,
          height: height,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: faceDown
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF243C32), Color(0xFF13211B)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFCF8F1), Color(0xFFF2E5D0)],
                  ),
            border: Border.all(
              color: faceDown
                  ? const Color(0xFFC4A15A)
                  : playable
                  ? const Color(0xFFC4A15A)
                  : const Color(0xFFD8CCB7),
              width: playable ? 2.2 : 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x332B251F),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: faceDown
              ? _CardBack()
              : _CardFace(card: card, playable: playable),
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.card, required this.playable});

  final BeloteCard card;
  final bool playable;

  @override
  Widget build(BuildContext context) {
    final suitColor = switch (card.suit) {
      Suit.clubs || Suit.spades => GameBoardView._forestDeep,
      Suit.diamonds || Suit.hearts => GameBoardView._burgundy,
    };

    return DefaultTextStyle(
      style: TextStyle(
        color: suitColor,
        fontFamily: 'Georgia',
        fontWeight: FontWeight.w700,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 2,
            left: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  card.rank.label,
                  style: TextStyle(fontSize: playable ? 11 : 12, height: 1),
                ),
                Text(
                  _suitGlyph(card.suit),
                  style: TextStyle(fontSize: playable ? 10 : 11, height: 1),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: RotatedBox(
              quarterTurns: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.rank.label,
                    style: TextStyle(fontSize: playable ? 11 : 12, height: 1),
                  ),
                  Text(
                    _suitGlyph(card.suit),
                    style: TextStyle(fontSize: playable ? 10 : 11, height: 1),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Text(
              _suitGlyph(card.suit),
              style: TextStyle(
                fontSize: playable ? 20 : 24,
                color: suitColor.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFF0D9A9), width: 1),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF294539), Color(0xFF13211B)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFF0D9A9), width: 1),
                ),
              ),
            ),
          ),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BELOTE',
                  style: TextStyle(
                    color: Color(0xFFF4E8D6),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4),
                Icon(Icons.auto_awesome, size: 14, color: Color(0xFFC4A15A)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.text,
    required this.background,
    required this.border,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color border;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _suitGlyph(Suit suit) {
  return switch (suit) {
    Suit.clubs => '♣',
    Suit.diamonds => '♦',
    Suit.hearts => '♥',
    Suit.spades => '♠',
  };
}
