# Flutter Root Layout — Design Spec

**Date:** 2026-07-11  
**Status:** Approved  
**App:** repo root (Flutter)

## Goal

Eliminate the dual Flutter project layout by promoting `sebhua_notes_app/` to the repository root so there is a single Flutter app.

## Approach

Promote nested app contents to root; delete root stubs and the empty nested directory.

## Changes

- Move `lib/`, platform folders, `test/`, `pubspec.yaml`, `pubspec.lock`, `.metadata`, `analysis_options.yaml`, `README.md` to root.
- Merge OpenAPI files into root `docs/` alongside `docs/superpowers/`.
- Keep root `.gitignore` (already covers Flutter + Cursor/Codegraph/omo).
- Delete nested `sebhua_notes_app/` and former root stub `lib/` / draft `pubspec.yaml`.
- Update `AGENTS.md` paths and remove the “root stub cleanup” gap item.

## Verification

```bash
flutter pub get
flutter analyze
```
