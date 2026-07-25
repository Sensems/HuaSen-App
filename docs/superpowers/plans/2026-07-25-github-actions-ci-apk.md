# GitHub Actions CI + Android APK Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a single GitHub Actions workflow that runs Flutter analyze/test on PRs and `master`, then builds and uploads a debug-signed release APK on `master` pushes only.

**Architecture:** One workflow file (`.github/workflows/ci.yml`) with two jobs: `analyze` (always) and `build-apk` (`needs: analyze`, gated to `push` on `master`). Uses `subosito/flutter-action` on `ubuntu-latest`. No dart-define; project already signs release with debug keys in `android/app/build.gradle.kts`.

**Tech Stack:** GitHub Actions, Flutter stable, `actions/checkout`, `subosito/flutter-action@v2`, `actions/upload-artifact@v4`

## Global Constraints

- Work only on `master` (no feature branches / worktrees) per repo AGENTS.md.
- Do **not** create git commits unless the user explicitly asks (skip plan commit steps).
- Workflow file path: `.github/workflows/ci.yml` only (no other platform builds).
- Triggers: `pull_request` (any) + `push` to `master`.
- CI order: `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs` → `flutter analyze` → `flutter test`.
- APK job only when `github.event_name == 'push' && github.ref == 'refs/heads/master'`.
- Build command: `flutter build apk --release` with **no** `--dart-define`.
- Artifact name: `app-release-apk`; path: `build/app/outputs/flutter-apk/app-release.apk`; `retention-days: 14`.
- Flutter: `channel: stable` via `subosito/flutter-action@v2` (must satisfy `sdk: ^3.12.2`).
- No keystore secrets, no GitHub Release, no Windows/iOS jobs, no China mirrors.

## File Structure

| File | Responsibility |
|------|----------------|
| `.github/workflows/ci.yml` | Entire CI + APK pipeline |

---

### Task 1: Add `ci.yml` workflow

**Files:**
- Create: `.github/workflows/ci.yml`

**Interfaces:**
- Consumes: existing Flutter project at repo root; Android release already uses debug `signingConfig`
- Produces: GitHub Actions workflow named `CI` with jobs `analyze` and `build-apk`

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

---

## Spec coverage (self-review)

| Spec requirement | Task |
|------------------|------|
| Single workflow two jobs | Task 1 |
| PR + master push triggers | Task 1 |
| pub get → build_runner → analyze → test | Task 1 |
| APK only on master push after analyze | Task 1 |
| No dart-define / debug signing (project default) | Task 1 |
| Artifact name/path/14 days | Task 1 |
| Out of scope items omitted | Task 1 (YAGNI) |
