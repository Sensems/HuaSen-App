# Reset Password Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the reset-password page (mock UI), wire `send-code` with `purpose: reset_password` + `reset-password`, 60s countdown, login「忘记密码?」with email prefill, and return to login with a success prompt (no auto-login / no tokens).

**Architecture:** Mirror register (approach A). Extend `AuthNotifier.sendCode` with required `EmailCodePurpose`; add `resetPassword → bool`. UI owns the 60s `Timer`. Reuse existing `AuthService` / DTOs (already implemented).

**Tech Stack:** Flutter, Riverpod 3, go_router, Dio, toly_ui message, freezed DTOs (already generated).

**Spec:** `docs/superpowers/specs/2026-07-13-reset-password-design.md`

**Working directory for all Flutter commands:** repository root (contains `pubspec.yaml`).

**Testing:** Manual only (per spec). Each task ends with `dart analyze` / `flutter analyze` on touched paths — no new automated tests.

**Already done (do not redo):**
- `lib/data/models/auth_dtos.dart` — `EmailSendCodeDto`, `EmailCodePurpose.resetPassword`, `EmailResetPasswordDto` + codegen
- `lib/data/services/auth_service.dart` — `sendEmailCode(..., purpose:)`, `emailResetPassword`

---

## File structure

| File | Responsibility |
|------|----------------|
| `lib/core/constants/app_constants.dart` | `routeResetPassword` |
| `lib/core/constants/ui_strings.dart` | Reset-password copy |
| `lib/features/auth/auth_notifier.dart` | `sendCode` + `purpose`; `resetPassword` |
| `lib/features/auth/register_screen.dart` | Pass `EmailCodePurpose.register` |
| `lib/features/auth/reset_password_screen.dart` | Reset UI + 60s countdown |
| `lib/features/auth/login_screen.dart` |「忘记密码?」→ push with email `extra` |
| `lib/core/router/app_router.dart` | Public allow-list + `/reset-password` route |
| `AGENTS.md` | Public routes / auth scope note |

---

### Task 1: Route constant + UI strings

**Files:**
- Modify: `lib/core/constants/app_constants.dart`
- Modify: `lib/core/constants/ui_strings.dart`

- [ ] **Step 1: Add route constant**

In `AppConstants`, after `routeRegister`, add:

```dart
  /// Email reset-password screen.
  static const String routeResetPassword = '/reset-password';
```

- [ ] **Step 2: Add reset-password strings**

In `UiStrings`, after the register section (before legal placeholders), add:

```dart
  // --- Reset password ---
  static const String resetPasswordTitle = '重置密码';
  static const String resetPasswordSubtitle = '输入注册邮箱，我们将发送验证码';
  static const String resetPasswordHint = '新密码';
  static const String resetPasswordConfirmHint = '确认新密码';
  static const String resetPasswordButton = '确认重置';
  static const String resetPasswordBackToLogin = '← 返回登录';
  static const String resetPasswordSuccess = '密码重置成功，请登录';
  static const String resetPasswordResendPrefix = '重新发送';
  static const String resetPasswordNetworkError = '网络异常，请重试';
```

Reuse on the reset screen (do not duplicate): `loginEmailHint`, `registerCodeHint`, `registerGetCode`, `registerCodeSent`, `registerCodeRequired`, `registerCodeInvalid`, `registerPasswordWeak`, `registerPasswordMismatch`, `loginEmailRequired`, `loginEmailInvalid`, `loginShowPassword`, `loginHidePassword`.

- [ ] **Step 3: Analyze**

