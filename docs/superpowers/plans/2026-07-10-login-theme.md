# Login Page + Theme Color Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship email/password login (花森 UI), coral primary `#ed6f5c`, persisted tokens, route guards, and proactive + reactive token refresh against `http://127.0.0.1:3000`.

**Architecture:** Feature login UI → Riverpod `AuthNotifier` → `AuthService` / `TokenRefresher` → `TokenStorage` (`shared_preferences`). `GoRouter.redirect` + `refreshListenable` react to auth state. `AuthInterceptor` shares a single-flight refresh gate with the proactive scheduler. Dedicated Dio for `/auth/refresh` avoids interceptor loops.

**Tech Stack:** Flutter, Riverpod 3, go_router, Dio, freezed/json_serializable, shared_preferences, flutter_test.

**Spec:** `docs/superpowers/specs/2026-07-10-login-theme-design.md`

**Working directory for all Flutter commands:** `sebhua_notes_app/`

**Git note:** Workspace may have no `.git`. If `git status` fails, skip commit steps and continue.

---

## File structure

| File | Responsibility |
|------|----------------|
| `lib/ui/theme/app_colors.dart` | Brand coral `#ed6f5c` + ColorScheme |
| `lib/core/constants/app_constants.dart` | `routeLogin`, default API URL, storage keys, refresh skew |
| `lib/core/constants/ui_strings.dart` | Login copy |
| `lib/core/network/token_storage.dart` | Interface + `expiresAt` |
| `lib/core/network/shared_preferences_token_storage.dart` | Prefs implementation |
| `lib/core/network/token_refresher.dart` | Single-flight refresh + schedule |
| `lib/core/network/auth_interceptor.dart` | Bearer inject + 401 → shared refresh → retry |
| `lib/core/network/dio_client.dart` | Wire interceptor + optional refresh Dio factory |
| `lib/core/providers/core_providers.dart` | `tokenStorageProvider`, `dioProvider`, `authServiceProvider` |
| `lib/core/router/app_router.dart` | `/login`, redirect, `refreshListenable` |
| `lib/data/models/auth_dtos.dart` | `EmailLoginDto` (+ codegen) |
| `lib/data/services/auth_service.dart` | `emailLogin` |
| `lib/features/auth/auth_state.dart` | Immutable auth UI/session state |
| `lib/features/auth/auth_notifier.dart` | Bootstrap, login, clear, schedule refresh |
| `lib/features/auth/login_screen.dart` | Login UI |
| `test/core/network/shared_preferences_token_storage_test.dart` | Storage tests |
| `test/core/network/token_refresher_test.dart` | Refresh / schedule tests |
| `test/widget_test.dart` | Expect login when unauthenticated |

---

### Task 1: Theme primary → `#ed6f5c`

**Files:**
- Modify: `sebhua_notes_app/lib/ui/theme/app_colors.dart`

- [ ] **Step 1: Update brand colors**

Replace amber brand tokens with coral (keep names or rename to `coral` / `coralLight` / `coralDark` — prefer rename + update ColorScheme refs):

```dart
static const Color coral = Color(0xFFED6F5C);
static const Color coralLight = Color(0xFFF08A7A);
static const Color coralDark = Color(0xFFD45745);
```

Wire `lightColorScheme.primary` / `tertiary` / `inversePrimary` and dark scheme equivalents to these. Update file doc comment (no longer “warm amber”).

- [ ] **Step 2: Sanity-check theme still builds**

Run: `cd sebhua_notes_app && dart analyze lib/ui/theme/`

Expected: no issues.

- [ ] **Step 3: Commit (if git available)**

```bash
git add sebhua_notes_app/lib/ui/theme/app_colors.dart
git commit -m "style: set app primary accent to #ed6f5c"
```

---

### Task 2: Constants, strings, dependency

**Files:**
- Modify: `sebhua_notes_app/pubspec.yaml`
- Modify: `sebhua_notes_app/lib/core/constants/app_constants.dart`
- Modify: `sebhua_notes_app/lib/core/constants/ui_strings.dart`

- [ ] **Step 1: Add dependency**

Under `dependencies:` add:

```yaml
shared_preferences: ^2.5.3
```

Run: `cd sebhua_notes_app && flutter pub get`

Expected: success.

- [ ] **Step 2: Extend AppConstants**

Add (do **not** duplicate `apiBaseUrl` — only change its `defaultValue`):

```dart
static const String routeLogin = '/login';

static const String keyAccessToken = 'access_token';
static const String keyRefreshToken = 'refresh_token';
static const String keyTokenExpiresAt = 'token_expires_at';

/// Seconds before access-token expiry to trigger proactive refresh.
static const int tokenRefreshSkewSeconds = 60;
```

