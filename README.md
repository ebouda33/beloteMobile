# Belote Mobile

Application Flutter pour construire un jeu de belote local, en commencant par
la cible Web afin de valider rapidement le moteur et l'interface.

## Etat actuel

- Projet Flutter initialise.
- Cibles Web, iOS et Android presentes dans le depot.
- Configuration IntelliJ partagee pour lancer le Web sans script shell.
- Premier modele de cartes de belote implemente.
- Tests de base sur le paquet, les couleurs, les valeurs, la distribution et
  l'ecran d'accueil.
- Bouton `Nouvelle partie` actif : il melange le paquet, distribue 5 cartes par
  joueur, retourne une carte du paquet et affiche la main du joueur.
- Debut d'etat de partie local : les quatre mains initiales sont conservees, le
  joueur humain est identifie et la carte retournee propose l'atout.
- Encheres simples sur la carte retournee : le joueur peut prendre ou passer.
- Quand l'atout est pris, les mains sont completees a 8 cartes, le preneur est
  conserve et affiche.
- Quand tous les joueurs passent, l'interface propose de redistribuer.
- Skill local `finish-step-docs` ajoute pour mettre a jour les docs quand une
  etape est terminee.

## Lancer le projet

Depuis IntelliJ IDEA ou Android Studio, utiliser la configuration :

```text
Flutter Web
```

Elle lance `lib/main.dart` sur Chrome avec `-d chrome`.

Depuis un terminal :

```sh
flutter run -d chrome
```

## Tests

```sh
flutter test
```

Derniere verification effectuee apres l'ajout de la prise, du refus et de la
redistribution :
`dart format lib test`, `flutter test test/game/game_state_test.dart`,
`flutter test` et `flutter analyze` passent.

## Documentation

- `docs/specifications-belote.md` : specification fonctionnelle de la V1.
- `docs/installation-flutter.md` : installation de Flutter et des outils.
- `docs/ide/intellij-flutter.md` : configuration IntelliJ pour lancer le Web.

## Prochaine reprise

Prochaine etape recommandee : demarrer le premier pli apres la prise de l'atout
en ajoutant le joueur courant, les cartes jouables et la pose d'une carte.
