# Settings + Account Edit + WeChat Bind — Design Spec

**Date:** 2026-07-14  
**Status:** Approved (brainstorm)  
**App:** Flutter app at repository root  
**Visual reference:** Attached mock (settings / account edit / WeChat bind)

## Goal

Ship **UI-only** screens aligned with the mock:

1. **Settings** — rebuild `SettingsScreen` (account card, appearance, sync toggles, threshold sliders, account binding).
2. **Account info edit** — new page for avatar / username / bound email display.
3. **WeChat bind** — new page for bind-code entry, paste, confirm, and step instructions.

Out of scope: REST / Repository / Drift, real profile or WeChat bind/unbind APIs, email-change flow, avatar file picker, bottom-nav changes (clipboard stays deep-link only), automated tests (manual QA only), Feature domain layering migration.

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Settings content | **B** — follow mock + keep dark-mode row |
| Sub-page routing | **A** — routes outside `ShellRoute` (hide bottom tabs), like note editor |
| Dark mode | **A** — wire Switch to existing `themeModeProvider` |
| WeChat bind UX (no API) | **A** — interactive input/paste/clear/confirm + `toly_ui` success toast; settings WeChat row shows「已绑定」+「解绑」 |
| Account edit UX (no API) | **A** — editable username; save / avatar → toast; email row display-only, no navigation |
| Architecture | **A** — flat Screens + local `StatefulWidget` state (except theme); no Notifiers this iteration |
| Thresholds | Keep existing `Slider` with `divisions` (not static `< N MB` labels from mock) |
| Theme / accent | Global `AppColors` / `ColorScheme.primary` (`#ed6f5c`); light canvas `#f8f7f4` |
| Feedback | `toly_ui` / `tolyui_message` for user-visible toasts |
| Verification | Manual QA only |

## Architecture

Dependency direction unchanged: `features → ui / data / core` (this work uses `ui` + `core` only).

```
SettingsScreen (Shell tab)
  → push /settings/account  → AccountEditScreen (no shell)
  → push /settings/wechat-bind → WechatBindScreen (no shell)

Dark-mode Switch → themeModeProvider (persisted)
Other controls → local setState placeholders
```

| Layer | Changes |
|-------|---------|
| **Core / constants** | Add `routeSettingsAccount`, `routeSettingsWechatBind`; Chinese copy in `UiStrings` |
| **Core / router** | Register two `GoRoute`s **outside** `ShellRoute`; keep `/settings` inside shell |
| **Feature settings** | Rewrite `settings_screen.dart` as `ConsumerStatefulWidget` (needs `themeModeProvider`); add `account_edit_screen.dart` |
| **Feature wechat** | Add `wechat_bind_screen.dart` (alongside drafts) |
| **UI / theme** | Reuse `AppColors` / `AppTheme`; wire Switch via `ref.watch` / `notifier.set` or `toggle`. **Do not** add SharedPreferences persistence for theme in this iteration (`themeModeProvider` is in-memory; `keyThemeMode` exists but is unused) |

## Routes

| Path | Name | Shell | Screen |
|------|------|-------|--------|
| `/settings` | `settings` | Yes | `SettingsScreen` |
| `/settings/account` | `settings-account` | No | `AccountEditScreen` |
| `/settings/wechat-bind` | `settings-wechat-bind` | No | `WechatBindScreen` |

Navigation: `context.push` from settings; AppBar back / system back pops to settings.

Auth redirect: both new routes require authentication (not added to public-route list).

## Screen specs

### 1. Settings (`SettingsScreen`)

**Header:** Title「设置」; **no** back button (tab page; mock’s leading back is not used).

**Sections (top → bottom):**

1. **Account card** — circular avatar (initial「张」), display name「张明」, email `zhangming@example.com`, trailing coral「编辑」→ `/settings/account`.
2. **Appearance** — dark-mode row (icon + title + hint + Switch) bound to `themeModeProvider`.
3. **Sync settings** — two rows with Switch (local bools, default **on**):
   - 草稿箱同步
   - 剪贴板同步
4. **Sync thresholds** — two rows with icon, title, trailing current value, and `Slider`:
   - Image: min 1, max 50, `divisions: 49`, default 10 MB
   - File: min 1, max 200, `divisions: 199`, default 50 MB
   - Local state only (not persisted)
5. **Account binding**
   - Email: show fake email +「已绑定」status (not tappable)
   - WeChat:「已绑定」+ coral「解绑」
     - **Hit targets:**「解绑」text is its own `GestureDetector` / button → toast only (e.g.「解绑功能即将开放」); **rest of the WeChat row** → `push` `/settings/wechat-bind` (preview bind UI). Do not navigate when tapping「解绑」.

**Layout:** `SingleChildScrollView`; wide screens (`width >= 600`) constrain content to `maxWidth: 600` centered.

**Visual:** Soft canvas background; white/surface cards with rounded corners (~14–16) and light border/shadow consistent with notes list; primary coral for accents and active switches.

### 2. Account edit (`AccountEditScreen`)

**AppBar:** Leading back; trailing coral「保存」→ toast「已保存」then `pop`.

**Body:**

- Large centered avatar with coral camera badge; tap → toast「头像编辑即将开放」(no image picker).
- Username `TextField`, initial「张明」(local state).
- Bound email: read-only row with chevron decoration; caption that email changes are done from settings; **tap does nothing**.
- Bottom full-width coral button「保存修改」→ same as AppBar save: toast「已保存」then `pop` (does **not** write back into settings placeholder state this iteration).

### 3. WeChat bind (`WechatBindScreen`)

**AppBar:** Back only.

**Body:**

- Green circular WeChat-style mark + title「绑定微信」+ short explanatory sentence.
- White card: bind-code field (may prefill example `HS-8K2M-N4X`) with clear;「粘贴」reads clipboard into the field; green「确认绑定」→ `toly_ui` success toast (e.g.「绑定成功，消息将同步至草稿箱」).
- Numbered steps 1–4 (green badges): follow OA → send keyword → copy code → confirm in app.

**Note:** Do **not** show a persistent bottom「already bound」success banner on load; success feedback is toast-only after confirm.

## Placeholder data

| Field | Value |
|-------|-------|
| Display name | 张明 |
| Avatar initial | 张 |
| Email | zhangming@example.com |
| WeChat on settings | Always「已绑定」UI |
| Example bind code | HS-8K2M-N4X |

## Error / edge handling (UI-only)

| Action | Behavior |
|--------|----------|
| Paste with empty clipboard | Toast that clipboard is empty / nothing to paste |
| Confirm bind with empty code | Toast validation hint; do not show success |
| Unbind | Toast only; binding status UI stays「已绑定」 |
| Theme toggle | Immediate theme change via `themeModeProvider` (session only; resets to light on cold start until persistence is implemented later) |

## Testing

Manual QA only:

- [ ] Settings tab shows all sections; bottom nav visible
- [ ] Dark mode toggles app theme immediately; cold start returns to light (current provider behavior)
- [ ] Sync switches and threshold sliders move locally
- [ ] Edit → account page (no bottom nav); AppBar/底部保存 → toast then back; avatar toast; system back returns
- [ ] WeChat row body → bind page;「解绑」→ toast only (stay on settings); paste / clear / confirm (empty vs filled); back returns
- [ ] Unbind toast does not crash; status remains bound
- [ ] Wide layout: settings content centered ≤600px

## Non-goals reminder

No API wiring, no shared profile provider between settings and account edit, no email-change page, no real WeChat OAuth / OA flow, no automated widget tests.