Run: `dart analyze lib/core/constants/`

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add lib/core/constants/app_constants.dart lib/core/constants/ui_strings.dart
git commit -m "chore: add reset-password route and UI strings"
```

---

### Task 2: AuthNotifier — purpose on sendCode + resetPassword

**Files:**
- Modify: `lib/features/auth/auth_notifier.dart`
- Modify: `lib/features/auth/register_screen.dart` (call site only)

- [ ] **Step 1: Update `sendCode` signature and purpose**

Replace the current `sendCode` method with:

```dart
  /// Returns `true` only when the API accepts the send-code request.
  Future<bool> sendCode(
    String email, {
    required EmailCodePurpose purpose,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      state = AuthState(
        status: state.status,
        errorMessage: UiStrings.loginEmailRequired,
      );
      return false;
    }
    if (!_emailPattern.hasMatch(trimmedEmail)) {
      state = AuthState(
        status: state.status,
        errorMessage: UiStrings.loginEmailInvalid,
      );
      return false;
    }

    state = AuthState(status: state.status, isSendingCode: true);

    try {
      final response = await ref.read(authServiceProvider).sendEmailCode(
            email: trimmedEmail,
            purpose: purpose,
          );
      if (response.isSuccess) {
        state = AuthState(status: state.status);
        return true;
      }
      state = AuthState(
        status: state.status,
        isSendingCode: true,
        errorMessage: response.message,
      );
      return false;
    } on DioException {
      state = AuthState(
        status: state.status,
        isSendingCode: true,
        errorMessage: UiStrings.registerNetworkError,
      );
      return false;
    } finally {
      if (state.isSendingCode) {
        state = AuthState(
          status: state.status,
          errorMessage: state.errorMessage,
        );
      }
    }
  }
```

Ensure `import '../../data/models/auth_dtos.dart';` remains (already present for `EmailCodePurpose`).

- [ ] **Step 2: Add `resetPassword`**

Place after `register` (before `clearError`):

```dart
  /// Returns `true` on successful password reset. Does **not** persist
  /// tokens or set [AuthStatus.authenticated].
  Future<bool> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
    required String code,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedCode = code.trim();
    final validationMessage = _validateResetPassword(
      email: trimmedEmail,
      password: password,
      confirmPassword: confirmPassword,
      code: trimmedCode,
    );
    if (validationMessage != null) {
      state = AuthState(status: state.status, errorMessage: validationMessage);
      return false;
    }

    state = AuthState(status: state.status, isSubmitting: true);

    try {
      final response = await ref.read(authServiceProvider).emailResetPassword(
            email: trimmedEmail,
            password: password,
            code: trimmedCode,
          );
      if (response.isSuccess) {
        state = AuthState(status: state.status);
        return true;
      }
      state = AuthState(
        status: state.status,
        isSubmitting: true,
        errorMessage: response.message,
      );
      return false;
    } on DioException {
      state = AuthState(
        status: state.status,
        isSubmitting: true,
        errorMessage: UiStrings.resetPasswordNetworkError,
      );
      return false;
    } finally {
      if (state.isSubmitting) {
        state = AuthState(
          status: state.status,
          errorMessage: state.errorMessage,
        );
      }
    }
  }
```

Add helper next to `_validateRegister`:

```dart
  String? _validateResetPassword({
    required String email,
    required String password,
    required String confirmPassword,
    required String code,
  }) {
    if (email.isEmpty) {
      return UiStrings.loginEmailRequired;
    }
    if (!_emailPattern.hasMatch(email)) {
      return UiStrings.loginEmailInvalid;
    }
    if (code.isEmpty) {
      return UiStrings.registerCodeRequired;
    }
    if (!_codePattern.hasMatch(code)) {
      return UiStrings.registerCodeInvalid;
    }
    if (!_passwordPattern.hasMatch(password)) {
      return UiStrings.registerPasswordWeak;
    }
    if (password != confirmPassword) {
      return UiStrings.registerPasswordMismatch;
    }
    return null;
  }
```

- [ ] **Step 3: Update register screen call site**

In `register_screen.dart` `_onGetCode`, change:

```dart
    final ok = await ref
        .read(authNotifierProvider.notifier)
        .sendCode(_emailController.text);
```

to:

```dart
    final ok = await ref.read(authNotifierProvider.notifier).sendCode(
          _emailController.text,
          purpose: EmailCodePurpose.register,
        );
