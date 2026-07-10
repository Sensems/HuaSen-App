# Login Page + Theme Color — Design Spec

**Date:** 2026-07-10  
**Status:** Approved (brainstorm)  
**App:** `sebhua_notes_app/` (Flutter)

## Goal

1. Add an email/password **login page** wired to the local backend.
2. Change the app **primary/accent color** to `#ed6f5c`.
3. Persist tokens, guard routes, and schedule **automatic token refresh**.

Out of scope for this iteration: register page, email verification UI, forgot-password flow, WeChat login on this screen, Drift/repository work unrelated to auth.

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Auth method | Email + password via `POST /auth/email/login` |
| API base | Default `http://127.0.0.1:3000` (`API_BASE_URL` dart-define) |
| Delivery scope | Login only;「立即注册」「忘记密码」are placeholders |
| Branding | Title「花森」, slogan「记录，以编辑的方式」 |
| Remember me | **No checkbox**; always persist tokens after successful login |
| Navigation | Login success → `/`; unauthenticated access to protected routes → `/login` |
| Token refresh | Proactive schedule + reactive 401 single-flight refresh |

## Architecture

Dependency direction unchanged: `features → data / core / ui`.

| Layer | Changes |
|-------|---------|
| **Theme** | `AppColors`: primary `#ed6f5c` + light/dark variants; `ColorScheme.primary` (and related) updated so buttons, links, focus rings, FAB follow the new accent |
| **Core** | `AppConstants`: `routeLogin`, default `apiBaseUrl` → `http://127.0.0.1:3000`; concrete `TokenStorage` (`shared_preferences`); `app_router` `/login` + `redirect` guard; refresh-aware `AuthInterceptor`; `TokenRefresher` (or equivalent) for scheduling |
| **Data** | `EmailLoginDto`; `AuthService.emailLogin` → `POST /auth/email/login` |
| **Feature** | `features/auth/login_screen.dart` + Riverpod auth notifier (idle / submitting / error / authenticated) |
| **DI** | Providers for `tokenStorage`, `dio`, `authService`, `authNotifier`, refresher |

### Route guard

- Public: `/login` only (for this iteration).
- All existing app routes (`/`, `/note/:id`, `/settings`, `/clipboard`, …) are protected.
- No access token → redirect to `/login`.
- Has access token and target is `/login` → redirect to `/`.

**Mid-session logout / failed refresh:** `GoRouter` must re-evaluate redirects when auth state changes (e.g. `refreshListenable` wired to `AuthNotifier` / a `ValueNotifier` flipped on login, logout, and token clear). Clearing tokens alone is not enough — the router must navigate to `/login` without waiting for a later user tap.

### Token storage

Extend the existing `TokenStorage` interface (today: access/refresh only) with `expiresAt` get/set, then implement with `shared_preferences`:

- `accessToken`, `refreshToken`
- `expiresAt` (epoch **milliseconds**)

**Expiry formula** (OpenAPI: `expiresIn` is seconds, e.g. `7200`):

```text
expiresAtMs = DateTime.now().millisecondsSinceEpoch + expiresInSeconds * 1000
```

Always write all three on successful login or refresh. `clearToken` removes all auth fields (access, refresh, expiresAt).

## UI

Restore the provided mock (light paper-like background + coral accent):

- Header: coral dot +「花森」+「记录，以编辑的方式」
- Email field (envelope icon) + password field (lock icon, show/hide toggle)
- **No**「记住我」row
-「忘记密码?」→ SnackBar / toast「即将开放」
- Primary button「登录」(`#ed6f5c`); disabled + progress while submitting
- Footer:「还没有账号? **立即注册**」→ same placeholder behavior
- Wide layouts: center form, max width constraint

Copy lives in `ui_strings` (or auth-local constants). Widget colors come from `Theme` / `AppColors`, not hardcoded hex in the screen (except where documenting the brand token in `AppColors`).

## Data flow

### Login success

