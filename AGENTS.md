# Repository Guidelines

## Project Structure & Module Organization

This is a Flutter/Dart project for a Belote mobile game, currently developed Web-first. Application code lives in `lib/`, with the entry point at `lib/main.dart`. Game-domain logic is grouped under `lib/game/`, for example `lib/game/cards/`. Tests mirror the source layout under `test/`, with widget coverage in `test/widget_test.dart` and card/deck tests in `test/game/`. Platform wrappers are in `android/`, `ios/`, and `web/`. Project notes are in `docs/`.

## Build, Test, and Development Commands

- `flutter pub get`: install Dart and Flutter dependencies from `pubspec.yaml`.
- `flutter run -d chrome`: run the app locally in Chrome, the primary development target.
- `flutter test`: run all unit and widget tests.
- `flutter analyze`: run static analysis using the configured Flutter lint rules.
- `dart format lib test`: format Dart source and tests before submitting changes.

## Coding Style & Naming Conventions

Use Dart defaults: two-space indentation, trailing commas for readable multi-line Flutter and test code, and `dart format` for layout. The project includes `package:flutter_lints/flutter.yaml` through `analysis_options.yaml`; fix analyzer warnings rather than suppressing them unless there is a narrow, documented reason. Use `PascalCase` for classes and enums, `camelCase` for variables, functions, and getters, and `snake_case.dart` for file names. Keep game rules under `lib/game/` rather than embedding them in widgets.

## Testing Guidelines

Use `flutter_test` for both unit and widget tests. Place tests next to the relevant domain area under `test/`, such as `test/game/card_test.dart`. Prefer descriptive test names that state behavior, for example `deals four hands of eight cards without losing cards`. Add or update tests for changes to card values, deck creation, dealing, UI behavior, or future game-state rules. Run `flutter test` and `flutter analyze` before opening a pull request.

## Commit & Pull Request Guidelines

Existing commits use short imperative summaries, such as `Initialise Flutter belote app` and `Document current project state`. Continue that style: start with a verb, keep the subject concise, and describe one logical change. Pull requests should include a summary, tests run, and screenshots or recordings for visible UI changes. Link related issues or documentation updates, especially changes tied to `docs/specifications-belote.md`.

## Documentation & Configuration Notes

Keep `README.md` focused on current project status and quick start instructions. Put detailed setup or product rules in `docs/`. Do not commit generated build outputs from `build/`, local IDE state, secrets, or machine-specific configuration.
