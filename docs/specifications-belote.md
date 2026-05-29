# Specifications - Jeu de belote mobile

## Objectif

Construire un jeu de belote avec Flutter, d'abord jouable sur le Web pour
simplifier le demarrage et les premiers tests, puis sur iOS, puis sur Android.
La premiere version est locale uniquement : pas de reseau, pas de compte
utilisateur, pas de matchmaking.

La specification doit rester evolutive afin d'ajouter plus tard :

- le mode reseau ;
- plusieurs variantes de regles ;
- une meilleure intelligence artificielle ;
- des statistiques et historiques de parties.

Ordre des plateformes :

1. Web
2. iOS
3. Android

## Etat d'avancement

Premier niveau valide :

- squelette Flutter cree ;
- lancement Web depuis l'IDE configure sans script shell ;
- documentation d'installation et de configuration IDE ajoutee ;
- modele de cartes et paquet de 32 cartes cree ;
- distribution initiale de 5 cartes par joueur implementee ;
- carte du paquet retournee pour proposer l'atout ;
- bouton `Nouvelle partie` actif dans l'interface ;
- affichage d'une main aleatoire de 5 cartes pour le joueur humain ;
- etat de partie local ajoute avec les quatre mains initiales, la carte retournee,
  le joueur humain et la phase de choix de l'atout ;
- refus de la carte retournee ajoute ;
- prise de la carte retournee ajoutee avec distribution complete a 8 cartes par
  joueur, tri des mains avant le premier pli, conservation du preneur et
  affichage de l'atout ;
- cas ou tous les joueurs passent gere avec une action de redistribution ;
- debut de pli ajoute avec joueur courant, cartes jouables pour le joueur humain
  et affichage de la carte posee dans le pli en cours ;
- tapis de jeu central ajoute avec vraies cartes visibles, mains adverses cachees
  et carte retournee affichee au centre pendant le choix de l'atout ;
- clic sur la carte retournee ajoute pour ouvrir une confirmation `Votre choix`
  avec les actions `Prendre` et `Passer` ;
- jeu automatique des adversaires ajoute pour completer le pli courant ;
- gagnant du pli determine selon l'atout et la couleur demandee, puis defini
  comme prochain joueur courant ;
- cartes jouables renforcees avec suivi de couleur, coupe obligatoire, defausse
  autorisee si le partenaire est maitre et montee a l'atout quand possible ;
- enchainement des 8 plis d'une manche ajoute avec suivi des plis remportes par
  equipe et detection de fin de manche ;
- premier calcul des points de manche ajoute avec points des cartes et bonus de
  10 points pour le dernier pli ;
- validation du contrat preneur ajoutee avec reussite a partir de 82 points,
  chute attribuant 162 points a la defense et capot a 252 points ;
- score de partie cumule entre les manches, nouvelle manche apres score et
  detection du score cible de 501 points ajoutes ;
- affichage du vainqueur de partie quand 501 points est atteint, avec
  fermeture du flux de nouvelle manche et recapitulatif du score final ;
- belote/rebelote ajoutee avec bonus de 20 points pour l'equipe qui joue les
  deux honneurs d'atout ;
- tests de base ajoutes et executes avec succes.

Le premier etat de partie local est en place : une nouvelle partie melange le
paquet, distribue 5 cartes par siege de joueur, retourne une carte du paquet,
puis affiche la main du joueur humain. La couleur de la carte retournee est
l'atout propose. Le joueur humain peut prendre cette couleur, ce qui complete
les mains et demarre la phase de pli, ou passer. Pour la V1 actuelle, les autres
joueurs passent automatiquement apres le refus du joueur humain, puis
l'interface propose de redistribuer. Quand le joueur humain prend l'atout, il
devient le premier joueur courant de la phase de pli. Ses cartes sont jouables
dans l'interface, la carte posee est retiree de sa main, ajoutee au pli en cours
et le tour avance au joueur suivant. Les adversaires peuvent ensuite jouer
automatiquement pour completer le pli courant. Le dernier pli complete reste
 visible dans l'interface avec son gagnant. La main du joueur humain est triee
 au moment de la prise, avant le premier pli, par couleur puis par force dans la
 couleur. La liste des cartes jouables limite
