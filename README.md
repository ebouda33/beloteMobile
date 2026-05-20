# Belote Mobile

Application Flutter pour construire un jeu de belote local, en commencant par
la cible Web afin de valider rapidement le moteur et l'interface.

## Etat actuel

- Projet Flutter initialise.
- Cibles Web, iOS et Android presentes dans le depot.
- Configuration IntelliJ partagee pour lancer le Web sans script shell.
- Premier modele de cartes de belote implemente.
- Tests de base sur le paquet, les couleurs, les valeurs et l'ecran d'accueil.
- Bouton `Nouvelle partie` visible mais volontairement desactive tant que le
  moteur de partie n'est pas branche a l'interface.

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

Derniere verification effectuee avant le premier commit : tous les tests
passent.

## Documentation

- `docs/specifications-belote.md` : specification fonctionnelle de la V1.
- `docs/installation-flutter.md` : installation de Flutter et des outils.
- `docs/ide/intellij-flutter.md` : configuration IntelliJ pour lancer le Web.

## Prochaine reprise

Prochaine etape recommandee : brancher le bouton `Nouvelle partie` sur un debut
d'etat de partie local, puis afficher une premiere main distribuee au joueur.
