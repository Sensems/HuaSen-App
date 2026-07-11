# Email Register Page — Design Spec

**Date:** 2026-07-11  
**Status:** Approved (brainstorm)  
**App:** Flutter app at repository root

## Goal

1. Add an email **registration page** matching the provided mock.
2. Wire `POST /auth/email/send-code` and `POST /auth/email/register`.
3. Verification-code button uses a **60-second** countdown after a successful send.
4. Connect login「立即注册」→ register; register success → login with a success prompt.

Out of scope: auto-login after register, forgot-password, WeChat register, domain-layer refactor, automated tests (manual QA only).

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Approach | **A** — extend existing `AuthNotifier` + `AuthService` (same pattern as login) |
| After success | Navigate to `/login`; SnackBar「注册成功，请登录」; **do not** persist tokens |
| Legal links | Navigate to placeholder pages (`/legal/terms`, `/legal/privacy`) |
| Terms checkbox | Required; tap「注册」without check → error message (button stays enabled) |
| Password rule | Align with OpenAPI: **≥8 chars, must contain letters and digits** (not uppercase-only) |
| Confirm password | Client-only; not sent to API |
| Code countdown | 60s; start only after send-code succeeds; cancel Timer on dispose |
| Verification | Manual testing only |

## Backend reference

| Method | Path | Body | Response |
|--------|------|------|----------|
| POST | `/auth/email/send-code` | `{ email }` | 200 send success (no typed `data` schema) |
| POST | `/auth/email/register` | `{ email, password, code }` | `TokenResponseDto` |

OpenAPI notes:

- Password description: ≥8, must include letters and numbers (example `Abc12345`).
- `code`: 6-digit numeric string.
- Register returns tokens; client **discards** them for this iteration.

## Architecture

Dependency direction unchanged: `features → data / core / ui`.

| Layer | Changes |
|-------|---------|
| **Core** | `AppConstants`: `routeRegister`, `routeLegalTerms`, `routeLegalPrivacy`; `ui_strings` register/legal copy; `app_router` public routes + redirect allow-list |
| **Data** | `EmailSendCodeDto`, `EmailRegisterDto` in `auth_dtos.dart`; `AuthService.sendEmailCode`, `emailRegister` |
| **Feature** | `register_screen.dart`; optional thin `legal_placeholder_screen.dart`; extend `AuthState` / `AuthNotifier` with `sendCode` / `register` + `isSendingCode` |
| **Login** |「立即注册」→ `context.push` / `go` `/register` (replace coming-soon SnackBar) |

### Route guard

Public (unauthenticated allowed):

- `/login`
- `/register`
- `/legal/terms`
- `/legal/privacy`

Protected: all other app routes (unchanged).

- Unauthenticated + non-public → `/login`
- Authenticated + public auth/legal routes → `/` (home), same idea as today’s login redirect

## UI

Restore the provided register mock; accent via theme primary `#ed6f5c`.

- Title「创建账号」; subtitle「使用邮箱注册 花森」
- Fields (prefix icons, rounded inputs like login):
  - Email —「邮箱地址」
  - Code —「验证码」+ trailing outlined「获取验证码」(countdown label while active)
  - Password —「设置密码」(show/hide toggle, consistent with login)
  - Confirm —「确认密码」(show/hide)
- Checkbox row:「我已阅读并同意《用户协议》和《隐私政策》」; linked phrases use primary color
- Primary button「注册」; submitting shows progress / disables double-submit
- Footer:「已有账号？**返回登录**」→ `/login`

Wide layouts: center form, max width ~400 (match login).

Legal placeholder: AppBar title + short body text that content is coming later; back navigates previous.

## Data flow

### Send code

1. Validate email (non-empty + format).
2. Set `isSendingCode`; call `sendEmailCode`.
3. On success: clear send error; UI starts 60s countdown; button disabled until 0.
4. On failure / network: show message; **do not** start countdown.
5. Clear `isSendingCode` in `finally`.

### Register

1. Validate: email, 6-digit code, password rule, confirm match, terms checked.
2. Set `isSubmitting`; call `emailRegister`.
3. On success (`response.isSuccess`, same gate as login): **do not** write `TokenStorage`; keep `AuthStatus.unauthenticated`; navigate to `/login` with success SnackBar. (Token fields in `data` may be present; ignore them.)
4. On API / network failure: show `errorMessage` / SnackBar pattern consistent with login.
5. Clear `isSubmitting` in `finally`.

### AuthState additions

- `isSendingCode` (bool) — independent of `isSubmitting` so send-code and register/login do not block each other incorrectly.
- Reuse `errorMessage` for form/API errors (register screen watches notifier like login).

`sendCode` success signaling for countdown: return `bool` / use a clear success path from the notifier method so the screen starts the Timer only when the call succeeded (avoid starting countdown solely from absence of error if submit was cancelled).

## Error & validation copy

Centralize strings in `UiStrings` (examples; exact wording may be tuned in implementation):

| Case | Message direction |
|------|-------------------|
| Empty / invalid email | Same spirit as login email errors |
| Empty / non-6-digit code | Ask for 6-digit code |
| Weak password | State ≥8 and must include letters and digits |
| Confirm mismatch | Passwords must match |
| Terms unchecked | Must agree to terms |
| Network | Same as login network error |
| API `message` | Prefer backend `message` when present |

## Testing

Manual only (per product owner). No new automated test requirement in this iteration.

Suggested manual checks: validation matrix, countdown start/cancel, register success → login prompt, legal navigation, login↔register links, unauthenticated guard for new public routes.

## Files likely touched

- `lib/data/models/auth_dtos.dart` (+ codegen)
- `lib/data/services/auth_service.dart`
- `lib/features/auth/auth_state.dart`
- `lib/features/auth/auth_notifier.dart`
- `lib/features/auth/login_screen.dart`
- `lib/features/auth/register_screen.dart` (new)
- `lib/features/auth/legal_placeholder_screen.dart` (new, or inline)
- `lib/core/router/app_router.dart`
- `lib/core/constants/app_constants.dart`
- `lib/core/constants/ui_strings.dart`

## Non-goals (explicit)

- Persisting or using register-returned tokens
- Forgot-password endpoint/UI
- Real legal document content
- Feature domain/data split under `features/auth/`
