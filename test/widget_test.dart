import 'package:belote_mobile/game/cards/belote_card.dart';
import 'package:belote_mobile/game/game_state.dart';
import 'package:belote_mobile/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Finder humanCards() {
    return find.descendant(
      of: find.byKey(const ValueKey('human-hand')),
      matching: find.byType(PlayingCardView),
    );
  }

  Finder opponentCards(String seatKey) {
    return find.descendant(
      of: find.byKey(ValueKey(seatKey)),
      matching: find.byType(PlayingCardView),
    );
  }

  testWidgets('shows the Belote home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BeloteApp());

    expect(find.text('Belote Mobile'), findsOneWidget);
    expect(find.text('Belote'), findsOneWidget);
    expect(find.text('Nouvelle partie'), findsOneWidget);
  });

  testWidgets('starts a local game and shows the player hand', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BeloteApp());

    await tapVisible(tester, find.text('Nouvelle partie'));

    expect(find.byKey(const ValueKey('game-table')), findsOneWidget);
    expect(find.byKey(const ValueKey('human-hand')), findsOneWidget);
    expect(find.byKey(const ValueKey('turned-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('trump-badge')), findsOneWidget);
    expect(find.text('Atout'), findsOneWidget);
    expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
    expect(humanCards(), findsNWidgets(5));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('partner-hand')),
        matching: find.byType(PlayingCardView),
      ),
      findsNWidgets(5),
    );
    expect(find.textContaining('Carte retournee : '), findsOneWidget);
    expect(find.textContaining('Prendre '), findsNothing);
    expect(find.text('Passer'), findsNothing);

    await tapVisible(tester, find.byKey(const ValueKey('turned-card')));

    expect(find.text('Votre choix'), findsOneWidget);
    expect(find.textContaining('Prendre '), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);

    await tapVisible(tester, find.text('Prendre'));

    expect(find.byKey(const ValueKey('trump-badge')), findsOneWidget);
    expect(find.text('Preneur : Vous *'), findsNWidgets(2));
    expect(find.text('Joueur courant : Vous'), findsOneWidget);
    expect(humanCards(), findsNWidgets(8));
    expect(find.textContaining('Prendre '), findsNothing);
    expect(find.text('Passer'), findsNothing);
  });

  testWidgets('can reveal the opponents cards from the toolbar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BeloteApp());

    await tapVisible(tester, find.text('Nouvelle partie'));

    final partnerCardsBefore = tester
        .widgetList<PlayingCardView>(opponentCards('partner-hand'))
        .toList();
    expect(partnerCardsBefore, isNotEmpty);
    expect(partnerCardsBefore.every((card) => card.faceDown), isTrue);

    await tapVisible(tester, find.byTooltip('Voir les cartes des joueurs'));

    final partnerCardsAfter = tester
        .widgetList<PlayingCardView>(opponentCards('partner-hand'))
        .toList();
    expect(partnerCardsAfter, isNotEmpty);
    expect(partnerCardsAfter.every((card) => !card.faceDown), isTrue);

    expect(find.byTooltip('Masquer les cartes des joueurs'), findsOneWidget);
  });

  testWidgets('renders compact cards with suit only', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlayingCardView(
            card: BeloteCard(suit: Suit.hearts, rank: Rank.ace),
            compact: true,
          ),
        ),
      ),
    );

    expect(find.text('As'), findsNWidgets(2));
    expect(find.text('♥'), findsOneWidget);
  });

  testWidgets('passes on the turned trump card and closes the dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BeloteApp());

    await tapVisible(tester, find.text('Nouvelle partie'));
    await tapVisible(tester, find.byKey(const ValueKey('turned-card')));

    expect(find.text('Votre choix'), findsOneWidget);
    await tapVisible(tester, find.text('Passer'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Votre choix'), findsNothing);
    expect(find.byKey(const ValueKey('game-table')), findsOneWidget);
  });

  testWidgets('shows bidding speech bubbles for pass and take decisions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: GameBoardView(
              gameState: GameState(
                hands: const {
                  PlayerSeat.human: [
                    BeloteCard(suit: Suit.hearts, rank: Rank.ace),
                    BeloteCard(suit: Suit.hearts, rank: Rank.king),
                  ],
                  PlayerSeat.leftOpponent: [
                    BeloteCard(suit: Suit.clubs, rank: Rank.queen),
                    BeloteCard(suit: Suit.clubs, rank: Rank.jack),
                  ],
                  PlayerSeat.partner: [
                    BeloteCard(suit: Suit.spades, rank: Rank.seven),
                    BeloteCard(suit: Suit.spades, rank: Rank.eight),
                  ],
                  PlayerSeat.rightOpponent: [
                    BeloteCard(suit: Suit.diamonds, rank: Rank.ten),
                    BeloteCard(suit: Suit.diamonds, rank: Rank.ace),
                  ],
                },
                turnedCard: const BeloteCard(
                  suit: Suit.hearts,
                  rank: Rank.queen,
                ),
                remainingDeck: const [],
                phase: GamePhase.choosingTrump,
                biddingRound: 2,
                trumpSuit: Suit.clubs,
                trumpTaker: PlayerSeat.leftOpponent,
                passedSeats: {PlayerSeat.partner, PlayerSeat.rightOpponent},
              ),
              onCardTap: (_) {},
              onTurnedCardTap: () {},
              showOpponentCards: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Prend Trefle'), findsOneWidget);
    expect(find.text('Passe'), findsNWidgets(2));
  });

  testWidgets('hides bidding speech bubbles after the first trick', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: GameBoardView(
              gameState: GameState(
                hands: const {
                  PlayerSeat.human: [
                    BeloteCard(suit: Suit.hearts, rank: Rank.ace),
                    BeloteCard(suit: Suit.hearts, rank: Rank.king),
                  ],
                  PlayerSeat.leftOpponent: [
                    BeloteCard(suit: Suit.clubs, rank: Rank.queen),
                    BeloteCard(suit: Suit.clubs, rank: Rank.jack),
                  ],
                  PlayerSeat.partner: [
                    BeloteCard(suit: Suit.spades, rank: Rank.seven),
                    BeloteCard(suit: Suit.spades, rank: Rank.eight),
                  ],
                  PlayerSeat.rightOpponent: [
                    BeloteCard(suit: Suit.diamonds, rank: Rank.ten),
                    BeloteCard(suit: Suit.diamonds, rank: Rank.ace),
                  ],
                },
                turnedCard: const BeloteCard(
                  suit: Suit.hearts,
                  rank: Rank.queen,
                ),
                remainingDeck: const [],
                phase: GamePhase.playingTrick,
                biddingRound: 2,
                trumpSuit: Suit.clubs,
                trumpTaker: PlayerSeat.leftOpponent,
                passedSeats: {PlayerSeat.partner, PlayerSeat.rightOpponent},
                currentPlayer: PlayerSeat.human,
                currentTrick: const [
                  PlayedCard(
                    player: PlayerSeat.leftOpponent,
                    card: BeloteCard(suit: Suit.clubs, rank: Rank.queen),
                  ),
                ],
                lastCompletedTrick: const [
                  PlayedCard(
                    player: PlayerSeat.leftOpponent,
                    card: BeloteCard(suit: Suit.clubs, rank: Rank.queen),
                  ),
                  PlayedCard(
                    player: PlayerSeat.partner,
                    card: BeloteCard(suit: Suit.spades, rank: Rank.king),
                  ),
                  PlayedCard(
                    player: PlayerSeat.rightOpponent,
                    card: BeloteCard(suit: Suit.diamonds, rank: Rank.ace),
                  ),
                  PlayedCard(
                    player: PlayerSeat.human,
                    card: BeloteCard(suit: Suit.hearts, rank: Rank.ace),
                  ),
                ],
                lastTrickWinner: PlayerSeat.leftOpponent,
                wonTricks: {
                  Team.humanTeam: const [],
                  Team.opponentTeam: const [
                    [
                      PlayedCard(
                        player: PlayerSeat.leftOpponent,
                        card: BeloteCard(suit: Suit.clubs, rank: Rank.queen),
                      ),
                      PlayedCard(
                        player: PlayerSeat.partner,
                        card: BeloteCard(suit: Suit.spades, rank: Rank.king),
                      ),
                      PlayedCard(
                        player: PlayerSeat.rightOpponent,
                        card: BeloteCard(suit: Suit.diamonds, rank: Rank.ace),
                      ),
                      PlayedCard(
                        player: PlayerSeat.human,
                        card: BeloteCard(suit: Suit.hearts, rank: Rank.ace),
                      ),
                    ],
                  ],
                },
              ),
              onCardTap: (_) {},
              onTurnedCardTap: () {},
              showOpponentCards: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Passe'), findsNothing);
    expect(find.textContaining('Prend '), findsNothing);
  });

  testWidgets('dims non playable cards and lifts playable cards on hover', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: GameBoardView(
              gameState: GameState(
                hands: const {
                  PlayerSeat.human: [
                    BeloteCard(suit: Suit.hearts, rank: Rank.ace),
                    BeloteCard(suit: Suit.clubs, rank: Rank.seven),
                  ],
                  PlayerSeat.leftOpponent: [
                    BeloteCard(suit: Suit.spades, rank: Rank.queen),
                  ],
                  PlayerSeat.partner: [
                    BeloteCard(suit: Suit.diamonds, rank: Rank.queen),
                  ],
                  PlayerSeat.rightOpponent: [
                    BeloteCard(suit: Suit.diamonds, rank: Rank.ace),
                  ],
                },
                turnedCard: const BeloteCard(
                  suit: Suit.hearts,
                  rank: Rank.queen,
                ),
                remainingDeck: const [],
                phase: GamePhase.playingTrick,
                trumpSuit: Suit.hearts,
                currentPlayer: PlayerSeat.human,
                currentTrick: const [
                  PlayedCard(
                    player: PlayerSeat.leftOpponent,
                    card: BeloteCard(suit: Suit.hearts, rank: Rank.king),
                  ),
                ],
              ),
              onCardTap: (_) {},
              onTurnedCardTap: () {},
              showOpponentCards: false,
            ),
          ),
        ),
      ),
    );

    final dimmedCardFinder = find.byKey(const ValueKey('card-clubs-seven'));
    expect(dimmedCardFinder, findsOneWidget);
    final dimmedOpacity = tester.widget<AnimatedOpacity>(
      find.descendant(
        of: dimmedCardFinder,
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(dimmedOpacity.opacity, lessThan(1));

    final hoverCardFinder = find.byKey(const ValueKey('card-hearts-ace'));
    expect(hoverCardFinder, findsOneWidget);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    await gesture.moveTo(tester.getCenter(hoverCardFinder));
    await tester.pump(const Duration(milliseconds: 200));

    final hoverTransform = tester.widget<Transform>(
      find
          .descendant(
            of: find.byKey(const ValueKey('hover-hearts-ace')),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(hoverTransform.transform.storage[13], lessThanOrEqualTo(0));
  });
}
