### Task 5: Full analyze + manual Android QA checklist

**Files:** none required (verification only); fix any analyze failures found.

- [ ] **Step 1: Project analyze**

Run: `flutter analyze`  
Expected: No issues found (or only pre-existing unrelated issues 鈥?do not expand scope).

- [ ] **Step 2: Manual QA on a physical/emulated Android device**

Use `flutter run -d <android-device>` (not Chrome). Checklist:

1. Login 鈫?stay foreground ~30s+ 鈫?probes continue; **no** ongoing銆屾鍦ㄥ悓姝ヨ崏绋裤€峸hile resumed.
2. Press Home / switch app (do not swipe-away kill) 鈫?ongoing銆屾鍦ㄥ悓姝ヨ崏绋裤€峚ppears.
3. Create a draft from another client/session 鈫?within ~30s system銆屾柊鑽夌銆峚ppears; tap opens `/drafts`.
4. Return to app 鈫?ongoing notification dismissed; badge/list reflects new draft.
5. Logout 鈫?ongoing gone; no further draft probes/notifications.
6. Kill process from recents 鈫?no requirement to keep notifying (A-tier).

- [ ] **Step 3: Update design/plan status notes if needed**

Mark this plan鈥檚 task checkboxes done in the plan file when execution finishes. Do not commit unless the user asks.

---


