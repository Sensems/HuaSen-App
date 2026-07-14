# Drafts List Page — Design Spec

**Date:** 2026-07-14  
**Status:** Approved (brainstorm)  
**App:** Flutter app at repository root

## Goal

1. Ship a **草稿箱** screen matching the provided mock (sticky title + filter chips, draft cards with 完善/删除, list-only scroll).
2. Wire **real API** via `NotesService.listNotes` with `type=draft` and optional `mediaType`, plus pull-to-refresh and load-more.
3. Show **全部草稿总数** as a badge on the Shell「草稿」tab.
4. Keep the top header **sticky**; only the list scrolls.

Out of scope: Drift / Repository layer, real media thumbnail fetch (list DTO has `mediaIds` only), note editor implementation beyond navigation, publish flow, restoring clipboard to the tab bar, automated tests (manual QA only).

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Data | `GET /notes?type=draft` via existing `NotesService.listNotes` |
| Architecture | **1** — `DraftsListNotifier` + independent `draftsCountProvider`; both call Service directly (no Drift) |
| Filter chips | 全部 / 文本 / 图片 / 音频（替换 mock 中的「文件」） |
| Filter → API | 全部: no `mediaType`; 文本: `TEXT`; 图片: `IMAGE`; 音频: `VOICE` |
| Card source name | `title` (fallback「无标题」); preview from `content` |
| Card icon | Material `Icons.mark_chat_unread` (no WeChat brand asset) |
| 完善 | Navigate to `/note/:id` |
| 删除 | `POST /notes/delete`; on success remove from list and refresh badge count |
| Tab badge | Always `total` from `type=draft` **without** `mediaType`; hide when `0` |
| Visual | Match attached drafts mock; accent via global `AppColors` / `ColorScheme.primary` |
| Bottom nav | Keep three tabs (笔记 / 草稿 / 设置); do not add clipboard back |
| UI kit | Material + in-house `lib/ui/` + `tolyui_message` for errors (prefer backend `message`) |
| Verification | Manual testing only |

## Backend reference

| Method | Path | Query / body | Response |
|--------|------|--------------|----------|
| GET | `/notes` | `type=draft`, `page`, `size`, optional `mediaType` | `ApiResponse<PaginatedNotes>` |
| POST | `/notes/delete` | `{ id }` | `ApiResponse` with deleted note |

`PaginatedNotes`: `items: List<NoteDetailDto>`, `total`, `page`, `size`.

`mediaType` values used by this UI: `TEXT` | `IMAGE` | `VOICE`.

**Known API gap:** Live OpenAPI `mediaType` enum is `IMAGE` | `VOICE` | `VIDEO` | `FILE` — it does **not** list `TEXT`. Per product decision we still send `mediaType=TEXT` for the「文本」chip. If the backend rejects it, treat as a backend follow-up; do not invent a client-only filter.

`NoteDetailDto` fields used: `id`, `title`, `content`, `mediaIds`, `createdAt`, `updatedAt`.

## Architecture

Dependency direction unchanged: `features → data / core / ui`.

```
UI (DraftsScreen + sticky header + cards)
  → DraftsListNotifier
    → NotesService.listNotes / deleteNote
  → Dio (+ AuthInterceptor)

MainShell (草稿 Tab Badge)
  → draftsCountProvider
    → NotesService.listNotes(type: 'draft', page: 1, size: 1)  // use total only
```

| Layer | Changes |
|-------|---------|
| **Feature wechat** | Rebuild `drafts_screen.dart`; add `DraftsListNotifier` + state; optional widgets for chips/cards; add `draftsCountProvider` |
| **UI / shell** | Convert `MainShell` to `ConsumerWidget` (or equivalent) so it can watch `draftsCountProvider`; Badge on drafts destination when count > 0. Wide layout still hides the bar (existing behavior; no NavigationRail badge this iteration). |
| **Core** | Chinese `UiStrings` for 草稿箱 / chips / empty / actions (replace English `wechatDrafts` placeholders) |
| **Data** | Reuse `NotesService.listNotes` / `deleteNote` + existing DTOs; no Drift |
| **Router** | Keep `/drafts` under existing `ShellRoute`; no route table change required |
| **Shared util** | Reuse `lib/features/notes/note_time_format.dart` for relative timestamps |

## UI / interaction

### Layout

