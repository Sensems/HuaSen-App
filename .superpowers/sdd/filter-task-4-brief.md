### Task 4: End-to-end verification

**Files:**
- None (verification only)

- [ ] **Step 1: Full analyze on notes feature paths**

Run:

```bash
flutter analyze lib/features/notes lib/data/services/notes_service.dart lib/core/constants/ui_strings.dart
```

Expected: No issues introduced by this work.

- [ ] **Step 2: Manual QA checklist**

With app running (authenticated):

1. Notes home tab row shows filter icon on the right (icon only).
2. Open sheet: category single-select, tag multi-select, no add rows; title「筛选」; 清除 + 确认.
3. Select category and/or tags → 确认 → list reloads; network shows `category` and/or `tags`; badge dot appears.
4. Tap 清除 → filters cleared, badge gone, list reloads without those params.
5. Open sheet, deselect all, 确认 → same as clear.
6. With filters active, dismiss via X → badge and list unchanged.
7. With filters active, switch 全部/置顶/最近 and search → requests still include category/`tags`.

---
