import 'package:flutter/material.dart';

import '../cards/belote_card.dart';
import '../game_state.dart';

class GameBoardView extends StatelessWidget {
  const GameBoardView({
    super.key,
    required this.gameState,
    required this.onCardTap,
    required this.onTurnedCardTap,
    required this.showOpponentCards,
  });

  final GameState gameState;
  final ValueChanged<BeloteCard> onCardTap;
  final VoidCallback onTurnedCardTap;
  final bool showOpponentCards;

  static const Color _forestDeep = Color(0xFF182A23);
  static const Color _forest = Color(0xFF243C32);
  static const Color _paper = Color(0xFFF4E8D6);
  static const Color _brass = Color(0xFFC4A15A);
  static const Color _burgundy = Color(0xFF7A3636);

  @override
  Widget build(BuildContext context) {
    final playableCards = gameState.playableCards(gameState.humanSeat);
    final showBiddingSpeech = gameState.completedTrickCount == 0;

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
              _StatusBadge(
                key: const ValueKey('trump-badge'),
                text: '',
                background: _brass.withValues(alpha: 0.14),
                border: _brass.withValues(alpha: 0.55),
                foreground: _paper,
                child: _TrumpBadgeContent(
                  trumpSuit: gameState.trumpSuit,
                  biddingRound: gameState.biddingRound,
                ),
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
                  count: gameState.hands[PlayerSeat.partner]?.length ?? 0,
                  cards: gameState.hands[PlayerSeat.partner] ?? const [],
                  faceDown: !showOpponentCards,
                  orientation: Axis.horizontal,
                  active: gameState.currentPlayer == PlayerSeat.partner,
                  speechBubble: showBiddingSpeech
                      ? gameState.biddingSpeechForSeat(PlayerSeat.partner)
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SeatHand(
                        key: const ValueKey('left-opponent-hand'),
                        title: PlayerSeat.leftOpponent.label,
                        count:
                            gameState.hands[PlayerSeat.leftOpponent]?.length ??
                            0,
                        cards:
                            gameState.hands[PlayerSeat.leftOpponent] ??
                            const [],
                        faceDown: !showOpponentCards,
                        orientation: Axis.vertical,
                        compact: true,
                        active:
                            gameState.currentPlayer == PlayerSeat.leftOpponent,
                        speechBubble: showBiddingSpeech
                            ? gameState.biddingSpeechForSeat(
                                PlayerSeat.leftOpponent,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _TrickArea(
                        gameState: gameState,
                        onTurnedCardTap: onTurnedCardTap,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SeatHand(
                        key: const ValueKey('right-opponent-hand'),
                        title: PlayerSeat.rightOpponent.label,
                        count:
                            gameState.hands[PlayerSeat.rightOpponent]?.length ??
                            0,
                        cards:
                            gameState.hands[PlayerSeat.rightOpponent] ??
                            const [],
                        faceDown: !showOpponentCards,
                        orientation: Axis.vertical,
                        compact: true,
                        active:
                            gameState.currentPlayer == PlayerSeat.rightOpponent,
                        speechBubble: showBiddingSpeech
                            ? gameState.biddingSpeechForSeat(
                                PlayerSeat.rightOpponent,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
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
                  speechBubble: showBiddingSpeech
                      ? gameState.biddingSpeechForSeat(gameState.humanSeat)
                      : null,
                ),
              ],
            ),
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
    this.speechBubble,
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
  final String? speechBubble;

  @override
  Widget build(BuildContext context) {
    final visibleCards = List.generate(cards.length, (index) {
      final card = cards[index];
      final baseCard = PlayingCardView(
        key: ValueKey('card-${card.id}'),
        card: card,
        faceDown: faceDown,
        compact: compact || (!faceDown && onCardTap == null),
        playable: playableCards.contains(card),
        dimmed:
            onCardTap != null &&
            !faceDown &&
            playableCards.isNotEmpty &&
            !playableCards.contains(card),
        onTap: onCardTap == null || faceDown || !playableCards.contains(card)
            ? null
            : () => onCardTap!(card),
      );

      if (faceDown) {
        final spread = (index - (cards.length - 1) / 2) * 0.03;
        return Transform.rotate(angle: spread, child: baseCard);
      }

      return baseCard;
    });

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
            if (speechBubble != null) ...[
              const SizedBox(height: 8),
              _SpeechBubble(
                text: speechBubble!,
                take: speechBubble!.startsWith('Prend'),
              ),
            ],
            const SizedBox(height: 8),
            if (!faceDown && onCardTap == null)
              Wrap(spacing: 6, runSpacing: 6, children: visibleCards)
            else if (!faceDown && orientation == Axis.horizontal)
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
  const _TrickArea({required this.gameState, required this.onTurnedCardTap});

  final GameState gameState;
  final VoidCallback onTurnedCardTap;

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
                if (gameState.trumpTakerLabel case final takerLabel?)
                  _StatusBadge(
                    key: const ValueKey('trump-taker-badge'),
                    text: takerLabel,
                    background: const Color(0xFFE7D1D1),
                    border: const Color(0xFF9C5757),
                    foreground: const Color(0xFF4A1C1C),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFF0D9A9).withValues(alpha: 0.15),
                          const Color(0xFFF0D9A9).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  if (showTurnedCard)
                    SizedBox.expand(
                      child: Center(
                        child: InkWell(
                          onTap: onTurnedCardTap,
                          borderRadius: BorderRadius.circular(12),
                          child: PlayingCardView(
                            key: const ValueKey('turned-card'),
                            card: gameState.turnedCard,
                          ),
                        ),
                      ),
                    )
                  else if (playedCards.isEmpty)
                    const Text(
                      'Le centre du tapis s anime ici.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFD8CCB7), fontSize: 14),
                    )
                  else ...[
                    for (final playedCard in playedCards)
                      Align(
                        alignment: _alignmentForSeat(playedCard.player),
                        child: Column(
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
                      ),
                  ],
                ],
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
    this.dimmed = false,
    this.onTap,
  });

  final BeloteCard card;
  final bool faceDown;
  final bool compact;
  final bool playable;
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 42.0 : 56.0;
    final height = compact ? 60.0 : 82.0;

    return _PlayingCardFrame(
      cardId: card.id,
      width: width,
      height: height,
      faceDown: faceDown,
      compact: compact,
      playable: playable,
      dimmed: dimmed,
      onTap: onTap,
      child: faceDown
          ? _CardBack()
          : _CardFace(card: card, playable: playable, compact: compact),
    );
  }
}

class _PlayingCardFrame extends StatefulWidget {
  const _PlayingCardFrame({
    required this.cardId,
    required this.width,
    required this.height,
    required this.faceDown,
    required this.compact,
    required this.playable,
    required this.dimmed,
    required this.onTap,
    required this.child,
  });

  final String cardId;
  final double width;
  final double height;
  final bool faceDown;
  final bool compact;
  final bool playable;
  final bool dimmed;
  final VoidCallback? onTap;
  final Widget child;

  @override
  State<_PlayingCardFrame> createState() => _PlayingCardFrameState();
}

class _PlayingCardFrameState extends State<_PlayingCardFrame> {
  bool _hovered = false;

  bool get _canHover =>
      widget.playable && widget.onTap != null && !widget.faceDown;

  @override
  Widget build(BuildContext context) {
    Widget card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: widget.faceDown
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
              color: widget.faceDown
                  ? const Color(0xFFC4A15A)
                  : widget.playable
                  ? const Color(0xFFC4A15A)
                  : const Color(0xFFD8CCB7),
              width: widget.playable ? 2.2 : 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x332B251F),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );

    if (_canHover) {
      card = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() {
            _hovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            _hovered = false;
          });
        },
        child: TweenAnimationBuilder<double>(
          key: ValueKey('hover-${widget.cardId}'),
          tween: Tween<double>(begin: 0, end: _hovered ? 1 : 0),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -6 * value),
              child: Transform.scale(scale: 1 + (0.04 * value), child: child),
            );
          },
          child: card,
        ),
      );
    }

    if (widget.dimmed) {
      card = AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: 0.52,
        child: card,
      );
    }

    return card;
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.card,
    required this.playable,
    required this.compact,
  });

  final BeloteCard card;
  final bool playable;
  final bool compact;

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
          if (!compact) ...[
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
          ] else ...[
            Positioned(
              top: 2,
              left: 2,
              child: Text(
                card.rank.label,
                style: TextStyle(fontSize: playable ? 11 : 12, height: 1),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: RotatedBox(
                quarterTurns: 2,
                child: Text(
                  card.rank.label,
                  style: TextStyle(fontSize: playable ? 11 : 12, height: 1),
                ),
              ),
            ),
          ],
          Center(
            child: Text(
              _suitGlyph(card.suit),
              style: TextStyle(
                fontSize: compact ? 18 : (playable ? 20 : 24),
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
    super.key,
    required this.text,
    required this.background,
    required this.border,
    required this.foreground,
    this.child,
  });

  final String text;
  final Color background;
  final Color border;
  final Color foreground;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child:
          child ??
          Text(
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

class _TrumpBadgeContent extends StatelessWidget {
  const _TrumpBadgeContent({
    required this.trumpSuit,
    required this.biddingRound,
  });

  final Suit? trumpSuit;
  final int biddingRound;

  @override
  Widget build(BuildContext context) {
    final iconColor = trumpSuit == null
        ? const Color(0xFF7A5E34)
        : switch (trumpSuit!) {
            Suit.clubs || Suit.spades => GameBoardView._forestDeep,
            Suit.diamonds || Suit.hearts => GameBoardView._burgundy,
          };

    final icon = trumpSuit == null
        ? (biddingRound == 1
              ? Icons.help_outline_rounded
              : Icons.rotate_right_rounded)
        : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Atout',
          style: TextStyle(
            color: GameBoardView._paper,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: GameBoardView._paper.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(color: iconColor.withValues(alpha: 0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: icon == null
                ? Text(
                    _suitGlyph(trumpSuit!),
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Icon(icon, size: 14, color: iconColor),
          ),
        ),
      ],
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text, required this.take});

  final String text;
  final bool take;

  @override
  Widget build(BuildContext context) {
    final background = take ? const Color(0xFFE7D1D1) : const Color(0xFFE8E0D4);
    final border = take ? const Color(0xFF9C5757) : const Color(0xFFB9A991);
    final foreground = take ? const Color(0xFF4A1C1C) : const Color(0xFF4E4338);
    final tailColor = background;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
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
        ),
        Positioned(
          left: 18,
          bottom: -5,
          child: Transform.rotate(
            angle: 0.78539816339,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: tailColor,
                border: Border(
                  right: BorderSide(color: border, width: 1),
                  bottom: BorderSide(color: border, width: 1),
                ),
              ),
            ),
          ),
        ),
      ],
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

Alignment _alignmentForSeat(PlayerSeat seat) {
  return switch (seat) {
    PlayerSeat.human => Alignment.bottomCenter,
    PlayerSeat.leftOpponent => Alignment.centerLeft,
    PlayerSeat.partner => Alignment.topCenter,
    PlayerSeat.rightOpponent => Alignment.centerRight,
  };
}
