# Task 3: Detail/editor refresh call sites + analyze

**Files:**
- Modify: `lib/features/notes/note_detail_screen.dart`
- Modify: `lib/features/notes/note_editor_screen.dart`

## Steps

- [ ] Replace every `ref.read(notesListProvider.notifier).refresh()` with `await refreshExistingNotesLists(ref)` (import from `notes_list_notifier.dart`).
- [ ] Grep the whole `lib/` tree for remaining non-family `notesListProvider` usages (without `(tab)`) and fix any that break compile.
- [ ] Run `flutter analyze` at repo root; fix any issues introduced by this feature.
- [ ] Do **not** commit.
- [ ] Write report to `.superpowers/sdd/swipe-task-3-report.md`.

## Acceptance

Analyze clean for this feature; mutation refresh hits existing tab instances only via `refreshExistingNotesLists`.

## Global Constraints

- master only; no commits; no new automated tests; no unrelated refactors.
