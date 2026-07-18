# Note Detail Page — Design Spec

**Date:** 2026-07-18  
**Status:** Approved (brainstorm)  
**App:** Flutter app at repository root  
**Mock:** User-provided note detail mock (cream canvas, coral accents, floating「编辑」)

## Goal

Add a read-only **note detail** screen between the published notes list and the note editor. Users can view title, rich text, attachments, and pin state; pin/unpin; delete with confirmation; then enter the editor via a floating「编辑」button.

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Navigation flow | List → detail →「编辑」→ editor; `+` new and drafts「完善」still open editor directly |
| Routes | `/note/:id` → detail; `/note/:id/edit` → editor; `/note/new` → create editor |
| Metadata row | Show `updatedAt` + pinned badge only; **no** category/tag pills this iteration |
| Body rendering | Read-only `QuillEditor` (`readOnly: true`, no toolbar); same Delta JSON as editor |
| Attachments | Read-only cards from `getNoteDetailBundle` media; no add/remove/preview/download |
| Architecture | New `NoteDetailScreen` (`ConsumerStatefulWidget`); call `NotesService` directly (same as editor/account) |
| Pin | `POST /notes/pin` toggle; update local UI + refresh notes list |
| Delete | Confirm dialog → `POST /notes/delete` → toast → refresh list → `pop` to list |
| Return from editor | Existing editor `pop`; detail **reloads** when it becomes visible again |
| Tests | Manual QA only; no new automated tests |
| Implementation approach | Dedicated detail screen without extracting shared content widgets from editor |

## Out of Scope

- Category / tag name resolution or pills
- Attachment preview, download, or open-in-browser
- In-place editing of title/body/category/tags on the detail page
- Drift / Repository layer
- Refactoring editor into a shared `NoteContentView`
- Automated tests
- Changing draft delete UX (drafts remain list → editor)

## Existing Context

- `NotesListScreen` currently `push('/note/${note.id}')` into `NoteEditorScreen`.
- Drafts open `/note/:id` for edit; must change to `/note/:id/edit`.
- Editor API wiring is done: `getNoteDetailBundle`, create/update/publish, Quill Delta codec.
- `NotesService.pinNote` / `deleteNote` already exist.
- `NoteDetailDto` has `categoryId` / `tagIds` but no display names — deferred.
- Drafts delete confirm dialog is the pattern to mirror for detail delete.

## Routes

| Path | Screen | Notes |
|------|--------|-------|
| `/note/new` | `NoteEditorScreen(noteId: 'new')` | Must resolve before generic `:id` detail, or match `new` explicitly |
| `/note/:id` | `NoteDetailScreen` | Published-note read view |
| `/note/:id/edit` | `NoteEditorScreen` | Existing editor; path param `id` |

All three stay **outside** `ShellRoute` (no bottom nav), consistent with today’s editor.

Constants: add a route helper or constant for the edit path (e.g. `/note/:id/edit`) in `AppConstants` / router as needed.

### Entry points (must update)

| Entry | Target |
|-------|--------|
| Notes list card tap | `/note/:id` (detail) |
| Notes list `+` | `/note/new` (unchanged) |
| Drafts「完善」 | `/note/:id/edit` |
| Detail「编辑」 | `/note/:id/edit` |

## UI Structure

Match the provided mock:

1. **Top bar** — left `‹ 返回` (coral); right `置顶` / `取消置顶` + `删除` (coral text actions).
2. **Metadata row** — grey `updatedAt` as `yyyy.MM.dd HH:mm`; if `pinnedAt != null`, coral-tint pill「置顶」. No category/tag chips.
3. **Title** — large bold read-only text (not a `TextField`).
4. **Body** — read-only Quill, scrollable with the page.
5. **Attachments** — header「附件」+ count badge; file cards (icon, name, size) styled like the editor; no add row, no remove control. Empty: hide section or show count `0` (pick one consistent with editor empty habit during implementation).
6. **Floating「编辑」** — bottom fixed/floating outlined button (white fill, coral border/text); content bottom padding so cards are not obscured.

Visual system: existing `AppColors` / `ColorScheme.primary` coral; light canvas surface. Chinese copy in `UiStrings`.

### Loading / error

- Initial load: centered `CircularProgressIndicator`.
- Failure: message + retry (reuse notes load failure copy patterns).
- Pin/delete in-flight: ignore duplicate taps / disable actions.

## Data & Interactions

### Load

```
GET /notes/detail?id={id}  →  NoteDetailBundle (note + media)
```

- Deserialize note `content` with the same Quill codec as the editor.
- Map `media` to read-only attachment cards (name from key/url heuristics already used in editor if available; size from `fileSize`).

### Resume after editor

When opening the editor from detail, use:

```dart
await context.push('/note/$id/edit');
if (mounted) { /* reload detail */ }
```

so title/body/media/pin refresh after save or silent back.

### Pin

1. Tap top-bar pin action.
2. `NotesService.pinNote(id)`.
3. Success: apply returned `NoteDetailDto` to local state; `$message.success` with backend `message`; `notesListProvider.refresh()`.
4. Failure: `$message.error` with backend `message`.

Top-bar label: `pinnedAt != null` →「取消置顶」, else「置顶」. Metadata pin pill follows `pinnedAt`.

### Delete

1. Tap「删除」→ `showDialog` confirm (mirror drafts: title + message + 取消/确认).
2. On confirm: `NotesService.deleteNote(id)`.
3. Success: toast → `notesListProvider.refresh()` → `context.pop()` to list.
4. Failure: toast; stay on detail.

### Edit

`context.push('/note/$id/edit')`.

### Attachments

Display only. No tap handler required this iteration.

## Architecture

```
NotesListScreen
  └─ push /note/:id
       NoteDetailScreen
         ├─ NotesService.getNoteDetailBundle / pinNote / deleteNote
         ├─ notesListProvider.refresh (after pin/delete)
         └─ push /note/:id/edit
              NoteEditorScreen (existing)
                └─ pop → detail reloads
```

No new Riverpod notifier unless implementation proves screen state is unwieldy; default is screen-local state.

## Files (expected)

| Area | Files |
|------|--------|
| New screen | `lib/features/notes/note_detail_screen.dart` |
| Router | `lib/core/router/app_router.dart`, `lib/core/constants/app_constants.dart` |
| List / drafts nav | `notes_list_screen.dart`, drafts screen / card open path |
| Copy | `lib/core/constants/ui_strings.dart` |
| Reuse | Existing Quill content codec helpers from editor API work; attachment card visuals may be duplicated lightly |

## Acceptance Criteria

1. Published list card opens detail; `+` and drafts open editor.
2. Detail shows updated time, optional pin badge, title, read-only rich text, attachments.
3. Pin toggles via API and updates chrome + list after refresh.
4. Delete requires confirmation; on success returns to list with refreshed data.
5.「编辑」opens `/note/:id/edit`; after save/back, detail reflects updates when reloaded.
6. API toasts use backend `message`; `flutter analyze` clean for touched files.

## Follow-Ups

- Category/tag pills when API exposes names (or dedicated resolve step).
- Attachment open/preview.
- Optional shared widgets for title/body/attachments between detail and editor.
