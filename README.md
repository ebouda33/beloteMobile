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
- Bouton `Nouvelle partie` actif : il melange le paquet, distribue quatre mains
  et affiche une main aleatoire de 8 cartes au joueur.
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

Derniere verification effectuee apres l'affichage d'une main aleatoire :
`flutter test` et `flutter analyze` passent.

## Documentation

- `docs/specifications-belote.md` : specification fonctionnelle de la V1.
- `docs/installation-flutter.md` : installation de Flutter et des outils.
- `docs/ide/intellij-flutter.md` : configuration IntelliJ pour lancer le Web.

## Prochaine reprise

Prochaine etape recommandee : introduire un objet d'etat de partie qui conserve
les quatre mains distribuees, le joueur humain et les adversaires locaux, puis
preparer le choix de l'atout.
