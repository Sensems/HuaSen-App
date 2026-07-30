# GitHub Actions Tag Release (v*)

**Date:** 2026-07-27  
**Status:** Approved for planning  
**Scope:** Extend `.github/workflows/ci.yml` — PR/`master` analyze+test only; `v*` tag builds arm64 APK and creates a GitHub Release

## Goal

Publishing an APK happens only when a `v*` git tag is pushed. PR and `master` pushes keep running analyze/test and no longer build or upload APK artifacts on every merge.

## Decisions

| Topic | Choice |
|-------|--------|
| Trigger for Release | `push` tags matching `v*` (e.g. `v1.0.0`) |
| Master APK Artifact | Removed — no `build-apk` on `master` |
| Workflow layout | Single file `.github/workflows/ci.yml` (approach 1) |
| APK ABI | `flutter build apk --release --target-platform=android-arm64` |
| Asset name | `huasen-{tag}-arm64.apk` (renamed from `app-release.apk`) |
| Signing | Existing debug signing (unchanged) |
| `API_BASE_URL` | No `--dart-define` (code default) |
| Release body | Short default notes (tag name); no mandatory changelog generator |
| Permissions | `contents: write` on the release job (for `GITHUB_TOKEN` create release) |

## Workflow layout

**File:** `.github/workflows/ci.yml`

```
on:
  pull_request:
  push:
    branches: [master]
    tags: ['v*']

jobs:
  analyze:     # always (PR, master push, tag push)
  release:     # needs: analyze; if: startsWith(github.ref, 'refs/tags/v')
```

### Job `analyze`

Unchanged steps: checkout → Flutter (stable, cache) → pub get → build_runner → analyze → test.

Runs on PR, `master` push, and `v*` tag push so a bad tag still fails before release.

### Job `release` (tag only)

Runs when:

- `needs: analyze` succeeded
- `startsWith(github.ref, 'refs/tags/v')`

Steps:

1. Checkout + Setup Flutter (same as today)
2. `flutter pub get`
3. `dart run build_runner build --delete-conflicting-outputs`
4. `flutter build apk --release --target-platform=android-arm64`
5. Rename APK to `huasen-${GITHUB_REF_NAME}-arm64.apk`
6. Create GitHub Release for the tag and attach the APK (`softprops/action-gh-release` or `gh release create`)

Remove the former `build-apk` job that ran on `master` push and uploaded `app-release-apk` artifacts.

## Error handling

- Analyze/test failure on a tag → no Release created
- Release create failure → workflow fails (tag remains; can re-run job after fix)
- Re-pushing the same tag / re-running: prefer `softprops/action-gh-release` with update-if-exists behavior if available; otherwise document one-shot tags

## Out of scope

- Play Store / formal keystore
- `workflow_dispatch` manual release
- Windows/iOS builds
- Automatic semver bump from `pubspec.yaml`
- Keeping master Artifact uploads

## Success criteria

1. PR and `master` push: only analyze/test; no APK job.
2. `git push origin v1.0.0` (after tagging): analyze then Release `v1.0.0` with `huasen-v1.0.0-arm64.apk`.
3. Failed analyze on a tag prevents Release.
4. Existing China/CI Maven split and `sqlparser` pin remain untouched.