```

Add import if missing:

```dart
import '../../data/models/auth_dtos.dart';
```

- [ ] **Step 4: Analyze**

Run: `dart analyze lib/features/auth/auth_notifier.dart lib/features/auth/register_screen.dart`

Expected: no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/auth_notifier.dart lib/features/auth/register_screen.dart
git commit -m "feat: add resetPassword and purpose to sendCode"
```

---

### Task 3: ResetPasswordScreen

**Files:**
- Create: `lib/features/auth/reset_password_screen.dart`

- [ ] **Step 1: Create the screen**

Create `lib/features/auth/reset_password_screen.dart` with the full contents below (mirrors register layout; no terms checkbox; countdown label「重新发送 Ns」):

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../data/models/auth_dtos.dart';
import 'auth_notifier.dart';

/// Email reset-password screen for `/reset-password`.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail = ''});

  /// Prefill from login via GoRouter `extra` (empty when deep-linked).
  final String initialEmail;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _countdownSeconds = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdownSeconds = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds <= 1) {
        timer.cancel();
        setState(() => _countdownSeconds = 0);
        return;
      }
      setState(() => _countdownSeconds -= 1);
    });
  }

  Future<void> _onGetCode() async {
    final auth = ref.read(authNotifierProvider);
    if (auth.isSendingCode || _countdownSeconds > 0) {
      return;
    }
    final ok = await ref.read(authNotifierProvider.notifier).sendCode(
          _emailController.text,
          purpose: EmailCodePurpose.resetPassword,
        );
    if (!mounted) {
      return;
    }
    if (ok) {
      $message.success(message: UiStrings.registerCodeSent);
      _startCountdown();
    }
  }

  Future<void> _onReset() async {
    final auth = ref.read(authNotifierProvider);
    if (auth.isSubmitting) {
      return;
    }
    final ok = await ref.read(authNotifierProvider.notifier).resetPassword(
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          code: _codeController.text,
        );
    if (!mounted) {
      return;
    }
    if (ok) {
      $message.success(message: UiStrings.resetPasswordSuccess);
      context.go(AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authNotifierProvider);
    final isSubmitting = authState.isSubmitting;
    final isSendingCode = authState.isSendingCode;
    final codeButtonEnabled =
        !isSendingCode && !isSubmitting && _countdownSeconds == 0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    UiStrings.resetPasswordTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    UiStrings.resetPasswordSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    enabled: !isSubmitting,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      hintText: UiStrings.loginEmailHint,
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _codeController,
                          enabled: !isSubmitting,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 6,
                          decoration: const InputDecoration(
                            hintText: UiStrings.registerCodeHint,
                            prefixIcon: Icon(Icons.lock_outline),
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: codeButtonEnabled ? _onGetCode : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.primary),
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isSendingCode
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.primary,
                                  ),
                                )
                              : Text(
                                  _countdownSeconds > 0
                                      ? '${UiStrings.resetPasswordResendPrefix} ${_countdownSeconds}s'
                                      : UiStrings.registerGetCode,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !isSubmitting,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      hintText: UiStrings.resetPasswordHint,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? UiStrings.loginShowPassword
                            : UiStrings.loginHidePassword,
                        onPressed: isSubmitting
                            ? null
                            : () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    enabled: !isSubmitting,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onReset(),
                    decoration: InputDecoration(
                      hintText: UiStrings.resetPasswordConfirmHint,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _obscureConfirm
                            ? UiStrings.loginShowPassword
                            : UiStrings.loginHidePassword,
                        onPressed: isSubmitting
                            ? null
                            : () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  if (authState.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      authState.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isSubmitting ? null : _onReset,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isSubmitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Text(UiStrings.resetPasswordButton),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () {
                              ref
                                  .read(authNotifierProvider.notifier)
                                  .clearError();
                              context.go(AppConstants.routeLogin);
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                      child: const Text(UiStrings.resetPasswordBackToLogin),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

Run: `dart analyze lib/features/auth/reset_password_screen.dart`

Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/reset_password_screen.dart
git commit -m "feat: add reset password screen UI"
```

---

### Task 4: Router — public `/reset-password`

**Files:**
- Modify: `lib/core/router/app_router.dart`

- [ ] **Step 1: Import + public allow-list + route**

Add import:

```dart
import '../../features/auth/reset_password_screen.dart';
```

Extend `isPublicRoute`:

```dart
      final isPublicRoute = location == AppConstants.routeLogin ||
          location == AppConstants.routeRegister ||
          location == AppConstants.routeResetPassword ||
          location == AppConstants.routeLegalTerms ||
          location == AppConstants.routeLegalPrivacy;
```

Add route after the register `GoRoute`:

```dart
      GoRoute(
        path: AppConstants.routeResetPassword,
        name: 'reset-password',
        builder: (context, state) {
          final email = state.extra is String ? state.extra as String : '';
          return ResetPasswordScreen(initialEmail: email);
        },
      ),
```

- [ ] **Step 2: Analyze**

Run: `dart analyze lib/core/router/app_router.dart`

Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/core/router/app_router.dart
git commit -m "feat: add public reset-password route"
```

---

### Task 5: Login — wire「忘记密码?」

**Files:**
- Modify: `lib/features/auth/login_screen.dart`

- [ ] **Step 1: Replace coming-soon with navigation**

Remove `_showComingSoon` usage from the forgot-password button only (keep the method if still unused elsewhere — if unused, delete the method).

Replace the forgot-password `TextButton` `onPressed` with:

```dart
                    child: TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () {
                              ref
                                  .read(authNotifierProvider.notifier)
                                  .clearError();
                              context.push(
                                AppConstants.routeResetPassword,
                                extra: _emailController.text.trim(),
                              );
                            },
                      child: const Text(UiStrings.loginForgotPassword),
                    ),
```

If `_showComingSoon` becomes unused, delete it.

- [ ] **Step 2: Analyze**

Run: `dart analyze lib/features/auth/login_screen.dart`

Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/login_screen.dart
git commit -m "feat: link login forgot-password to reset screen"
```

---

### Task 6: AGENTS.md + final analyze

**Files:**
- Modify: `AGENTS.md` (learned / public-routes bullets only if stale)

- [ ] **Step 1: Sync AGENTS.md facts**

Confirm these are accurate (update in place if missing):

- Public unauthenticated routes include `/reset-password`
- Auth delivery: reset-password UI shipped (mirror register); send-code uses `purpose: reset_password`
- Success: toly_ui + return to login; no tokens / no auto-login

- [ ] **Step 2: Full analyze**

Run: `flutter analyze`

Expected: no issues in auth / router / constants paths.

- [ ] **Step 3: Commit**

```bash
git add AGENTS.md
git commit -m "docs: note reset-password in AGENTS auth scope"
```

(Skip this commit if `AGENTS.md` needed no edits.)

---

## Manual QA (after Task 5–6)

Run app:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

Checklist (from spec):

1. Login「忘记密码?」→ reset page; email prefilled when login field had a value.
2. Get-code disabled during countdown / `isSendingCode`; success shows 60s「重新发送 Ns」+「验证码已发送」.
3. Network inspector: send-code body has `purpose: "reset_password"`; reset-password body is `{ email, password, code }` only.
4. Weak password / mismatch / invalid code show form errors.
5. Success:「密码重置成功，请登录」→ login; no tokens written; not authenticated.
6.「← 返回登录」works; unauthenticated `/reset-password` deep link allowed.

---

## Spec coverage (self-review)

| Spec requirement | Task |
|------------------|------|
| Mock UI + global theme primary | Task 3 |
| `purpose: reset_password` | Task 2 + Task 3 |
| `POST /auth/email/reset-password` | Task 2 |
| 60s countdown「重新发送 Ns」 | Task 3 |
| Login prefill via `extra` | Task 4 + Task 5 |
| Success toly_ui → login, no tokens | Task 2 + Task 3 |
| Public `/reset-password` | Task 4 |
| Register still sends `purpose: register` | Task 2 |
| Manual QA only | Explicit; no new tests |
| DTOs/Service already done | Listed under Already done |
