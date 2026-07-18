# Note Editor UI + Local Interaction — Design Spec

**Date:** 2026-07-16  
**Status:** Approved (brainstorm)  
**App:** Flutter app at repository root

## Goal

Implement the note editor screen UI and local interactions shown in the provided mockup, without wiring backend APIs in this iteration.

This iteration replaces the current placeholder editor with a real `flutter_quill` editing surface, a custom compact toolbar, local file attachment selection/removal, and local-only action feedback. API save/load/upload integration is intentionally deferred to the next implementation step.

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Editor package | Use the existing `flutter_quill` dependency |
| Scope | Static UI + local interaction only |
| Backend calls | None in this iteration |
| Attachments | Use real `file_picker` selection, store selected files only in page state |
| Save button | Local-only feedback, no `NotesService` call |
| Sync clipboard button | Local placeholder feedback, no clipboard/network sync |
| Verification | `flutter analyze` + manual QA |
| Tests | No new automated tests unless requested |

## Rich Text Editor Options Considered

| Option | Fit | Trade-off |
|--------|-----|-----------|
| `flutter_quill` | Best fit for this project because it is already in `pubspec.yaml`, supports Delta JSON, custom toolbar buttons, links, headings, lists, and rich text editing | Needs some local UI wrapping to match the mockup |
| `appflowy_editor` | Strong block editor and mobile toolbar model | Would introduce a different document model and a new dependency direction for a feature already planned around Quill |
| `super_editor` | Very flexible low-level editor | More implementation work for toolbar, serialization, and attachment UX |

Decision: use `flutter_quill` with a custom lightweight toolbar instead of `QuillSimpleToolbar`, because the default toolbar is visually heavier than the mockup.

## Out of Scope

- Calling `GET /notes/detail`
- Calling `POST /notes/create` or `POST /notes/update`
- Uploading files through `StorageService.uploadFile`
- Creating or persisting `mediaIds`
- Inline image/file embeds inside Quill content
- Real clipboard synchronization
- Drift/local database persistence
- Category/tag editing
- Automated tests

## Existing Context

Current entry point:

- `lib/features/notes/note_editor_screen.dart` is a placeholder with title/content inputs and an attachment placeholder.
- `NotesListScreen` already navigates to `/note/new` and `/note/:id`.
- `NotesService` already exposes `getNoteDetail`, `createNote`, `updateNote`, and `deleteNote`.
- `CreateNoteDto` / `UpdateNoteDto` accept `content` as a string and `mediaIds` as a list of uploaded media IDs.
- `StorageService.uploadFile` can later upload selected file bytes and return upload metadata.

## UI Structure

### Mobile Layout

Use a single vertical page matching the mockup:

1. Safe-area top bar with left text action `‹ 返回` and right text action `保存`.
2. Title input styled as large bold text, with no heavy input chrome.
3. Compact horizontal toolbar of rounded square buttons.
4. `QuillEditor` body area with rich text content.
5. Attachment section:
   - Header `附件`
   - Small count badge
   - File cards for selected attachments
   - Dashed or outlined `+ 添加附件` row
6. Bottom outlined primary action `同步至剪贴板`.

The page background should follow the existing light canvas direction (`AppColors` / app theme), with white or low-surface cards and coral primary accents through `ColorScheme.primary`.

### Wide Layout

Keep the current wide-screen intent:

- Left pane: title, toolbar, editor.
- Right pane: attachment section and bottom local actions.

The visual styling remains consistent with mobile, but spacing can use the existing desktop padding pattern.

## Toolbar Design

Use a small custom toolbar driven by the `QuillController`. Initial buttons:

| Button | Behavior |
|--------|----------|
| B | Toggle bold |
| I | Toggle italic |
| H | Toggle heading style for current line |
| List | Toggle bullet list |
| Link | Open URL dialog and apply link to selected text |
| Undo | Revert the latest local editor operation |

Toolbar buttons should:

- Reflect active selection state when practical.
- Use compact rounded rectangles like the mockup.
- Use primary/coral tint for active state.
- Avoid exposing the full default Quill toolbar in this iteration.

