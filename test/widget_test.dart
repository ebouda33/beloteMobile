import 'package:belote_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

    await tester.tap(find.text('Nouvelle partie'));
    await tester.pump();

    expect(find.text('Votre main'), findsOneWidget);
    expect(find.byType(Chip), findsNWidgets(5));
    expect(find.text('Atout : a choisir'), findsOneWidget);
    expect(find.textContaining('Carte retournee : '), findsOneWidget);
    expect(find.textContaining('Prendre '), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);

    await tester.tap(find.textContaining('Prendre '));
    await tester.pump();

    expect(find.textContaining('Atout : '), findsOneWidget);
    expect(find.text('Atout : a choisir'), findsNothing);
    expect(find.textContaining('Prendre '), findsNothing);
    expect(find.text('Passer'), findsNothing);
  });

  testWidgets('passes on the turned trump card', (WidgetTester tester) async {
    await tester.pumpWidget(const BeloteApp());

    await tester.tap(find.text('Nouvelle partie'));
    await tester.pump();

    await tester.tap(find.text('Passer'));
    await tester.pump();

    expect(find.text('Atout : a choisir'), findsOneWidget);
    expect(
      find.text('Vous avez passe. En attente des autres joueurs.'),
      findsOneWidget,
    );
    expect(find.textContaining('Prendre '), findsNothing);
    expect(find.text('Passer'), findsNothing);
  });
}
