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
- Debut de pli jouable : apres la prise d'atout, le joueur courant est affiche,
  les cartes jouables du joueur humain sont cliquables et la carte posee apparait
  dans le pli en cours.
- Les adversaires jouent automatiquement pour completer un pli, le gagnant est
  calcule selon l'atout et la couleur demandee, puis il devient joueur courant.
- Les cartes jouables respectent les premieres contraintes de pli : suivre la
  couleur demandee, couper si necessaire, defausser si le partenaire est maitre
  et monter a l'atout quand c'est possible.
- Une manche peut aller jusqu'aux 8 plis, avec suivi des plis remportes par
  equipe et detection de fin de manche.
- Premier calcul de points de manche : points des cartes gagnees et bonus de
  10 points pour le dernier pli.
- Validation du contrat preneur ajoutee : contrat reussi a partir de 82 points,
  chute a 162 points pour la defense et capot a 252 points.
- Score de partie cumule entre les manches, affichage du score courant,
  nouvelle manche apres score et detection du score cible de 501 points.
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

Derniere verification effectuee apres l'ajout du score de partie :
`dart format lib test`, `flutter test test/game/game_state_test.dart`,
`flutter test test/widget_test.dart`, `flutter test` et `flutter analyze`
passent.

## Documentation

- `docs/specifications-belote.md` : specification fonctionnelle de la V1.
- `docs/installation-flutter.md` : installation de Flutter et des outils.
- `docs/ide/intellij-flutter.md` : configuration IntelliJ pour lancer le Web.

## Prochaine reprise

Prochaine etape recommandee : ajouter l'affichage clair du vainqueur de partie
et affiner le flux de fin de partie avant d'ajouter belote/rebelote.