Change existing `apiBaseUrl` `defaultValue` from `https://api.example.com` to `http://127.0.0.1:3000`.

- [ ] **Step 3: Add UiStrings for login**

```dart
// --- Login ---
static const String loginBrandTitle = '花森';
static const String loginBrandSlogan = '记录，以编辑的方式';
static const String loginEmailHint = '邮箱地址';
static const String loginPasswordHint = '密码';
static const String loginButton = '登录';
static const String loginForgotPassword = '忘记密码?';
static const String loginNoAccount = '还没有账号? ';
static const String loginRegisterNow = '立即注册';
static const String loginComingSoon = '即将开放';
static const String loginNetworkError = '网络异常，请重试';
static const String loginEmailRequired = '请输入邮箱地址';
static const String loginEmailInvalid = '邮箱格式不正确';
static const String loginPasswordRequired = '请输入密码';
```

- [ ] **Step 4: Commit**

```bash
git add sebhua_notes_app/pubspec.yaml sebhua_notes_app/pubspec.lock \
  sebhua_notes_app/lib/core/constants/app_constants.dart \
  sebhua_notes_app/lib/core/constants/ui_strings.dart
git commit -m "chore: add login constants and shared_preferences"
```

---

### Task 3: TokenStorage + SharedPreferences implementation (TDD)

**Files:**
- Modify: `sebhua_notes_app/lib/core/network/token_storage.dart`
- Create: `sebhua_notes_app/lib/core/network/shared_preferences_token_storage.dart`
- Create: `sebhua_notes_app/test/core/network/shared_preferences_token_storage_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sebhua_notes/core/network/shared_preferences_token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists and clears access, refresh, expiresAt', () async {
    final prefs = await SharedPreferences.getInstance();
    final storage = SharedPreferencesTokenStorage(prefs);

    await storage.setToken('a');
    await storage.setRefreshToken('r');
    await storage.setExpiresAt(1_700_000_000_000);

    expect(await storage.getToken(), 'a');
    expect(await storage.getRefreshToken(), 'r');
    expect(await storage.getExpiresAt(), 1_700_000_000_000);

    await storage.clearToken();
    expect(await storage.getToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
    expect(await storage.getExpiresAt(), isNull);
  });
}
```

- [ ] **Step 2: Run test — expect FAIL**

Run: `cd sebhua_notes_app && flutter test test/core/network/shared_preferences_token_storage_test.dart`

Expected: FAIL (missing type / methods).

- [ ] **Step 3: Extend interface + implement**

`token_storage.dart` add:

```dart
Future<int?> getExpiresAt();
Future<void> setExpiresAt(int epochMs);
```

`shared_preferences_token_storage.dart`:

```dart
class SharedPreferencesTokenStorage implements TokenStorage {
  SharedPreferencesTokenStorage(this._prefs);
  final SharedPreferences _prefs;

  // get/set using AppConstants.keyAccessToken / keyRefreshToken / keyTokenExpiresAt
  // clearToken removes all three keys
}
```

Helper for callers (can live on storage or a small util):

```dart
static int expiresAtFromExpiresIn(int expiresInSeconds) =>
    DateTime.now().millisecondsSinceEpoch + expiresInSeconds * 1000;
```

- [ ] **Step 4: Run test — expect PASS**

Run: `cd sebhua_notes_app && flutter test test/core/network/shared_preferences_token_storage_test.dart`

- [ ] **Step 5: Commit**

```bash
git add sebhua_notes_app/lib/core/network/token_storage.dart \
  sebhua_notes_app/lib/core/network/shared_preferences_token_storage.dart \
  sebhua_notes_app/test/core/network/shared_preferences_token_storage_test.dart
git commit -m "feat: implement TokenStorage with expiresAt persistence"
```

---

### Task 4: EmailLoginDto + AuthService.emailLogin

**Files:**
- Modify: `sebhua_notes_app/lib/data/models/auth_dtos.dart`
- Modify: `sebhua_notes_app/lib/data/services/auth_service.dart`
- Generated: `auth_dtos.freezed.dart`, `auth_dtos.g.dart`

- [ ] **Step 1: Add DTO**

```dart
@freezed
abstract class EmailLoginDto with _$EmailLoginDto {
  const factory EmailLoginDto({
    required String email,
    required String password,
  }) = _EmailLoginDto;

  factory EmailLoginDto.fromJson(Map<String, dynamic> json) =>
      _$EmailLoginDtoFromJson(json);
}
```

