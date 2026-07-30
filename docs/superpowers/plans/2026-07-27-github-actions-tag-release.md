# GitHub Actions Tag Release Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** PR/`master` only analyze+test; `v*` tag pushes build arm64 APK and create a GitHub Release with the APK attached.

**Architecture:** Single workflow `.github/workflows/ci.yml` with `analyze` (always) and `release` (tag-only, needs analyze). Remove master `build-apk` artifact job.

**Tech Stack:** GitHub Actions, Flutter stable, `softprops/action-gh-release@v2`

## Global Constraints

- Work on `master` only; do not create commits unless the user asks.
- Spec: `docs/superpowers/specs/2026-07-27-github-actions-tag-release-design.md`
- Tags: `v*` only; APK: `--target-platform=android-arm64`
- Asset name: `huasen-{tag}-arm64.apk`
- No dart-define; debug signing unchanged
- `permissions.contents: write` on release job
- Remove master Artifact upload job

## File Structure

| File | Responsibility |
|------|----------------|
| `.github/workflows/ci.yml` | Full CI + tag release pipeline |

---

### Task 1: Replace `build-apk` with tag `release` job

**Files:**
- Modify: `.github/workflows/ci.yml`

**Interfaces:**
- Consumes: existing analyze job steps pattern
- Produces: workflow that on `refs/tags/v*` creates GitHub Release with APK

- [ ] **Step 1: Rewrite `ci.yml` to match this content exactly**

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [master]
    tags: ['v*']

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

  release:
    name: Release APK
    needs: analyze
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    permissions:
      contents: write
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

      - name: Build release APK (arm64)
        run: flutter build apk --release --target-platform=android-arm64

      - name: Rename APK
        run: |
          mv build/app/outputs/flutter-apk/app-release.apk \
            "build/app/outputs/flutter-apk/huasen-${GITHUB_REF_NAME}-arm64.apk"

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: build/app/outputs/flutter-apk/huasen-${{ github.ref_name }}-arm64.apk
          name: ${{ github.ref_name }}
          body: |
            HuaSen ${{ github.ref_name }} (arm64-v8a, debug-signed).
          fail_on_unmatched_files: true
```

- [ ] **Step 2: Verify constraints**

Confirm file has: `tags: ['v*']`, no `build-apk` / `upload-artifact` for master, `if: startsWith(github.ref, 'refs/tags/v')`, `contents: write`, rename + `action-gh-release`, arm64 build.

- [ ] **Step 3: Skip commit**

Do not commit unless user asks.
