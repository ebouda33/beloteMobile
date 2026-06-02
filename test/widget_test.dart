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
    expect(find.byKey(const ValueKey('ai-level-selector')), findsOneWidget);
  });

  testWidgets('can switch the AI level selector', (WidgetTester tester) async {
    await tester.pumpWidget(const BeloteApp());

    final selectorBefore = tester.widget<SegmentedButton<AiLevel>>(
      find.byKey(const ValueKey('ai-level-selector')),
    );
    expect(selectorBefore.selected, {AiLevel.debutant});

    await tapVisible(tester, find.text('Expert'));

    final selectorAfter = tester.widget<SegmentedButton<AiLevel>>(
      find.byKey(const ValueKey('ai-level-selector')),
    );
    expect(selectorAfter.selected, {AiLevel.expert});
  });

  testWidgets('starts a local game and shows the player hand', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BeloteApp(randomizeDealerSeat: false));

    await tapVisible(tester, find.text('Nouvelle partie'));

    expect(find.byKey(const ValueKey('game-table')), findsOneWidget);
    expect(find.byKey(const ValueKey('score-notebook')), findsOneWidget);
    expect(find.text('Scores'), findsOneWidget);
    expect(find.text('EUX'), findsOneWidget);
    expect(find.text('NOUS'), findsOneWidget);
    expect(find.byKey(const ValueKey('human-hand')), findsOneWidget);
    expect(find.byKey(const ValueKey('turned-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('trump-badge')), findsOneWidget);
    expect(find.text('Atout'), findsOneWidget);
    expect(find.byKey(const ValueKey('toggle-opponent-cards')), findsOneWidget);
    expect(find.byKey(const ValueKey('toggle-last-trick')), findsOneWidget);
    expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
    expect(humanCards(), findsNWidgets(5));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('partner-hand')),
        matching: find.byType(PlayingCardView),
      ),
      findsNWidgets(5),
    );
    expect(find.textContaining('Prendre '), findsNothing);
    expect(find.text('Passer'), findsNothing);

    await tapVisible(tester, find.byKey(const ValueKey('turned-card')));

    expect(find.text('Votre choix'), findsOneWidget);
    expect(find.textContaining('Prendre '), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);

    await tapVisible(tester, find.text('Prendre'));

    expect(find.byKey(const ValueKey('trump-badge')), findsOneWidget);
    expect(find.byKey(const ValueKey('dealer-chip')), findsOneWidget);
    expect(find.text('Preneur : Vous *'), findsOneWidget);
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

    await tapVisible(
      tester,
      find.byKey(const ValueKey('toggle-opponent-cards')),
    );

    final partnerCardsAfter = tester
        .widgetList<PlayingCardView>(opponentCards('partner-hand'))
        .toList();
    expect(partnerCardsAfter, isNotEmpty);
    expect(partnerCardsAfter.every((card) => !card.faceDown), isTrue);

    expect(find.byKey(const ValueKey('toggle-opponent-cards')), findsOneWidget);
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
    await tester.pumpWidget(const BeloteApp(randomizeDealerSeat: false));

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
              showLastTrick: false,
              onToggleLastTrick: () {},
              onStartNextRound: () {},
              onToggleOpponentCards: () {},
              showOpponentCardsActionLabel: 'Voir les cartes des joueurs',
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
              showLastTrick: false,
              onToggleLastTrick: () {},
              onStartNextRound: () {},
              onToggleOpponentCards: () {},
              showOpponentCardsActionLabel: 'Voir les cartes des joueurs',
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
              showLastTrick: false,
              onToggleLastTrick: () {},
              onStartNextRound: () {},
              onToggleOpponentCards: () {},
              showOpponentCardsActionLabel: 'Voir les cartes des joueurs',
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

  testWidgets('shows the last trick in the middle of the table', (
    WidgetTester tester,
  ) async {
    var showLastTrick = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
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
                            card: BeloteCard(
                              suit: Suit.clubs,
                              rank: Rank.queen,
                            ),
                          ),
                          PlayedCard(
                            player: PlayerSeat.partner,
                            card: BeloteCard(
                              suit: Suit.spades,
                              rank: Rank.king,
                            ),
                          ),
                          PlayedCard(
                            player: PlayerSeat.rightOpponent,
                            card: BeloteCard(
                              suit: Suit.diamonds,
                              rank: Rank.ace,
                            ),
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
                  showLastTrick: showLastTrick,
                  onToggleLastTrick: () {
                    setState(() {
                      showLastTrick = !showLastTrick;
                    });
                  },
                  onStartNextRound: () {},
                  onToggleOpponentCards: () {},
                  showOpponentCardsActionLabel: 'Voir les cartes des joueurs',
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('last-trick-display')), findsNothing);

    await tapVisible(tester, find.byKey(const ValueKey('toggle-last-trick')));

    expect(find.byKey(const ValueKey('last-trick-display')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('trick-card-leftOpponent-clubs-queen')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('trick-card-partner-spades-king')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('trick-card-rightOpponent-diamonds-ace')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('trick-card-human-hearts-ace')),
      findsOneWidget,
    );
  });
}
