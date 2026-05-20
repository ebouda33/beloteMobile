# Configuration IntelliJ pour Flutter Web

## Plugin Flutter

Le projet utilise une configuration IntelliJ native Flutter pour lancer la
version Web sans script shell.

Si l'IDE affiche `Unknown run configuration type FlutterRunConfigurationType`,
le plugin Flutter n'est pas installe ou pas active.

Dans IntelliJ IDEA ou Android Studio :

1. Ouvrir `Settings`.
2. Aller dans `Plugins`.
3. Chercher `Flutter` dans le Marketplace.
4. Installer le plugin `Flutter`.
5. Accepter l'installation du plugin `Dart` si l'IDE le propose.
6. Redemarrer IntelliJ.
7. Verifier dans `Settings > Languages & Frameworks > Flutter` que le SDK pointe vers :

```text
/opt/homebrew/share/flutter
```

## Lancer le Web depuis l'IDE

Le projet contient une configuration partagee :

```text
Flutter Web
```

Elle lance :

```text
lib/main.dart -d chrome
```

Pour l'utiliser :

1. Selectionner `Flutter Web` dans le menu des configurations en haut de l'IDE.
2. Verifier que le device est `Chrome (web)`.
3. Cliquer sur `Run`.

Si la configuration n'apparait pas encore, ouvrir `Run > Edit Configurations...`,
puis recharger les configurations du projet ou recreer une configuration
`Flutter` avec :

- `Dart entrypoint` : `lib/main.dart`
- `Additional run args` : `-d chrome`

## Etat de l'ecran d'accueil

Au premier lancement Web, l'ecran affiche un bouton `Nouvelle partie`.
Il est actuellement grise parce que le code le declare avec `onPressed: null`.

Cet etat est volontaire pour le premier niveau du projet : l'interface existe,
mais le demarrage de partie n'est pas encore relie au moteur de jeu.

La prochaine implementation devra remplacer ce placeholder par une action qui :

1. cree une nouvelle partie locale ;
2. melange et distribue le paquet ;
3. affiche la main du joueur humain ;
4. active les premieres actions de jeu.

## Commandes utiles

Verifier Flutter :

```sh
flutter doctor
```

Lancer le Web directement :

```sh
flutter run -d chrome
```

Lancer les tests :

```sh
flutter test
```
