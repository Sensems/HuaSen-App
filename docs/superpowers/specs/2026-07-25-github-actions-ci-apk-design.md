# GitHub Actions CI + Android APK Artifact

**Date:** 2026-07-25  
**Status:** Approved for planning  
**Scope:** One workflow — analyze/test on PR and `master`; release APK artifact on `master` push only (debug-signed)

## Goal

Add GitHub Actions so every PR and every `master` push runs Flutter static analysis and tests; after CI passes on `master`, build a release APK and upload it as a downloadable workflow artifact. No formal keystore yet; API URL uses app defaults.

## Background

- Repo root is the Flutter app (`pubspec.yaml`, `sdk: ^3.12.2`).
- No existing `.github/workflows`.
- Local release APK path: `build/app/outputs/flutter-apk/app-release.apk`.
- `API_BASE_URL` defaults in `AppConstants` to `http://notes.sensems.top/api`; CI builds do not pass `--dart-define`.
- Freezed / json_serializable / Riverpod generated files are committed; CI still runs `build_runner` so generated code stays in sync with sources.

## Decisions

| Topic | Choice |
|-------|--------|
| Approach | Single workflow, two jobs (`analyze` + conditional `build-apk`) |
| Triggers | `pull_request` (any) + `push` to `master` |
| CI steps | `pub get` → `build_runner` → `flutter analyze` → `flutter test` |
| APK when | Only `push` to `master`, and only if `analyze` succeeds |
| Signing | Flutter default debug signing for release APK (temporary) |
| `API_BASE_URL` | No dart-define; use code default |
| Artifact | Upload `app-release.apk`; retention 14 days |
| Platforms | Android APK only (no Windows/iOS/Release publish) |
| Formal keystore | Out of scope (follow-up) |

## Workflow layout

**File:** `.github/workflows/ci.yml`

```
on:
  pull_request:
  push:
    branches: [master]

jobs:
  analyze:     # always
  build-apk:   # needs: analyze; if: github.event_name == 'push' && github.ref == 'refs/heads/master'
```

### Job `analyze` (ubuntu-latest)

1. Checkout repository.
2. Setup Flutter (stable channel; version compatible with Dart SDK `^3.12.2`).
3. `flutter pub get`
4. `dart run build_runner build --delete-conflicting-outputs`
5. `flutter analyze`
6. `flutter test`

Fail the job (and thus block merge confidence) if any step fails.

### Job `build-apk` (ubuntu-latest)

Runs only when:

- `needs: analyze` succeeded
- event is `push` to `refs/heads/master`

Steps:

1. Checkout + setup Flutter (same as CI).
2. `flutter pub get`
3. `dart run build_runner build --delete-conflicting-outputs` (same as CI; keeps build self-contained)
4. `flutter build apk --release` (no `--dart-define`)
5. Upload artifact:
   - name: e.g. `app-release-apk`
   - path: `build/app/outputs/flutter-apk/app-release.apk`
   - retention-days: `14`

## Error handling

- Analyze/test failure → workflow red; `build-apk` skipped.
- APK build failure → CI still green for that run’s analyze job, but overall workflow fails (expected).
- No GitHub Release / no store upload in this scope.

## Out of scope

- Keystore secrets / Play Store signing
- `workflow_dispatch` manual trigger
- Windows / macOS / iOS builds
- Publishing to GitHub Releases
- China mirror configuration for Actions runners (use default GitHub-hosted network)

## Success criteria

1. Opening or updating a PR runs `analyze` only (no APK job).
2. Pushing to `master` runs `analyze` then `build-apk`; APK appears under the run’s Artifacts.
3. Failing `flutter analyze` or `flutter test` fails the workflow and prevents APK upload for that `master` push.
4. Built APK uses default `API_BASE_URL` and debug signing until a later signing task.
