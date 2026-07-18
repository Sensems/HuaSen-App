# Settings + Account + WeChat Bind — API Wiring Design

**Date:** 2026-07-15  
**Status:** Approved (brainstorm)  
**App:** Flutter app at repository root  
**Supersedes (API scope):** UI-only non-goals in `2026-07-14-settings-pages-design.md` for profile / update / bind / avatar. Visual layout from that spec remains the baseline unless noted.

## Goal

Wire existing REST + DTOs into the already-shipped Settings / Account edit / WeChat bind screens:

1. **Settings** — account card, email row, WeChat row driven by `GET /user/profile`.
2. **Account edit** — load profile; save nickname (+ optional avatar) via upload + `POST /user/update`.
3. **WeChat bind** — submit binding code via `POST /user/bind`; refresh profile so settings shows bound state.

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Scope | Profile display + nickname update + WeChat bind + avatar upload (local preview, upload on save) |
| Architecture | Shared `userProfileProvider` (`AsyncNotifier`); screens call thin `UserService` / `StorageService` (no new Repository) |
| WeChat status | `UserProfileDto.wxBound` from `GET /user/profile` |
| Avatar UX | Pick → local preview only; on Save → upload bytes then `update` with `avatar` URL (+ nickname) |
| Upload API | Extend `StorageService.uploadFile` to accept bytes + filename / `MultipartFile` (no `dart:io` `File`) so Web + desktop/mobile work |
| Unbind | Still toast「即将开放」; no unbind API |
| Sync toggles / thresholds | Remain local placeholders |
| Logout / email change | Out of scope |
| Feedback | `toly_ui` / `tolyui_message` with backend `message` for API success/errors |
| Verification | Manual QA only (no new automated tests unless asked) |
| Settings section order | Account → sync → thresholds → binding → appearance (外观 last) |
| Branch / worktree | Work on `master` only |

## Architecture

```
SettingsScreen / AccountEditScreen / WechatBindScreen
  → userProfileProvider (AsyncNotifier)
       → UserService.getProfile / updateProfile / bindWechat
  → (account save only) StorageService.uploadFile(bytes)
       → then UserService.updateProfile
```

Dependency direction unchanged: `features → ui / data / core`.

| Layer | Changes |
|-------|---------|
| **Models** | `UserProfileDto`: add `bool? wxBound` |
| **Services** | `StorageService.uploadFile`: bytes + filename (remove `dart:io` `File`); `UserService` already has profile/update/bind |
| **Providers** | New `userProfileProvider` under `features/settings/` (or shared settings provider file); uses `userServiceProvider` |
| **Screens** | Wire `SettingsScreen`, `AccountEditScreen`, `WechatBindScreen` to provider + services; keep layout |
| **Routes** | No new routes; `/settings/account` and `/settings/wechat-bind` stay outside `ShellRoute` |

### `userProfileProvider`

- `AsyncNotifier<UserProfileDto>` (or equivalent `AsyncValue` pattern used elsewhere).
- `build()` → `GET /user/profile` via `UserService.getProfile`.
- `refresh()` after successful update or bind.
- Screens `watch` for display; mutations may call services then `refresh()`, or expose notifier methods that do both.

### Upload signature (target)

```dart
Future<ApiResponse<UploadFileResponseDto>> uploadFile(
  List<int> bytes, {
  required String filename,
  String? type,
});
```

Use `MultipartFile.fromBytes` (or equivalent). Optional `type` for image if backend expects it.

## APIs

| Method | Path | Use |
|--------|------|-----|
| GET | `/user/profile` | Load profile (`id`, `email`, `nickname`, `avatar`, `wxBound`, …) |
| POST | `/user/update` | Body: `UpdateProfileDto` (`nickname?`, `avatar?`) |
| POST | `/user/bind` | Body: `BindUserDto` (`bindingCode`) |
| POST | `/storage/upload` | Multipart file → `url` for avatar |

OpenAPI does not publish a full profile response schema; client fields are optional where unknown, with `wxBound` required for binding UI.

## Screen specs

### 1. Settings (`SettingsScreen`)

**Section order:** account card → sync toggles → threshold sliders → account binding → appearance (dark mode).

**Account card** (`watch(userProfileProvider)`):

- Loading: small progress in card area.
- Error: short message + retry → `refresh()`.
- Data: `nickname` (fallback: email local-part or「未设置」); `email`; avatar `NetworkImage` if `avatar` non-empty else initial from nickname/email.

**Email binding row:** non-empty `email` → show email +「已绑定」; else「未绑定」. Not tappable.

**WeChat row** (hit targets unchanged):

- `wxBound == true` → status「已绑定」+「解绑」→ toast only; **rest of row** still → `/settings/wechat-bind` (page shows already-bound UI).
- else → status「未绑定」; row tap → `/settings/wechat-bind`.

**Unchanged local UI:** sync switches, sliders, dark-mode `themeModeProvider`.

### 2. Account edit (`AccountEditScreen`)

- Prefill from `userProfileProvider` (nickname, read-only email, avatar).
- Avatar tap → `file_picker` (images only) → keep `Uint8List` for local preview; **do not upload yet**.
- Save (AppBar + bottom button):
  1. If new bytes present → `StorageService.uploadFile` → take `url`.
  2. `UserService.updateProfile(UpdateProfileDto(nickname: …, avatar: url?))`.
  3. Success toast (backend `message`) → `refresh()` profile → `pop`.
- On failure: error toast (backend `message`); keep draft nickname/preview; allow retry.
- While saving: disable save controls + show loading.
- Email row remains display-only.

### 3. WeChat bind (`WechatBindScreen`)

- Empty bind-code field by default (remove example prefill).
- Paste / clear unchanged (empty clipboard → existing validation toast).
- Confirm → `UserService.bindWechat(BindUserDto(bindingCode: …))`.
- Success → toast (backend `message`) → `refresh()` → `pop`.
- If profile already `wxBound == true` on entry: show already-bound messaging; disable confirm (or guide back).
- Binding in flight: disable confirm button.
- Steps 1–4 UI copy unchanged.

## Error / edge handling

| Case | Behavior |
|------|----------|
| Profile load fail | Settings card: message + retry |
| Update / upload / bind fail | `toly_ui` error with backend `message` |
| Empty bind code | Client validation toast; no API call |
| Empty clipboard paste | Existing empty-clipboard toast |
| Unbind | Coming-soon toast only |
| Partial profile JSON | Optional DTO fields; safe fallbacks for display |

## Testing (manual QA)

- [ ] Settings shows real nickname / email / avatar; loading and retry work
- [ ] `wxBound` false →「未绑定」→ bind page; true →「已绑定」+ unbind toast
- [ ] Account: change nickname → save → settings reflects change
- [ ] Account: pick image → local preview → save → avatar updates (Chrome and/or desktop)
- [ ] Bind success → settings WeChat row shows bound
- [ ] API errors surface backend `message` via `toly_ui`
- [ ] Section order: appearance is last; wide layout ≤600px still OK

## Non-goals

- Logout, email change flow, WeChat unbind API, OAuth/OA automation
- Persisting sync toggles / thresholds
- Drift / Repository layer
- Automated widget/unit tests for this feature
- Redesigning visual mock beyond data wiring and section-order fix if needed
