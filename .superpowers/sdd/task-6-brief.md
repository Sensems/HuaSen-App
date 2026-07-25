# Task 6: Verify

## Goal

Run analysis and document manual QA paths.

## Done when

1. `flutter analyze` on touched files is clean
2. Manual QA checklist written for the user:

- New note: rows show placeholders; open sheet; select category + tags; 完成 updates rows; save includes categoryId/tagIds
- Edit note with existing category/tags: names resolve and display
- Clear category (retap selected) then 完成 + save → categoryId null
- Clear all tags then 完成 + save update → tagIds []
- Create new category/tag in sheet; appears selected; 完成 writes back
- Dismiss sheet with X/barrier → prior selection unchanged
- Wide layout: rows appear under title in editor pane
