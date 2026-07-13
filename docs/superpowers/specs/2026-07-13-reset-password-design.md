# Reset Password Page — Design Spec

**Date:** 2026-07-13  
**Status:** Approved (brainstorm)  
**App:** Flutter app at repository root

## Goal

1. Add a **reset password** page matching the provided mock.
2. Wire `POST /auth/email/send-code` with `purpose: reset_password` and `POST /auth/email/reset-password`.
3. Verification-code button uses a **60-second** countdown after a successful send (label「重新发送 Ns」).
4. Connect login「忘记密码?」→ reset page with email prefill; success → login with a success prompt.

Out of scope: auto-login after reset, token persistence from reset response, terms checkbox, shared form-widget extraction, WeChat flows, domain-layer refactor, automated tests (manual QA only).

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Approach | **A** — mirror register page; extend existing `AuthNotifier` + reuse `AuthService` |
| After success | `toly_ui`「密码重置成功，请登录」→ `go` `/login`; **do not** persist tokens or auto-login |
| Email from login | Prefill via `GoRouter` `extra` (`String` email); deep link without `extra` → empty field |
| Send-code purpose | **`reset_password`** via `EmailCodePurpose.resetPassword` |
| Password rule | Same as register: **≥8 chars, must contain letters and digits** |
| Confirm password | Client-only; not sent to API |
| Terms checkbox | **Not** on reset page (register-only) |
| Code countdown | 60s; start only after send-code succeeds; cancel Timer on dispose |
| Theme / accent | Global `AppColors` → `ColorScheme.primary` (`#ED6F5C`); no per-page hex |
| Verification | Manual testing only |

## Backend reference

| Method | Path | Body | Response |
|--------|------|------|----------|
| POST | `/auth/email/send-code` | `{ email, purpose: "reset_password" }` | 200 send success (no typed `data` schema) |
| POST | `/auth/email/reset-password` | `{ email, password, code }` | success wrapper; **no** token payload for client use |

Already implemented (no DTO/Service changes required this iteration):

- `EmailSendCodeDto` + `EmailCodePurpose.resetPassword` (`@JsonValue('reset_password')`)
- `EmailResetPasswordDto`
- `AuthService.sendEmailCode` / `emailResetPassword`

OpenAPI notes:

- Password: ≥8, must include letters and numbers.
- `code`: 6-digit numeric string.
- Reset success must **not** set `AuthStatus.authenticated` or write tokens.

## Architecture

Dependency direction unchanged: `features → data / core / ui`.

| Layer | Changes |
|-------|---------|
| **Core** | `AppConstants.routeResetPassword = '/reset-password'`; `ui_strings` reset-password copy; `app_router` public route + redirect allow-list |
| **Data** | No new DTOs/services — reuse existing |
| **Feature** | New `reset_password_screen.dart`; extend `AuthNotifier`: `sendCode` gains `purpose` param; add `resetPassword(...) → bool` |
| **Login** |「忘记密码?」→ `context.push(routeResetPassword, extra: email.trim())`; remove「即将开放」for this action |

### Route guard

Public (unauthenticated allowed):

- `/login`
- `/register`
- `/reset-password` ← **new**
- `/legal/terms`
- `/legal/privacy`

Protected: all other app routes (unchanged).

- Unauthenticated + non-public → `/login`
- Authenticated + public auth/legal routes → `/` (home), same as today

### AuthNotifier changes

- `sendCode(String email, {required EmailCodePurpose purpose})`  
  - Register screen passes `EmailCodePurpose.register`  
  - Reset screen passes `EmailCodePurpose.resetPassword`  
  - Keep `isSendingCode` independent of `isSubmitting`
- `resetPassword({ email, password, confirmPassword, code }) → Future<bool>`  
  - Validation mirrors register (email / 6-digit code / password strength / match) **without** terms  
  - On API success: clear submitting flags, return `true`; **never** persist tokens or flip to authenticated  
  - On failure: set `errorMessage` from API message or network string

## UI

Restore the provided reset-password mock; accent via theme `colorScheme.primary`.

- Title「重置密码」; subtitle「输入注册邮箱，我们将发送验证码」
- Fields (prefix icons, rounded inputs like register/login):
  - Email —「邮箱地址」(prefilled when navigated from login)
  - Code —「验证码」+ trailing outlined get-code control  
    - Idle:「获取验证码」  
    - Countdown:「重新发送 Ns」in primary color; disabled while `> 0` or `isSendingCode`
  - New password —「新密码」(show/hide toggle, consistent with login/register)
  - Confirm —「确认新密码」(show/hide)
- Primary button「确认重置」; submitting shows progress / disables double-submit
- Footer link「← 返回登录」→ `/login`
- Form-area `errorMessage` in error color (same pattern as register)
- Success / code-sent feedback via `toly_ui` `$message.success`, not ad-hoc SnackBars

## Data flow

```
Login「忘记密码?」
  → push /reset-password (email extra)
  → ResetPasswordScreen (prefill email)

获取验证码
  → AuthNotifier.sendCode(email, purpose: resetPassword)
  → AuthService.sendEmailCode → POST /auth/email/send-code
  → success: $message「验证码已发送」+ start 60s timer
  → failure: errorMessage on form

确认重置
  → AuthNotifier.resetPassword(...)
  → AuthService.emailResetPassword → POST /auth/email/reset-password
  → success: $message「密码重置成功，请登录」→ go /login
  → failure: errorMessage on form
```

## Error handling

| Case | Behavior |
|------|----------|
| Client validation | Set `errorMessage`; do not call API |
| API `code != 200` | Show `response.message` |
| Network (`DioException`) |「网络异常，请重试」 |
| Send vs submit | Independent `isSendingCode` / `isSubmitting` |
| Countdown | Only after successful send-code; cancel on dispose |
| Enter page | `clearError` in post-frame callback |

## File touch list

| File | Action |
|------|--------|
| `lib/core/constants/app_constants.dart` | Add `routeResetPassword` |
| `lib/core/constants/ui_strings.dart` | Reset-password strings |
| `lib/core/router/app_router.dart` | Public route + builder |
| `lib/features/auth/auth_notifier.dart` | `sendCode` purpose; `resetPassword` |
| `lib/features/auth/reset_password_screen.dart` | **New** screen |
| `lib/features/auth/login_screen.dart` | Wire forgot-password + email pass-through |
| `lib/features/auth/register_screen.dart` | Pass `purpose: register` into updated `sendCode` |
| `AGENTS.md` | Public routes / auth scope if needed after ship |

## Manual QA checklist

1. Login「忘记密码?」opens reset page with email prefilled.
2. Get-code disabled while countdown / `isSendingCode`; after success shows 60s「重新发送 Ns」.
3. Network: send-code body includes `purpose: "reset_password"`; reset-password body is `{ email, password, code }` only.
4. Weak password, mismatch, empty/invalid code show clear errors.
5. Success shows「密码重置成功，请登录」, lands on login, no tokens written.
6.「返回登录」works; unauthenticated deep link `/reset-password` is allowed.

## Non-goals (explicit)

- Auto-login or session restore after reset
- Extracting shared auth form widgets
- Changing OpenAPI / regenerating DTOs (already present)
- Automated widget/unit tests for this feature
