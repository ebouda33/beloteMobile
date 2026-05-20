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