## Local State

`NoteEditorScreen` can remain a stateful page for this iteration. It owns:

| State | Purpose |
|-------|---------|
| `TextEditingController` | Title text |
| `QuillController` | Rich text document and selection |
| `List<LocalAttachment>` | Selected local files |
| `bool isDirty` | Tracks title/editor/attachment changes for future leave confirmation |
| `bool isPickingFile` | Prevents duplicate file picker launches |

`LocalAttachment` should be a small local model near the editor screen or in a feature-local helper file. It should store the selected file name, byte size, extension/type, and either path or bytes depending on what `file_picker` returns on the platform.

## Local Interactions

### Return

Tap `返回` and call `context.pop()`. Do not save or show an unsaved-changes dialog in this iteration.

### Save

Tap `保存` and show a local success toast using `tolyui_message`. Do not call `NotesService`.

Recommended copy: `已保存到本地草稿，接口接入后将同步到云端`.

Stay on the current page after save so the user can continue QA on the editor UI.

### Rich Text Editing

The editor uses `flutter_quill` directly. Text style changes are applied through the controller. Link insertion opens a lightweight dialog with a URL field; confirm applies a link attribute to the current selection.

### Attachments

Tap `+ 添加附件`:

1. Open `file_picker`.
2. Add selected files to `List<LocalAttachment>`.
3. Display each file as a card with type icon, file name, human-readable size, and a delete action.
4. Delete removes only the local item from state.

No upload, media validation, or API sync is performed.

### Sync To Clipboard

Tap `同步至剪贴板` and show local placeholder feedback.

Recommended copy: `剪贴板同步将在接口接入阶段启用`.

## Data Format Reserved For Next Step

Although this iteration does not call APIs, it should shape state so the next step is straightforward:

- Serialize rich text as Quill Delta JSON:
  `jsonEncode(quillController.document.toDelta().toJson())`
- Later, pass that JSON string to `CreateNoteDto.content` or `UpdateNoteDto.content`.
- Later, when loading existing notes, try parsing `content` as Quill Delta JSON first. If parsing fails, import it as plain text so older text-only notes remain readable.
- Later, upload attachments before note save:
  1. Iterate local attachments.
  2. Call `StorageService.uploadFile`.
  3. Collect returned media IDs.
  4. Pass media IDs to `CreateNoteDto.mediaIds` or `UpdateNoteDto.mediaIds`.

## Error Handling

| Case | Behavior |
|------|----------|
| File picker canceled | No state change, no error toast |
| File picker throws | Show local error toast |
| Link dialog canceled | No formatting change |
| Empty URL submitted | Keep dialog open or show inline validation |
| Save clicked with empty title/body | Allow local save feedback; backend validation is out of scope |

## Suggested Implementation Units

| Unit | Path |
|------|------|
| Main editor screen update | `lib/features/notes/note_editor_screen.dart` |
| Optional small attachment model/widget | Same file or `lib/features/notes/widgets/` if the screen becomes too large |
| New UI strings | `lib/core/constants/ui_strings.dart` |

Keep the implementation scoped. Do not introduce Repository, Drift, or API notifiers in this UI-only iteration.

## Manual QA

1. Open `/note/new`.
2. Edit the title.
3. Type rich text in the editor.
4. Toggle bold, italic, heading, list, and link formatting.
5. Add one or more local attachments.
6. Remove an attachment.
7. Tap `保存` and confirm local feedback appears without navigation.
8. Tap `同步至剪贴板` and confirm placeholder feedback appears.
9. Run `flutter analyze`.

## Follow-Up API Wiring

The next implementation plan should cover:

- Loading note detail for existing IDs.
- Saving new and existing notes through `NotesService`.
- Uploading selected attachments through `StorageService`.
- Mapping upload responses to `mediaIds`.
- Parsing existing `content` as Quill Delta JSON with a plain-text fallback.
- Deciding whether attachments remain section-only or also become inline Quill embeds.
