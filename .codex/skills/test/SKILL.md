---
name: test
description: Use this skill after generating or modifying code in this project to decide which automated tests to create or update, run the appropriate test command, and report the result clearly.
---

# Test Workflow

Use this skill after every code change in the Belote mobile project.

## Core rule

After generating or modifying code:

1. Identify the stack currently present in the repository.
2. Add or update focused tests for the changed behavior when the change affects logic.
3. Run the narrowest reliable test command first.
4. Run the broader project test command before final response when feasible.
5. Report the exact command used and whether it passed or failed.

## Stack detection

Use the first matching project type:

- Flutter/Dart: `pubspec.yaml` exists.
- iOS Swift/Xcode: `.xcodeproj` or `.xcworkspace` exists.
- Android Gradle: `build.gradle`, `build.gradle.kts`, or `settings.gradle` exists.
- Other stack: inspect existing test configuration before choosing commands.

## Commands

For Flutter:

```sh
flutter test
```

For a single Dart test file:

```sh
flutter test test/path/to_test.dart
```

For iOS Swift/Xcode:

```sh
xcodebuild test -scheme <SchemeName> -destination 'platform=iOS Simulator,name=iPhone 15'
```

Use the repository's actual scheme and simulator if different.

For Android Gradle:

```sh
./gradlew test
```

For a specific Gradle module when applicable:

```sh
./gradlew :module:test
```

## If tests cannot run

If the project is not initialized yet, say that no executable test command exists yet.
Still describe which tests should be added with the first implementation.

If dependencies are missing or the environment blocks execution, report:

- the command attempted;
- the failure reason;
- the next concrete fix.

## Expected final report

Keep the test report short:

- changed behavior tested;
- command run;
- result;
- any remaining test gap.
