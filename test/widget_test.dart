import 'package:belote_mobile/game/cards/belote_card.dart';
import 'package:belote_mobile/main.dart';
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
    expect(humanCards(), findsNWidgets(5));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('partner-hand')),
        matching: find.byType(PlayingCardView),
      ),
      findsNWidgets(5),
    );
    expect(find.text('Atout : a choisir'), findsOneWidget);
    expect(find.textContaining('Carte retournee : '), findsOneWidget);
    expect(find.textContaining('Prendre '), findsNothing);
    expect(find.text('Passer'), findsNothing);

    await tapVisible(tester, find.byKey(const ValueKey('turned-card')));

    expect(find.text('Votre choix'), findsOneWidget);
    expect(find.textContaining('Prendre '), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);

    await tapVisible(tester, find.text('Prendre'));

    expect(find.text('Atout : a choisir'), findsNothing);
    expect(find.text('Preneur : Vous'), findsOneWidget);
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

    expect(find.text('Votre choix'), findsNothing);
    expect(find.byKey(const ValueKey('game-table')), findsOneWidget);
  });
}