- [ ] **Step 2: Codegen**

Run: `cd sebhua_notes_app && dart run build_runner build --delete-conflicting-outputs`

Expected: success.

- [ ] **Step 3: Add service method**

```dart
Future<ApiResponse<TokenResponseDto>> emailLogin({
  required String email,
  required String password,
}) async {
  final response = await _dio.post<Map<String, dynamic>>(
    '/auth/email/login',
    data: EmailLoginDto(email: email, password: password).toJson(),
  );
  return ApiResponse.fromJson(
    response.data!,
    (json) => TokenResponseDto.fromJson(json as Map<String, dynamic>),
  );
}
```

Note: backend may return HTTP 2xx with business `code != 200` (e.g. `20011`). Do **not** throw solely on HTTP status; callers check `isSuccess` / `message`. Configure Dio `validateStatus` if needed so 4xx business bodies still parse when applicable — prefer parsing `response.data` when present.

- [ ] **Step 4: Analyze**

Run: `cd sebhua_notes_app && dart analyze lib/data/models/auth_dtos.dart lib/data/services/auth_service.dart`

- [ ] **Step 5: Commit**

```bash
git add sebhua_notes_app/lib/data/models/auth_dtos.dart \
  sebhua_notes_app/lib/data/models/auth_dtos.freezed.dart \
  sebhua_notes_app/lib/data/models/auth_dtos.g.dart \
  sebhua_notes_app/lib/data/services/auth_service.dart
git commit -m "feat: add email login DTO and AuthService.emailLogin"
```

---

### Task 5: Core providers + TokenRefresher (TDD)

**Files:**
- Create: `sebhua_notes_app/lib/core/network/token_refresher.dart`
- Create: `sebhua_notes_app/lib/core/providers/core_providers.dart`
- Create: `sebhua_notes_app/test/core/network/token_refresher_test.dart`
- Modify: `sebhua_notes_app/lib/core/network/dio_client.dart` (add `createRefreshDio()` without AuthInterceptor)

- [ ] **Step 1: Write failing refresher tests**

Cover:

1. Concurrent `refresh()` calls → only one HTTP refresh (mock Dio / fake).
2. Success writes new tokens + `expiresAt`.
3. Failure clears storage and invokes `onSessionExpired` callback once.
4. `scheduleProactiveRefresh`: with `expiresAt = now + skew + 2s`, verify refresh is **not** immediate; with `expiresAt` already within skew (or past), verify `refresh()` runs promptly.

Use a fake `TokenStorage` in-memory and a stub that records call counts.

- [ ] **Step 2: Run — expect FAIL**

- [ ] **Step 3: Implement TokenRefresher**

Responsibilities:

- `Future<bool> refresh()` — single-flight (`Future<bool>? _inFlight`)
- Uses refresh Dio → `POST /auth/refresh` with `{ refreshToken }`
- On success: `setToken` / `setRefreshToken` / `setExpiresAt(now + expiresIn*1000)`
- On failure: `clearToken()` + `onSessionExpired()`
- `void scheduleProactiveRefresh()` — cancel prior timer; if no `expiresAt`, no-op; if due within skew, call `refresh()` then reschedule; else `Timer(duration, ...)`
- `void cancel()` — cancel timer (dispose)
- `void Function()? onSessionExpired` — **mutable late-bound callback** (not a Riverpod dep). Construct `TokenRefresher` in a provider **without** reading `AuthNotifier`. In `AuthNotifier` constructor/`build`, assign:

```dart
ref.read(tokenRefresherProvider).onSessionExpired = () {
  // clear already done by refresher; flip state + bump routerRefresh
  state = const AuthState(status: AuthStatus.unauthenticated);
  routerRefresh.value++;
};
```

This avoids a Riverpod cycle (`AuthNotifier` → `TokenRefresher` → `AuthNotifier`).

Skew: `AppConstants.tokenRefreshSkewSeconds`.

- [ ] **Step 4: core_providers.dart**

```dart
final sharedPreferencesProvider = FutureProvider<SharedPreferences>(...);
final tokenStorageProvider = Provider<TokenStorage>(...); // override in tests
final dioProvider = Provider<Dio>((ref) => DioClient.create(...));
final refreshDioProvider = Provider<Dio>((ref) => DioClient.createRefreshDio());
final authServiceProvider = Provider<AuthService>(...);
final tokenRefresherProvider = Provider<TokenRefresher>(...);
```

Bootstrap note: `SharedPreferences.getInstance()` is async — either:

- make `main()` async and pass overrides into `ProviderScope`, **or**
- use a synchronous bootstrap in `main` before `runApp`.