maintenant les actions invalides : suivre la couleur demandee si possible,
couper quand il faut, pouvoir defausser si le partenaire est maitre du pli et
monter a l'atout quand une carte plus forte est disponible. La manche peut
desormais aller jusqu'a 8 plis. Les plis remportes sont conserves par equipe,
la fin de manche est detectee, puis les points des cartes gagnees sont calcules
avec le bonus de 10 points du dernier pli. Le score applique de la manche tient
compte de l'equipe preneuse : si elle atteint au moins 82 points, les points de
cartes sont conserves ; en cas de chute, la defense marque 162 points ; en cas
de capot, l'equipe qui gagne les 8 plis marque 252 points. Le score applique de
chaque manche est maintenant ajoute au score de partie. Une nouvelle manche
peut etre lancee apres le score tant qu'aucune equipe n'a atteint 501 points.
Quand une equipe atteint 501 points, l'interface affiche clairement le
vainqueur de partie, un recapitulatif du score final, et n'expose plus l'action
de nouvelle manche.
Le bonus belote/rebelote est calcule automatiquement quand la meme equipe joue
le roi et la dame d'atout, puis il est ajoute au score de manche et affiche
dans le recapitulatif.

La presentation visuelle du tapis repose desormais sur de vraies cartes :
la main humaine reste visible et cliquable, les mains adverses sont montrees
dos caches, et la carte retournee est placee au centre du tapis pendant la
phase de choix de l'atout. Cette carte ouvre maintenant une confirmation
`Votre choix` avec deux actions explicites: `Prendre` et `Passer`.

Prochaine reprise :

1. affiner les actions disponibles en fin de partie si besoin ;
2. preparer l'ajout de nouvelles annonces ou variantes ;
3. ajouter des tests de score de partie avec plusieurs manches.

## Principes de conception

- La logique de jeu doit etre separee de l'interface mobile.
- Le moteur de jeu doit pouvoir fonctionner sans dependance a l'UI.
- Les joueurs IA de la V1 doivent pouvoir etre remplaces plus tard par des joueurs reseau.
- Les regles doivent etre testables automatiquement.
- L'interface Web doit servir de premiere surface de validation.
- L'interface doit rester pensee mobile des le depart : lisible, tactile, fluide.

## Variante cible V1

La V1 part sur une belote classique simplifiee.

Decisions initiales :

- 4 joueurs.
- 2 equipes de 2 joueurs.
- 1 joueur humain.
- 3 joueurs controles par une IA locale.
- Partie locale uniquement.
- Distribution automatique.
- Jeu en manches successives.
- Score cumule entre les equipes.
- Score cible : 501 points.
- Belote/rebelote activee des la V1.
- Autres annonces desactivees en V1.
- Capot gere des la V1.
- Defausse autorisee quand le partenaire est maitre du pli.
- Stack cible : Flutter.
- Plateforme de demarrage : Web.

Recommandation V1 :

- demarrer sans annonces complexes ;
- inclure belote/rebelote ;
- garder les encheres simples ;
- conserver le dix de der ;
- viser une partie jusqu'a 501 points.

## Cartes

Le jeu contient 32 cartes :

- couleurs : trefle, carreau, coeur, pique ;
- valeurs : 7, 8, 9, valet, dame, roi, 10, as.

Chaque carte doit etre modelisee par :

- une couleur ;
- une valeur ;
- un identifiant stable ;
- un libelle affichable.

## Ordre et valeur des cartes

Hors atout, ordre du plus fort au plus faible :

1. As
2. 10
3. Roi
4. Dame
5. Valet
6. 9
7. 8
8. 7

A l'atout, ordre du plus fort au plus faible :

1. Valet
2. 9
3. As
4. 10
5. Roi
6. Dame
7. 8
8. 7

Valeurs hors atout :

- As : 11
- 10 : 10
- Roi : 4
- Dame : 3
- Valet : 2
- 9, 8, 7 : 0

Valeurs a l'atout :

- Valet : 20
- 9 : 14
- As : 11
- 10 : 10
- Roi : 4
- Dame : 3
- 8, 7 : 0

## Deroulement d'une manche

Une manche suit ce cycle :

1. Melanger les 32 cartes.
2. Distribuer 5 cartes a chaque joueur.
3. Retourner la carte suivante du paquet : sa couleur propose l'atout.
4. Permettre aux joueurs de prendre ou passer.
5. Completer la distribution jusqu'a 8 cartes par joueur quand l'atout est pris.
6. Jouer 8 plis.
7. Calculer les points de chaque equipe.
8. Ajouter le score de la manche au score total.
9. Demarrer une nouvelle manche si le score cible n'est pas atteint.

