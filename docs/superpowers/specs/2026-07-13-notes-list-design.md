# Notes List Page — Design Spec

**Date:** 2026-07-13  
**Status:** Approved (brainstorm)  
**App:** Flutter app at repository root

## Goal

1. Ship a **notes list** screen matching the provided mock (brand header「花森」, expandable search, coral「+」, filter tabs, note cards, three-item bottom bar).
2. Wire **real API** via `NotesService.listNotes` (`keyword`, `page`, `size`) with pull-to-refresh and load-more.
3. Introduce a GoRouter **`ShellRoute`** for main tabs: 笔记 / 草稿 / 设置 (clipboard removed from the bar).
4. Keep the top header **sticky**; only the list scrolls.

Out of scope: Drift / Repository layer, pin sync with backend, NavigationRail for wide screens, deleting clipboard feature code, automated tests (manual QA only), note editor implementation beyond navigation to `/note/:id`.

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Data | **B** — UI + real `NotesService.listNotes` |
| Visual | **A** — match attached mock as the visual/interaction standard |
| Filter tabs | **A** — show 全部 / 置顶 / 最近; 置顶 is UI placeholder (no pin API); 最近 uses default list sort |
| Bottom nav | **C** — `ShellRoute` with three tabs; wire real `NotesListScreen` to `/` |
| Clipboard | **A** — remove from tab bar; keep `/clipboard` route and page for future deep link |
| Architecture approach | **1** — Shell + list Notifier calls Service directly (no Drift this iteration) |
| Search | Expand icon → input; submit only via search icon or keyboard search action (no live filter) |
| Theme / accent | Global `AppColors` → `ColorScheme.primary` (`#ED6F5C`); no per-page hex |
| UI kit | No third-party UI component library; use Material + in-house `lib/ui/` + `tolyui_message` for toasts |
| Verification | Manual testing only |

## Backend reference

| Method | Path | Query | Response |
|--------|------|-------|----------|
| GET | `/notes` | `page` (default 1), `size` (default 20, max 100), `keyword`, optional `type` / `category` / `tag` / `mediaType` | `ApiResponse<PaginatedNotes>` |

`PaginatedNotes`: `items: List<NoteDetailDto>`, `total`, `page`, `size`.

`NoteDetailDto` fields used by the list: `id`, `title`, `content`, `mediaIds`, `createdAt`, `updatedAt`.

**No** `isPinned` field or pin filter exists in OpenAPI / current DTOs. Do not invent client-side pin sync for 全部/最近.

## Architecture

Dependency direction unchanged: `features → data / core / ui`.

```
UI (NotesListScreen + sticky header widgets)
  → NotesListNotifier (Riverpod)
  → NotesService.listNotes
  → Dio (+ AuthInterceptor)
```

| Layer | Changes |
|-------|---------|
| **Core / router** | `ShellRoute` for `/`, `/drafts`, `/settings`; bottom nav owned by shell; `/` → `NotesListScreen`; add `routeDrafts` if missing; keep `/clipboard` outside shell tabs |
| **Core / providers** | Ensure `notesServiceProvider` (or equivalent) injects Dio → `NotesService` |
| **Feature notes** | Rebuild `notes_list_screen.dart` to mock layout; add `NotesListNotifier` + state; expandable search widget; sticky header + filter tabs |
| **UI** | Extend or restyle `CustomBottomNav` / `CustomCard` as needed for mock; shell may host bottom nav once |
| **Drafts / settings** | Remove per-page duplicate bottom nav when under shell; screens themselves can stay placeholder-quality this iteration |
| **Data** | Reuse existing DTOs/services; no Drift |

### Shell routes

| Tab | Path | Screen |
|-----|------|--------|
| 笔记 | `/` | `NotesListScreen` |
| 草稿 | `/drafts` | existing wechat drafts screen (or current placeholder wiring) |
| 设置 | `/settings` | existing settings screen |

Outside shell (examples): `/login`, `/register`, `/reset-password`, `/legal/*`, `/note/:id`, `/clipboard`.

Auth redirect rules unchanged: unauthenticated → login; authenticated on public auth routes → home.

## UI / interaction

### Layout