```
┌─ Sticky header ───────────────────────┐
│  草稿箱                                │
│  [全部] [文本] [图片] [音频]            │
├───────────────────────────────────────┤
│  Scrollable list only                 │
│  pull-to-refresh / load-more          │
│  cards: icon · title · time           │
│         content / media placeholder   │
│         [完善] [删除]                  │
└───────────────────────────────────────┘
┌─ Shell: 笔记 | 草稿(badge) | 设置 ────┐
```

### Header

- Title「草稿箱」left, large weight (mock-aligned).
- Filter chips: selected = primary fill + onPrimary text; unselected = outlined / surface.
- Sticky via fixed `Column` + `Expanded` list (same pattern as notes list).

### List / cards

- Pull-to-refresh and load-more on the list region only.
- Card icon: `Icons.mark_chat_unread` in a circular chip.
- Title: `title` or「无标题」; timestamp: relative Chinese from `updatedAt ?? createdAt` via existing `formatNoteListTime` (or same helper in `note_time_format.dart`).
- Body: truncated `content`. If `mediaIds` is non-empty, show a **generic** media placeholder block (no network thumbnail; do not invent IMAGE vs VOICE from IDs alone).
- Card body tap and「完善」both → `context.push('/note/:id')`.
- 「删除」→ call delete API **without** a confirmation dialog; success removes row and refreshes count; failure shows toast with backend `message` when available.
- Empty / error / loading: same patterns as notes list (centered spinner, retry, empty copy).

## Data flow

### `DraftsListState`

- `items`, `page`, `total`, `size` (default `AppConstants.notesPageSize` / 20)
- `filter`: `all` | `text` | `image` | `audio`
- `isInitialLoading`, `isRefreshing`, `isLoadingMore`
- `errorMessage`, `hasMore` (`items.length < total`)

### Triggers

| Action | Behavior |
|--------|----------|
| Enter screen | Load page 1 with current filter |
| Switch chip | Reset page 1; set `mediaType` mapping; replace items |
| Pull to refresh | Page 1; keep filter |
| Load more | `page + 1`, append; ignore if loading or `!hasMore` |
| 完善 | Navigate to editor |
| 删除 | `deleteNote` → remove item; refresh `draftsCountProvider` |

### Filter → query

| Chip | `type` | `mediaType` |
|------|--------|-------------|
| 全部 | `draft` | omitted |
| 文本 | `draft` | `TEXT` |
| 图片 | `draft` | `IMAGE` |
| 音频 | `draft` | `VOICE` |

### Badge (`draftsCountProvider`)

- Fetch `listNotes(type: 'draft', page: 1, size: 1)` and expose `total`.
- Independent of list filter so chip changes do not change the badge.
- Load when `MainShell` watches the provider (authenticated shell).
- Refresh after successful delete, and after a successful drafts list pull-to-refresh (keeps badge in sync without waiting for another shell rebuild).
- Hide badge when count is `0` or still unknown/error (no fake count).
- Cap display if needed for UI (e.g. `99+`) is optional; default show the numeric `total` as Material `Badge` allows.

### Errors

| Case | UX |
|------|----|
| First-load failure | Centered error + retry |
| Refresh failure | Keep list; `tolyui_message` error |
| Load-more failure | Footer retry; keep existing items |
| Delete failure | Keep card; toast with backend `message` when present |

## Files (expected)

| Path | Role |
|------|------|
| `lib/features/wechat/drafts_screen.dart` | Sticky header + list UI |
| `lib/features/wechat/drafts_list_notifier.dart` | List state / pagination / delete |
| `lib/features/wechat/drafts_count_provider.dart` | Badge total |
| `lib/features/wechat/widgets/*` | Chips / draft card (as needed) |
| `lib/ui/shell/main_shell.dart` | Badge on drafts tab |
| `lib/core/constants/ui_strings.dart` | Copy |

## Acceptance (manual)

1. Login → 草稿 tab: sticky「草稿箱」+ chips 全部/文本/图片/音频; only list scrolls.
2. List requests use `type=draft`; chip switches send the mapped `mediaType`; pull-to-refresh and load-more work.
3. Card uses `mark_chat_unread`; 完善 opens `/note/:id`; delete removes item and decreases badge.
4. Badge shows unfiltered draft `total`; hidden at `0`; unaffected by chip filter.
5. Bottom bar remains 笔记 / 草稿 / 设置 (no clipboard).

## Non-goals

- Drift / Repository
- Real media URL / thumbnail loading
- `POST /notes/publish` as「完善」
- Clipboard tab restoration
- Automated tests
- Wide-screen NavigationRail changes beyond existing shell behavior
