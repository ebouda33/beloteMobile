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
- Encheres en deux tours sur la carte retournee : premier tour sur la couleur
  proposee, puis second tour sur les 3 autres couleurs si tout le monde passe.
- La carte retournee est centree au milieu du tapis de jeu pendant la phase de
  choix de l'atout.
- Quand l'atout est pris, les mains sont completees a 8 cartes, triees par
  couleur puis par force dans la couleur, le preneur est conserve et affiche.
- Quand les deux tours d'encheres echouent, une nouvelle manche est redonnee
  avec rotation du premier joueur.
- Debut de pli jouable : apres la prise d'atout, le joueur courant est affiche,
  les cartes jouables du joueur humain sont cliquables et la carte posee apparait
  dans le pli en cours.
- La carte retournee se clique pour ouvrir une confirmation `Votre choix` avec
  les actions `Prendre` et `Passer`.
- Le donneur est choisi aleatoirement au debut. Toute la rotation suit le meme
  sens anti-horaire sur le tapis : donne, prise, jeu de la carte et rotation
  du donneur d'une manche a l'autre.
- La regle canonique de rotation est figee dans `docs/belote-turn-order.md`.
- Une batterie de tests couvre aussi le deuxieme tour d'enchere apres passe
  generale, sur les quatre donneurs possibles.
- Plateau de jeu visuel ajoute : tapis central, vraies cartes, mains adverses
  cachees et carte retournee affichee au centre du tapis pendant le choix de
  l'atout.
- Le preneur est affiche sur le tapis central avec un badge dedie, et l'atout
  est montre par une icone compacte plutot que par un libelle textuel.
- Option visuelle ajoutee pour reveler ou masquer les cartes des adversaires
  depuis la barre du haut.
- Quand les cartes adverses sont revelees ou sur le tapis, leur couleur reste
  au centre de la carte et la valeur reste dans les coins.
- Les cartes cachees des adversaires ne sont plus rendues en eventail: elles
  sont posees en support discret et stable autour du tapis pour rester
  lisibles.
- Les adversaires jouent automatiquement pour completer un pli, le gagnant est
  calcule selon l'atout et la couleur demandee, puis il devient joueur courant.
- Au jeu de la carte, `Debutant` garde un choix simple de carte jouable, tandis
  que `Expert` evite d'ouvrir un pli avec l'atout quand une carte hors atout
  reste possible et preserve aussi l'atout quand une carte hors atout peut
  encore gagner le pli ou quand il doit se defausser.
- Quand `Expert` mene un pli, il privilegie la couleur non-atout la plus fournie
  plutot que la carte la plus faible prise isolément.
- Quand `Expert` peut encaisser un as sans risque apparent, il le joue au lieu
  de le conserver inutilement.
- Quand `Expert` ne peut pas gagner le pli, il suit la couleur demandee avec la
  carte la moins couteuse, puis joue le plus petit atout gagnant si un coup est
  obligatoire.
- Le niveau `Expert` affine aussi ses choix avec le suivi des cartes sorties,
  les plis deja tombes et la lecture du partenaire pour mieux orienter
  l'entame et la defausse.
- Les cartes jouables respectent les premieres contraintes de pli : suivre la
  couleur demandee, couper si necessaire, defausser si le partenaire est maitre
  et monter a l'atout quand c'est possible.
- Les cartes impossibles a jouer sont assombries et les cartes jouables se
  soulevent au survol.
- Un selecteur `Debutant / Expert` permet de choisir le niveau des adversaires
  locaux depuis l'ecran d'accueil.
- La zone score est simplifiee en tableau avec deux colonnes `EUX` / `NOUS`,
  une ligne par manche et un total automatique en bas.
- Le carnet de score du tapis a ete compacte et clarifie pour mieux separer
  les manches, le total, et la lecture generale de la table.
- Une manche peut aller jusqu'aux 8 plis, avec suivi des plis remportes par
  equipe et detection de fin de manche.
- Premier calcul de points de manche : points des cartes gagnees et bonus de
  10 points pour le dernier pli.
- Validation du contrat preneur ajoutee : contrat reussi a partir de 82 points,
  chute a 162 points pour la defense et capot a 252 points.
- Score de partie cumule entre les manches, affichage du score courant,
  nouvelle manche apres score et detection du score cible de 501 points.
- Affichage du vainqueur de partie quand le score cible est atteint, avec
  fermeture du flux de nouvelle manche et recapitulatif du score final.
- Bonus belote/rebelote de 20 points ajoute automatiquement quand le meme
  equipe joue les deux honneurs d'atout.
- Skill local `finish-step-docs` ajoute pour mettre a jour les docs quand une
  etape est terminee.

Le jeton `D` du tapis indique le donneur. Les actions suivent ensuite toujours
la meme rotation anti-horaire: prise, distribution complementaire, entame du
pli et rotation du donneur a la manche suivante.

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

Prochaine etape recommandee :

1. renforcer encore l'intelligence des robots sur la lecture du partenaire et
   des fins de manche ;
2. preparer l'ajout de nouvelles annonces ou variantes.