```
┌─ Sticky header ───────────────────────┐
│  花森            [search] [+]         │
│  全部 | 置顶 | 最近                     │
├───────────────────────────────────────┤
│  Scrollable list only                 │
│  pull-to-refresh / load-more          │
└───────────────────────────────────────┘
┌─ Shell: 笔记 | 草稿 | 设置 ────────────┐
```

### Header

- Brand title「花森」left, large weight.
- Search: compact square icon → animates wider into a text field; `TextInputAction.search`; submit via trailing search affordance or keyboard; support clear / collapse.
- Coral「+」→ `context.push('/note/new')` (or named route).
- Filter tabs with coral active text + underline.

### List

- Sticky header via fixed column + `Expanded` list (or equivalent); header does not scroll away.
- Cards: white rounded surface, title, preview snippet, relative timestamp; optional left coral bar / pin icon only for placeholder pinned items; media hint icon when `mediaIds` non-empty.
- Tap card → `/note/:id`.
- Empty / error / loading states as in Data section.

### Filter tabs

| Tab | Behavior |
|-----|----------|
| 全部 | `listNotes` page 1…n with current `keyword` |
| 最近 | Same API call; rely on backend default ordering (typically updated-at) |
| 置顶 | Do **not** call pin API; show **empty state only** with copy that pin sync awaits backend (no fake pin cards) |

### Bottom nav

- Three items only: 笔记 / 草稿 / 设置.
- Clipboard removed from bar; route retained.

## Data flow

### `NotesListState`

- `items`, `page`, `total`, `size` (default 20)
- `keyword` (nullable / empty = no filter)
- `filterTab`: `all` | `pinned` | `recent`
- `isInitialLoading`, `isRefreshing`, `isLoadingMore`
- `errorMessage`, `hasMore` (`items.length < total`)

### Triggers

| Action | Behavior |
|--------|----------|
| Enter screen | Load page 1 |
| Submit search | Set `keyword`, reset page 1, replace items |
| Clear search | Clear `keyword`, reset page 1 |
| Switch 全部 / 最近 | Reset page 1, reload |
| Switch 置顶 | No list API; empty/placeholder UI |
| Pull to refresh | Page 1, keep keyword/tab |
| Load more | `page + 1`, append; ignore if already loading or `!hasMore` |

### Card mapping

| UI | Source |
|----|--------|
| Title | `title` or fallback「无标题」 |
| Preview | Truncated plain `content` |
| Timestamp | `updatedAt` ?? `createdAt`, relative Chinese labels (今天 / 昨天 / …) |
| Media icon | `mediaIds?.isNotEmpty` |
| Pin chrome | Placeholder pinned tab only |

### Errors

| Case | UX |
|------|----|
| First-load failure | Centered error + retry |
| Refresh failure | Keep list; `tolyui_message` error |
| Load-more failure | Footer retry hint; keep existing items |
| Success empty | Distinct copy for “no notes” vs “no search results” |
| `code != 200` | Existing `ApiResponse` / exception handling |

## Components (suggested file touchpoints)

- `lib/core/router/app_router.dart` — ShellRoute + real screens
- `lib/core/constants/app_constants.dart` — `routeDrafts` if needed
- `lib/core/constants/ui_strings.dart` — list / tab / empty / error copy
- `lib/features/notes/notes_list_screen.dart` — rebuild
- `lib/features/notes/notes_list_notifier.dart` (and state) — new
- `lib/ui/components/custom_bottom_nav.dart` — three-tab shell usage; remove clipboard item from callers
- Optional small widgets under `features/notes/` for expandable search / filter tabs / note card polish

## Testing (manual)

1. Login → land on notes list with real data (or empty state).
2. Expand search, type keyword, submit via icon and keyboard; clear/collapse.
3. Pull to refresh; scroll to load more when `total` > page size.
4. Switch 全部 / 置顶 / 最近 (置顶 empty/placeholder).
5.「+」and card tap navigate correctly.
6. Bottom tabs: 笔记 / 草稿 / 设置; clipboard not shown; `/clipboard` still reachable if navigated manually.
7. Light/dark theme still uses global primary coral.

## Non-goals (explicit)

- Implementing backend pin API or client Drift cache.
- Full drafts/settings feature work beyond shell wiring and nav cleanup.
- Removing `features/clipboard` sources.
- Wide-screen NavigationRail.
- Automated widget/unit tests for this feature (unless later requested).
