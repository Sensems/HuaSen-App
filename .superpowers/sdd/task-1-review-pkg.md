# Review package — Task 1 (working tree, no commits)

## Commits
(none — working-tree only per repo rules)

## Stat
?? .github/workflows/ci.yml

## Diff

### File: .github/workflows/ci.yml (new)
```yaml
name: CI

on:
  pull_request:
  push:
    branches: [master]

jobs:
  analyze:
    name: Analyze & Test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Pub get
        run: flutter pub get

      - name: Code generation
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Analyze
        run: flutter analyze

      - name: Test
        run: flutter test

  build-apk:
    name: Build APK
    needs: analyze
    if: github.event_name == 'push' && github.ref == 'refs/heads/master'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Pub get
        run: flutter pub get

      - name: Code generation
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Build release APK
        run: flutter build apk --release

      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
          retention-days: 14
```
