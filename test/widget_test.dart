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

  testWidgets('opens a second bidding round after everyone passes once', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BeloteApp());

    await tapVisible(tester, find.text('Nouvelle partie'));
    await tapVisible(tester, find.byKey(const ValueKey('turned-card')));

    expect(find.text('Votre choix'), findsOneWidget);
    await tapVisible(tester, find.text('Passer'));

    expect(find.textContaining('Atout : 2e tour'), findsNWidgets(2));
    expect(
      find.text('Premier tour passe. Choisissez une autre couleur.'),
      findsOneWidget,
    );
    expect(find.textContaining('Prendre '), findsNothing);
    expect(find.text('Passer'), findsNothing);

    await tapVisible(tester, find.byKey(const ValueKey('turned-card')));

    expect(find.text('Votre choix'), findsOneWidget);
    expect(
      find.textContaining('Choisissez une autre couleur que'),
      findsOneWidget,
    );
    expect(find.text('Passer'), findsOneWidget);
    expect(find.textContaining('Prendre '), findsNWidgets(3));

    await tapVisible(tester, find.textContaining('Prendre ').first);

    expect(find.text('Preneur : Vous'), findsOneWidget);
    expect(find.text('Joueur courant : Vous'), findsOneWidget);
    expect(humanCards(), findsNWidgets(8));
    expect(find.textContaining('Prendre '), findsNothing);
    expect(find.text('Passer'), findsNothing);
  });
}
