# Task 4: Design spec document

**Files:**
- Create: `docs/superpowers/specs/2026-07-25-notes-list-swipe-tabs-design.md`
- Plan already at: `docs/superpowers/plans/2026-07-25-notes-list-swipe-tabs.md` (do not rewrite unless needed for consistency)

## Steps

- [ ] Write a concise design spec matching the **implemented** architecture:
  - Goal / user behavior (swipe + tap; keep scroll/data per tab)
  - Architecture: fixed header/tabs + PageView.builder; family `notesListProvider(tab)`; shared `notesListQueryProvider`; `refreshExistingNotesLists`
  - Data flow diagram (mermaid OK)
  - Behavior details (lazy first visit, KeepAlive, query reload, pull-to-refresh per page, mutation refresh)
  - Out of scope
- [ ] Align with what was actually built (PageView.builder, WidgetRef helper, etc.)
- [ ] Do **not** commit.
- [ ] Write report to `.superpowers/sdd/swipe-task-4-report.md`.

## Acceptance

Spec file present and consistent with implementation.

## Global Constraints

- master only; no commits; Chinese or English OK — prefer clear technical Chinese/English mix matching other specs in docs/superpowers/specs/.