1. Client validates non-empty email/password and basic email shape.
2. `AuthNotifier.login` → `AuthService.emailLogin` → `POST /auth/email/login` with `EmailLoginDto`.
3. On `ApiResponse.isSuccess` (`code == 200`) with `TokenResponseDto`: persist tokens + `expiresAt`, mark authenticated, schedule refresh, navigate to `/`.

### Errors

| Case | UX |
|------|----|
| Client validation | Inline / form-level message |
| Business failure (e.g. unregistered `20011`) | Show backend `message` |
| Network / timeout | Generic「网络异常，请重试」 |
| Forgot password / register taps |「即将开放」 |

### Token refresh

**Proactive (primary):**

- After login or successful refresh, schedule one timer at `expiresAtMs - skew` (skew ≈ 60s).
- **Cold start:** if persisted tokens exist, resume scheduling (if `expiresAt` already within/past skew, refresh immediately; otherwise schedule until due).
- Call `POST /auth/refresh` with a **dedicated Dio** (no refresh-triggering interceptor loop).
- Success: update storage, reschedule. Failure: clear tokens and notify auth state so the router redirects to `/login`.

**Reactive (401 fallback):**

- On protected-request 401: single-flight refresh; concurrent callers await the same future.
- **Shared gate:** proactive timer and reactive 401 must share one in-flight refresh future (no parallel double refresh).
- Success: retry original request with new access token.
- Failure or 401 on `/auth/refresh` itself: clear tokens, notify auth state (router → `/login`) via `UnauthorizedException` / notifier.
- Do not attempt refresh for auth endpoints (`/auth/email/login`, `/auth/refresh`, etc.).

**Cold-start auth bootstrap:** hydrate auth state from `TokenStorage` before/with the first router redirect evaluation (avoid flash of login then bounce home when tokens already exist).

**Not in scope:** background isolate, multi-device kick strategies.

## Testing & acceptance

### Automated (thin)

- `TokenStorage` read/write/clear for access, refresh, `expiresAt`
- Refresh scheduler fires near `expiresAt - skew`; failure clears session
- Interceptor: single-flight under concurrent 401s; retry on success; clear on refresh failure
- Router: no token → `/login`; token + `/login` → `/`

### Manual

- Login UI matches mock (branding, `#ed6f5c`, no remember-me)
- Real login against `127.0.0.1:3000` reaches home; errors show API message
- Kill app / relaunch stays logged in; clear token or failed refresh returns to login
- Placeholder links only; app-wide primary color updated
- `flutter analyze` clean; smoke on at least Windows or Android

## File touch list (expected)

- `sebhua_notes_app/lib/ui/theme/app_colors.dart` (+ theme consumers as needed)
- `sebhua_notes_app/lib/core/constants/app_constants.dart`, `ui_strings.dart`
- `sebhua_notes_app/lib/core/network/token_storage.dart` + prefs implementation
- `sebhua_notes_app/lib/core/network/auth_interceptor.dart`, `dio_client.dart`
- `sebhua_notes_app/lib/core/router/app_router.dart`
- `sebhua_notes_app/lib/data/models/` (email login DTO in auth DTOs)
- `sebhua_notes_app/lib/data/services/auth_service.dart`
- `sebhua_notes_app/lib/features/auth/login_screen.dart` (+ auth notifier/providers)
- `sebhua_notes_app/pubspec.yaml` (`shared_preferences`)
- Sync `sebhua_notes_app/docs/api-docs.json` from live `/api/docs-json` when convenient (email auth paths)

## Backend reference (live)

| Method | Path | Body |
|--------|------|------|
| POST | `/auth/email/login` | `{ email, password }` → `TokenResponseDto` |
| POST | `/auth/email/register` | `{ email, password, code }` (not built this iteration) |
| POST | `/auth/email/send-code` | `{ email }` (not built this iteration) |
| POST | `/auth/refresh` | `{ refreshToken }` → `TokenResponseDto` |
| POST | `/auth/logout` | Bearer required |

No forgot-password endpoint exists today.