## Encheres V1

Objectif : avoir une premiere version jouable sans complexifier trop tot.

Option recommandee :

- proposer une phase d'enchere simple ;
- chaque joueur peut passer ou prendre la couleur de la carte retournee ;
- si un joueur prend, la couleur de la carte retournee devient l'atout ;
- si tout le monde passe, redistribuer.

Les encheres avancees, coinche, surcoinche et contrats chiffres sont hors scope V1.

## Regles de jeu d'une carte

Pour chaque pli :

- le premier joueur pose une carte librement ;
- les autres joueurs doivent suivre la couleur demandee si possible ;
- si le joueur ne peut pas suivre, il doit couper a l'atout si possible ;
- si le partenaire du joueur est actuellement maitre du pli, le joueur peut defausser au lieu de couper ;
- si un atout est deja joue et que le joueur doit couper, il doit monter si possible ;
- si le joueur ne peut ni suivre ni couper, il peut jouer n'importe quelle carte.

## Gain d'un pli

Le gagnant du pli est :

- la carte d'atout la plus forte si au moins un atout a ete joue ;
- sinon la carte la plus forte dans la couleur demandee.

Le gagnant du pli ouvre le pli suivant.

## Score d'une manche

Regles initiales :

- additionner les valeurs des cartes gagnees par chaque equipe ;
- ajouter 10 points a l'equipe qui gagne le dernier pli ;
- ajouter 20 points pour belote/rebelote a l'equipe du joueur concerne ;
- attribuer un bonus de capot si une equipe gagne les 8 plis ;
- verifier si l'equipe preneuse a rempli son contrat ;
- si le contrat echoue, l'equipe adverse marque les points selon la regle choisie.

Belote/rebelote :

- un joueur possedant le roi et la dame d'atout peut annoncer belote/rebelote ;
- l'annonce vaut 20 points ;
- l'annonce appartient a l'equipe du joueur qui possede les deux cartes ;
- l'annonce doit etre declaree lors du jeu du roi et de la dame d'atout ;
- l'annonce ne concerne que l'atout.

Point a specifier avant implementation :

- score exact en cas de chute ;
- valeur exacte du capot dans la variante retenue ;
- arrondis eventuels ;
- moment exact d'affichage et de confirmation de belote/rebelote dans l'interface.

## Intelligence artificielle V1

L'IA V1 doit etre simple, deterministe autant que possible, et suffisante pour jouer.

Priorites :

- respecter les regles ;
- choisir une carte valide ;
- eviter les choix aleatoires quand une decision simple est possible.

Strategie minimale :

- si elle peut gagner le pli avec une carte peu couteuse, elle le fait ;
- si elle ne peut pas gagner, elle joue une carte faible ;
- elle garde les gros atouts quand ce n'est pas necessaire de les jouer ;
- aux encheres, elle prend si sa main contient assez de points ou de force dans une couleur.

Une IA plus forte viendra apres stabilisation du moteur.

## Interface V1

Ecrans et zones minimales :

- ecran de partie ;
- main du joueur humain ;
- cartes jouees au centre de la table ;
- score des deux equipes ;
- indication de l'atout ;
- indication du joueur courant ;
- actions disponibles : passer, prendre, jouer une carte, nouvelle manche.

L'interface doit empecher autant que possible les actions invalides.
La validation finale reste cependant dans le moteur de jeu.

## Tests attendus

Les tests doivent couvrir en priorite le moteur de jeu :

- creation du paquet de 32 cartes ;
- melange/distribution sans doublons ;
- ordre des cartes hors atout ;
- ordre des cartes a l'atout ;
- valeur des cartes ;
- validation des cartes jouables ;
- determination du gagnant d'un pli ;
- calcul des points d'un pli ;
- calcul du score d'une manche ;
- comportements simples de l'IA.

Apres chaque ajout de code, les tests pertinents doivent etre ajoutes ou mis a jour,
puis executes selon le skill `test`.

## Hors scope V1

- reseau ;
- comptes utilisateur ;
- matchmaking ;
- chat ;
- achats integres ;
- classements en ligne ;
- sauvegarde cloud ;
- variantes coinche/contree completes ;
- animations avancees ;
- tutoriel complet.

## Decisions ouvertes

- Niveau exact de fidelite aux regles familiales.
- Representation graphique des cartes : assets dedies ou cartes dessinees par l'UI.
- Score exact en cas de chute et valeur exacte du capot.
