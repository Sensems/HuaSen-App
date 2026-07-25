# Task 4 Report: Design spec — Notes List Swipe Tabs

**Status:** Complete  
**Date:** 2026-07-25

## Deliverable

Created `docs/superpowers/specs/2026-07-25-notes-list-swipe-tabs-design.md`.

## Spec contents (aligned with implementation)

| Section | Coverage |
|---------|----------|
| Goal / interaction | Swipe + tap; per-tab scroll/data retention |
| Decisions table | PageView.builder, family provider, shared query, KeepAlive, lazy load, WidgetRef helper |
| Mermaid data-flow | Screen → query → family notifiers → API; mutation refresh path |
| Behavior | Query listen reload, loadInitial on first frame, pull-to-refresh per page, generation guard |
| Files | Add/change list matches Tasks 1–3 |
| Out of scope | Shell nav swipe, drafts, Drift, persistence, tests |

## Verification

- Cross-checked against `notes_list_query.dart`, `notes_list_notifier.dart`, `notes_list_screen.dart`, `note_detail_screen.dart`, `note_editor_screen.dart`.
- Style matched existing specs (`2026-07-23-notes-list-category-tag-filter-design.md`, `2026-07-25-github-actions-ci-apk-design.md`).
- Plan at `docs/superpowers/plans/2026-07-25-notes-list-swipe-tabs.md` left unchanged (consistent).

## Concerns

- None blocking. Spec documents `PageView.builder` (actual) vs plan’s generic “PageView with children” — intentional accuracy note.
- `refreshExistingNotesLists` uses `WidgetRef` (Task 3 fix); plan still mentions `Ref` in one place — spec uses implemented signature.

## Commit

Not committed (per task instructions).
