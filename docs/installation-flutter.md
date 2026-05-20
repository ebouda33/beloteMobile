# Installation Flutter

Ce document explique comment installer Flutter pour travailler sur le projet
Belote Mobile.

Ordre de developpement du projet :

1. Web pour simplifier le demarrage et les premiers tests.
2. iOS.
3. Android.

## macOS

### Prerequis

- macOS recent.
- Homebrew installe.
- Chrome pour lancer la version Web.
- Xcode complet plus tard pour compiler et lancer l'application iOS.
- Android Studio plus tard pour compiler et lancer l'application Android.

Verifier Homebrew :

```sh
brew --version
```

### Installer Flutter

```sh
brew install --cask flutter
```

Verifier l'installation :

```sh
flutter --version
```

Verifier que Flutter peut lancer la version Web :

```sh
flutter doctor
flutter devices
```

### Installer CocoaPods

CocoaPods est necessaire pour les dependances iOS Flutter.

```sh
brew install cocoapods
```

Verifier :

```sh
pod --version
```

### Installer Xcode pour iOS

Installer Xcode depuis l'App Store ou depuis Apple Developer.

Apres installation :

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

Verifier l'etat Flutter :

```sh
flutter doctor
```

### Installer Android plus tard

Pour Android, installer Android Studio, puis lancer Android Studio une premiere
fois pour installer le SDK Android.

Ensuite verifier :

```sh
flutter doctor
```

Si le SDK Android est installe dans un dossier non standard :

```sh
flutter config --android-sdk /chemin/vers/android-sdk
```

## Linux

### Prerequis

- Git.
- Curl ou wget.
- Unzip.
- Android Studio pour compiler Android.

Exemple Debian/Ubuntu :

```sh
sudo apt update
sudo apt install git curl unzip xz-utils zip libglu1-mesa
```

### Installer Flutter manuellement

Creer un dossier pour les outils de developpement :

```sh
mkdir -p ~/development
cd ~/development
```

Telecharger Flutter depuis le site officiel :

```sh
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_stable.tar.xz
tar xf flutter_linux_stable.tar.xz
```

Ajouter Flutter au `PATH`.

Pour Bash :

```sh
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Pour Zsh :

```sh
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Verifier :

```sh
flutter --version
flutter doctor
```

### Installer Android Studio

Installer Android Studio depuis le site officiel, puis l'ouvrir une premiere
fois pour installer :

- Android SDK ;
- Android SDK Platform ;
- Android SDK Command-line Tools ;
- Android Emulator si besoin.

Verifier ensuite :

```sh
flutter doctor
```

Accepter les licences Android :

```sh
flutter doctor --android-licenses
```

## Verification commune

La commande de reference est :

```sh
flutter doctor
```

L'objectif minimal pour demarrer ce projet :

- Flutter valide ;
- Chrome ou un navigateur Web detecte ;
- iOS valide sur macOS quand on passera au developpement iPhone ;
- Android valide quand on commencera la version Android ;
- CocoaPods valide sur macOS.

## Probleme courant

Si `flutter` n'est pas trouve :

```sh
which flutter
```

Si la commande ne retourne rien, Flutter n'est pas dans le `PATH`.

Sur macOS avec Homebrew, le chemin attendu est generalement :

```sh
/opt/homebrew/bin/flutter
```

Sur Linux avec l'installation manuelle, le chemin attendu est generalement :

```sh
$HOME/development/flutter/bin/flutter
```
