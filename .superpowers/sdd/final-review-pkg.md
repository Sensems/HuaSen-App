# Final review package — GitHub Actions CI + APK

## Scope
Working-tree changes for this feature (no commits):
- `.github/workflows/ci.yml` (new)
- `docs/superpowers/specs/2026-07-25-github-actions-ci-apk-design.md` (new)
- `docs/superpowers/plans/2026-07-25-github-actions-ci-apk.md` (new)

## Spec
docs/superpowers/specs/2026-07-25-github-actions-ci-apk-design.md

## Plan
docs/superpowers/plans/2026-07-25-github-actions-ci-apk.md

## Minor backlog from Task 1
- First GitHub Actions run still needed to validate Android toolchain on runner
- build-apk duplicates setup steps by design

## Workflow file

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
