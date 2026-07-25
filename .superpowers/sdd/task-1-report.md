# Task 1 Report: Add `ci.yml` workflow

**Status:** DONE  
**Branch:** master (working-tree only, no commit)  
**Date:** 2026-07-25

## Summary

Created `.github/workflows/ci.yml` exactly as specified in the task brief. The workflow defines two jobs: `analyze` (pub get → build_runner → analyze → test) on all PRs and pushes to `master`, and `build-apk` (same prep plus release APK build and artifact upload) only on push to `master` after `analyze` succeeds.

## Changes

### Created `.github/workflows/ci.yml`

| Item | Value |
|------|-------|
| Workflow name | `CI` |
| Triggers | `pull_request` (any branch) + `push` to `master` |
| Job `analyze` | `Analyze & Test` on `ubuntu-latest` |
| Job `build-apk` | `needs: analyze`; `if: github.event_name == 'push' && github.ref == 'refs/heads/master'` |
| Flutter setup | `subosito/flutter-action@v2`, `channel: stable`, `cache: true` |
| CI order | `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs` → `flutter analyze` → `flutter test` |
| APK build | `flutter build apk --release` (no `--dart-define`) |
| Artifact | `app-release-apk` from `build/app/outputs/flutter-apk/app-release.apk`, `retention-days: 14` |

## Verification (Step 2 — PowerShell)

```powershell
Test-Path .github/workflows/ci.yml
# True

Select-String -Path .github/workflows/ci.yml -Pattern "build-apk|flutter analyze|flutter test|app-release-apk|dart-define|master"
```

Output:

```text
True

.github\workflows\ci.yml:6:    branches: [master]
.github\workflows\ci.yml:29:        run: flutter analyze
.github\workflows\ci.yml:32:        run: flutter test
.github\workflows\ci.yml:34:  build-apk:
.github\workflows\ci.yml:37:    if: github.event_name == 'push' && github.ref == 'refs/heads/master'
.github\workflows\ci.yml:61:          name: app-release-apk
```

- File exists: **yes**
- Matches for analyze/test/apk/master: **yes**
- `dart-define` match: **none** (expected)

## Self-review (brief checklist)

| # | Constraint | Result |
|---|------------|--------|
| 1 | Triggers `pull_request` and `push` to `master` | ✅ |
| 2 | `build-apk.if` exactly `github.event_name == 'push' && github.ref == 'refs/heads/master'` | ✅ |
| 3 | `needs: analyze` on `build-apk` | ✅ |
| 4 | `build_runner` before analyze/test and before APK build | ✅ |
| 5 | `flutter build apk --release` with no dart-define | ✅ |
| 6 | Upload `app-release-apk` from `build/app/outputs/flutter-apk/app-release.apk`, retention 14 | ✅ |
| — | No keystore secrets, no GitHub Release, no Windows/iOS jobs, no China mirrors | ✅ |
| — | No git commit created | ✅ |

## Concerns

None. Workflow has not been executed on GitHub Actions yet; first run will validate runner environment and APK signing (debug signingConfig per project convention).