**Preferred:** async `main`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      // or tokenStorageProvider.overrideWithValue(SharedPreferencesTokenStorage(prefs)),
    ],
    child: const SebhuaNotesApp(),
  ));
}
```

(Adjust provider types so overrides are clean — prefer `Provider<SharedPreferences>` with override rather than `FutureProvider` if using sync main bootstrap.)

- [ ] **Step 5: Tests PASS + commit**

```bash
git commit -m "feat: add TokenRefresher and core DI providers"
```

---

### Task 6: AuthInterceptor 401 → shared refresh → retry

**Files:**
- Modify: `sebhua_notes_app/lib/core/network/auth_interceptor.dart`
- Modify: `sebhua_notes_app/lib/core/network/error_interceptor.dart`
- Modify: `sebhua_notes_app/lib/core/network/dio_client.dart`

- [ ] **Step 1: Fix interceptor chain so refresh can run**

Today `DioClient` registers `AuthInterceptor` then `ErrorInterceptor`. Dio invokes `onError` in **reverse** order, so `ErrorInterceptor` currently converts 401 → `UnauthorizedException` and `reject`s **before** `AuthInterceptor` can refresh.

Pick **one** (prefer A):

- **A (preferred):** In `ErrorInterceptor.onError`, if `statusCode == 401`, call `handler.next(err)` and do **not** map/reject — let `AuthInterceptor` own 401 (refresh or clear + `UnauthorizedException`).
- **B:** Reorder so a dedicated refresh interceptor is outermost for errors, and `ErrorInterceptor` skips 401 entirely the same way.

Document the chosen rule in a short comment on both interceptors.

- [ ] **Step 2: Inject TokenRefresher into AuthInterceptor**

Constructor: `AuthInterceptor({required TokenStorage tokenStorage, required TokenRefresher tokenRefresher, required Dio dio})`.

`onError` when `statusCode == 401`:

1. If path is `/auth/refresh` or `/auth/email/login` (and other auth login paths) → clear + reject `UnauthorizedException` (no refresh loop).
2. Else `final ok = await tokenRefresher.refresh();`
3. If ok: update `err.requestOptions.headers['Authorization']`, `handler.resolve(await dio.fetch(err.requestOptions))`.
4. If not ok: refresher already cleared + fired `onSessionExpired`; reject `UnauthorizedException`.

Wire carefully to avoid circular DI: build `TokenRefresher` + main `Dio` in one place (provider/factory) so the interceptor and refresher share the same instance.

- [ ] **Step 3: Focused test or smoke**

Cover via TokenRefresher single-flight test + a short interceptor test that 401 triggers one refresh (or manual smoke if mock Dio is too heavy — but do not skip the ErrorInterceptor 401 passthrough change).

- [ ] **Step 4: Commit**

```bash
git commit -m "feat: refresh access token on 401 with single-flight retry"
```

---

### Task 7: AuthNotifier + session bootstrap

**Files:**
- Create: `sebhua_notes_app/lib/features/auth/auth_state.dart`
- Create: `sebhua_notes_app/lib/features/auth/auth_notifier.dart`

- [ ] **Step 1: Define state**

```dart
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.isSubmitting = false,
    this.errorMessage,
  });
  final AuthStatus status;
  final bool isSubmitting;
  final String? errorMessage;
}
```

Start as `unknown` until bootstrap completes.

- [ ] **Step 2: AuthNotifier**

Mirror `ThemeModeNotifier` / `NotifierProvider` style from `theme_provider.dart`.

- `build()` / constructor: load token from storage → set `authenticated` or `unauthenticated`; if authenticated, `tokenRefresher.scheduleProactiveRefresh()`.
- Assign `tokenRefresher.onSessionExpired` as in Task 5 (late-bound callback).
- Expose `ValueNotifier<int> routerRefresh` — bump on every status change for `GoRouter.refreshListenable`.
- `login(email, password)`: validate → submitting → `authService.emailLogin` → on success persist tokens + schedule refresh + `authenticated`; on `!isSuccess` set `errorMessage` from `response.message`; on Dio/network set `UiStrings.loginNetworkError`.
- `forceLogout()`: clear storage + `unauthenticated` + notify listenable.

- [ ] **Step 3: Commit**

```bash
git commit -m "feat: add AuthNotifier with bootstrap and login"
```

---

### Task 8: Router guard + login route

**Files:**
- Modify: `sebhua_notes_app/lib/core/router/app_router.dart`
- Create: `sebhua_notes_app/lib/features/auth/login_screen.dart` (stub first OK)

- [ ] **Step 1: Update GoRouter**

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authNotifierProvider.notifier);
  // Prefer listening to auth listenable without rebuilding GoRouter every frame:
  // use refreshListenable: auth.routerRefresh

  return GoRouter(
    initialLocation: AppConstants.routeHome,
    refreshListenable: auth.routerRefresh,
    redirect: (context, state) {
      final status = ref.read(authNotifierProvider).status;
      if (status == AuthStatus.unknown) return null; // or splash; avoid flicker
      final loggingIn = state.matchedLocation == AppConstants.routeLogin;
      if (status == AuthStatus.unauthenticated) {
        return loggingIn ? null : AppConstants.routeLogin;
      }
      if (loggingIn) return AppConstants.routeHome;
      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.routeLogin,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      // existing routes...
    ],
  );
});
```

