# Notes List Search Bar — Interaction & Visual Polish

**Date:** 2026-07-14  
**Status:** Approved for planning  
**Scope:** Home notes list expandable search control only

## Goal

Adjust the notes-list header search so it feels cleaner and more focus-driven: more right padding, no close button, collapse only when empty + blurred, and no terracotta focus ring on the text field (outer capsule outline stays).

## Background

Current control: `ExpandableSearchButton` (`lib/features/notes/widgets/expandable_search_button.dart`).

- Collapsed: square search icon; tap expands and focuses.
- Expanded: text field + search submit + close (clear + collapse).
- Text field already sets `border: InputBorder.none`, but theme `InputDecorationTheme` still paints a focused outline (visible as terracotta in the mock screenshot).
- Collapse/clear is only via the close button; blur does not collapse.

## Decisions

| Topic | Choice |
|-------|--------|
| Approach | Patch existing expandable control (keep collapse animation) |
| Blur with text | Stay expanded; keep keyword visible |
| Blur when empty | Collapse to icon; if list still has a search keyword, call existing `clearSearch` |
| Borders | Remove TextField borders only; keep outer capsule fill + outline |
| Close button | Remove |
| Submit | Unchanged: trailing search icon or keyboard Search |

## Interaction

1. **Collapsed:** Tap search affordance → expand and request focus on the field.
2. **Expanded:** No close button. Layout is `[flexible TextField] [search icon]`.
3. **Tap / focus:** Interacting with the expanded control focuses the input (existing expand path already focuses after layout).
4. **Submit:** Search icon or `TextInputAction.search` → parent `onSubmit` (unchanged).
5. **Unfocus + empty text:** Collapse UI; if `controller` had been cleared but the list keyword is still active, invoke `onCollapsedClear` / `clearSearch` so the list returns to all notes.
6. **Unfocus + non-empty text:** Remain expanded; do not clear text; do not auto-submit.

Canceling an active search is done by clearing the field and unfocusing (or submitting an empty keyword if that path is already supported by the notifier).

## Visual

- Outer `AnimatedContainer`: keep elevated fill, 12px radius, existing light outline.
- `TextField` decoration: force `InputBorder.none` for enabled / focused / disabled / error borders so theme focus ring does not show.
- Remove close `IconButton`.
- Increase right inset after the search icon (about 12–16 logical px from icon to capsule edge) so the expanded bar does not feel cramped.
- Do not change global `AppTheme` / `InputDecorationTheme` for this polish.

## Architecture / data flow

Unchanged overall:

```
ExpandableSearchButton
  → onSubmit → NotesListScreen → NotesListNotifier.search(keyword)
  → onCollapsedClear → NotesListNotifier.clearSearch()
```

Widget-local state only:

- `_expanded` bool
- `FocusNode` listener: on focus loss, if `controller.text.trim().isEmpty` then collapse (+ clearSearch when needed)

No Drift, no API contract changes, no shell/nav changes.

## Error handling

Out of scope for this polish. Search/list error UX is unchanged.

## Testing / verification

Manual QA (preferred for this phase):

1. Expand: no close button; right padding looks looser.
2. Focus field: no terracotta input ring; outer capsule outline still visible.
3. Type keyword, unfocus: stays expanded with text.
4. Clear text, unfocus: collapses to icon; if a search was active, list reloads without keyword.
5. Submit via icon and keyboard still works.

No new automated tests unless requested.

## Out of scope

- Notes list API / pagination / filter tabs
- Global theme input borders
- Auth or other screens’ search patterns
- Changing max expanded width or brand header layout beyond the search control

## Files likely touched

- `lib/features/notes/widgets/expandable_search_button.dart` (primary)
- `lib/features/notes/notes_list_screen.dart` only if callback wiring needs a small cleanup
