### Task 1: Add `ci.yml` workflow

**Files:**
- Create: `.github/workflows/ci.yml`

**Interfaces:**
- Consumes: existing Flutter project at repo root; Android release already uses debug `signingConfig`
- Produces: GitHub Actions workflow named `CI` with jobs `analyze` and `build-apk`

## Global Constraints (binding)

- Work only on `master` (no feature branches / worktrees).
- Do **not** create git commits.
- Workflow file path: `.github/workflows/ci.yml` only.
- Triggers: `pull_request` (any) + `push` to `master`.
- CI order: `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs` → `flutter analyze` → `flutter test`.
- APK job only when `github.event_name == 'push' && github.ref == 'refs/heads/master'`.
- Build command: `flutter build apk --release` with **no** `--dart-define`.
- Artifact name: `app-release-apk`; path: `build/app/outputs/flutter-apk/app-release.apk`; `retention-days: 14`.
- Flutter: `channel: stable` via `subosito/flutter-action@v2`.
- No keystore secrets, no GitHub Release, no Windows/iOS jobs, no China mirrors.

- [ ] **Step 1: Create workflow directory and file**

Create `.github/workflows/ci.yml` with exactly this content:

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

- [ ] **Step 2: Verify file contents against Global Constraints**

Check that the file on disk:
1. Triggers both `pull_request` and `push` to `master`.
2. Has `build-apk.if` exactly: `github.event_name == 'push' && github.ref == 'refs/heads/master'`.
3. Has `needs: analyze` on `build-apk`.
4. Runs build_runner before analyze/test and before APK build.
5. Uses `flutter build apk --release` with no dart-define.
6. Uploads `app-release-apk` from `build/app/outputs/flutter-apk/app-release.apk` with retention 14.

Run (PowerShell):

```powershell
Test-Path .github/workflows/ci.yml
Select-String -Path .github/workflows/ci.yml -Pattern "build-apk|flutter analyze|flutter test|app-release-apk|dart-define|master"
```

Expected: file exists; matches show analyze/test/apk/master; **no** `dart-define` match.

- [ ] **Step 3: Skip commit**

Do not commit. Report Status DONE with files changed only.