While `unknown`, keep current location or show nothing flashy — bootstrap must finish before first meaningful redirect (await storage in notifier `build` using async Notifier if Riverpod 3 supports it, or complete hydrate in `main` before `runApp`).

**Preferred anti-flash:** hydrate tokens in `main` before `runApp`, pass initial `AuthState` into notifier so first frame is already authenticated/unauthenticated.

- [ ] **Step 2: Update widget_test**

Unauthenticated app should show login (花森 / 登录), not Notes AppBar.

**Required overrides** (same as production bootstrap):

```dart
SharedPreferences.setMockInitialValues({});
final prefs = await SharedPreferences.getInstance();
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      // and/or tokenStorageProvider if that is the override surface
    ],
    child: const SebhuaNotesApp(),
  ),
);
await tester.pumpAndSettle();
expect(find.text('花森'), findsOneWidget);
```

Do **not** pump a bare `ProviderScope` without prefs overrides once `main` requires them.

- [ ] **Step 3: Commit**

```bash
git commit -m "feat: guard routes and add /login"
```

---

### Task 9: LoginScreen UI (match mock)

**Files:**
- Modify: `sebhua_notes_app/lib/features/auth/login_screen.dart`
- Optionally reuse: `lib/ui/components/custom_button.dart`, `custom_input.dart` if they fit; otherwise local widgets matching mock.

- [ ] **Step 1: Implement layout**

- Scaffold background: theme surface / light paper
- Centered column, `ConstrainedBox(maxWidth: 400)`
- Brand row: `Container` circle `AppColors.coral` + title + slogan
- Email / password `TextFormField` with icons, obscure toggle
- Row: only「忘记密码?」aligned end (or spaceBetween with empty leading) — **no** remember-me
- Full-width login button using `ColorScheme.primary`; while `isSubmitting`, button **disabled** and show a progress indicator (e.g. `CircularProgressIndicator` on the button)
- Footer rich text for register
- Watch `authNotifierProvider` for `isSubmitting` / `errorMessage`
- On success, router redirect handles navigation (no manual `go` required if status flips)

Placeholder taps:

```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text(UiStrings.loginComingSoon)),
);
```

- [ ] **Step 2: Manual visual check**

Run: `flutter run -d windows` (or android) with backend up.

- [ ] **Step 3: Commit**

```bash
git commit -m "feat: implement 花森 login screen UI"
```

---

### Task 10: Wire main + analyze + acceptance

**Files:**
- Modify: `sebhua_notes_app/lib/main.dart`
- Modify: `sebhua_notes_app/test/widget_test.dart` (if not done)
- Optional: refresh `sebhua_notes_app/docs/api-docs.json` from `http://127.0.0.1:3000/api/docs-json`

- [ ] **Step 1: Async main bootstrap**

Ensure prefs + initial auth hydrate before first frame.

- [ ] **Step 2: Run analyzer and tests**

```bash
cd sebhua_notes_app
flutter analyze
flutter test
```

Expected: no errors; storage/refresher/widget tests pass.

- [ ] **Step 3: Manual acceptance checklist**

- [ ] Login UI matches mock (branding, coral, no remember-me)
- [ ] Login against `127.0.0.1:3000` → home
- [ ] Bad credentials show backend `message`
- [ ] Kill/relaunch stays logged in
- [ ] Failed refresh / cleared token → login without extra tap
- [ ] Forgot password / register →「即将开放」
- [ ] App primary color coral elsewhere (e.g. FAB if visible)

- [ ] **Step 4: Final commit**

```bash
git commit -m "feat: bootstrap auth session on app start"
```

---

## Execution handoff

After plan review approval, implement with:

1. **Subagent-Driven (recommended)** — `@superpowers:subagent-driven-development`
2. **Inline Execution** — `@superpowers:executing-plans`
