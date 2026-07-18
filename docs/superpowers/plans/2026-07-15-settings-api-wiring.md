# Settings API Wiring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire Settings / Account edit / WeChat bind to `UserService` + `StorageService` via a shared `userProfileProvider`, including cross-platform avatar upload on save.

**Architecture:** `AsyncNotifier` loads `GET /user/profile` once for all three screens. Account save optionally uploads image bytes then `POST /user/update`. WeChat confirm calls `POST /user/bind`. No Repository / Drift. Feedback via `tolyui_message` with backend `message`.

**Tech Stack:** Flutter, Riverpod (`AsyncNotifier`), Dio, freezed DTOs, `file_picker`, `tolyui_message`, existing `UserService` / `StorageService`

**Spec:** `docs/superpowers/specs/2026-07-15-settings-api-wiring-design.md`

**Working directory for all Flutter commands:** repo root (`d:\lbs\demo\sebhua-notes-app`)

## Global Constraints

- Implement on `master` only — no feature branches / worktrees unless the user explicitly asks.
- Do not add automated tests (manual QA only).
- No Repository / Drift / logout / email-change / unbind API.
- Sync toggles and threshold sliders stay local placeholders.
- User-visible API feedback: `$message.success` / `$message.error` with backend `message` (not hardcoded `UiStrings` for API failures). Client-only validation may use `UiStrings`.
- Accent via `ColorScheme.primary` / `AppColors`; no new brand colors required.
- Settings section order: account → sync → thresholds → binding → appearance (外观 last) — already matches current `settings_screen.dart`; do not reorder unless drifted.
- Skip `git commit` steps unless the user explicitly asks to commit in this session.
- After Freezed/DTO changes: `dart run build_runner build --delete-conflicting-outputs`
- Before claiming done: `flutter analyze` must be clean for touched files.

---

## 〇、进度里程碑

| 阶段 | 状态 | 完成度 |
|------|------|--------|
| 当前 | 全部任务已完成 | **7/7 ✅ 已完成** |
| Task 1 | DTO `wxBound` | ✅ |
| Task 2 | Storage bytes upload + provider | ✅ |
| Task 3 | `userProfileProvider` | ✅ |
| Task 4 | UiStrings | ✅ |
| Task 5 | SettingsScreen wire-up | ✅ |
| Task 6 | AccountEditScreen wire-up | ✅ |
| Task 7 | WechatBindScreen wire-up + analyze | ✅ |

---

## File structure

| File | Responsibility |
|------|----------------|
| `lib/data/models/user_dtos.dart` (+ generated) | Add `wxBound` to `UserProfileDto` |
| `lib/data/services/storage_service.dart` | Bytes-based `uploadFile` (no `dart:io`) |
| `lib/core/providers/core_providers.dart` | Add `storageServiceProvider` |
| `lib/features/settings/user_profile_provider.dart` | Shared `userProfileProvider` |
| `lib/core/constants/ui_strings.dart` | Bound/unbound, already-bound, load/retry, unset nickname |
| `lib/features/settings/settings_screen.dart` | Profile-driven account card + binding rows |
| `lib/features/settings/account_edit_screen.dart` | Prefill, pick preview, save upload+update |
| `lib/features/wechat/wechat_bind_screen.dart` | Bind API + already-bound UI |
| `lib/data/services/README.md` | Note bytes upload (optional one-line) |

---

### Task 1: `UserProfileDto.wxBound` + codegen

**Files:**
- Modify: `lib/data/models/user_dtos.dart`
- Modify: `lib/data/models/user_dtos.freezed.dart` (generated)
- Modify: `lib/data/models/user_dtos.g.dart` (generated)

**Interfaces:**
- Produces: `UserProfileDto({ String? id, String? email, String? nickname, String? avatar, bool? wxBound })`

- [x] **Step 1: Add `wxBound` to the freezed factory**

In `lib/data/models/user_dtos.dart`, update `UserProfileDto`:

```dart
@freezed
abstract class UserProfileDto with _$UserProfileDto {
  const factory UserProfileDto({
    String? id,
    String? email,
    String? nickname,
    String? avatar,
    bool? wxBound,
  }) = _UserProfileDto;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);
}
```

Leave `UpdateProfileDto` and `BindUserDto` unchanged.

- [x] **Step 2: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: exits 0; `user_dtos.freezed.dart` / `user_dtos.g.dart` include `wxBound`.

- [x] **Step 3: Verify analyze on model**

```bash
flutter analyze lib/data/models/user_dtos.dart
```

Expected: No issues.

---

### Task 2: Cross-platform `StorageService.uploadFile` + provider

**Files:**
- Modify: `lib/data/services/storage_service.dart`
- Modify: `lib/core/providers/core_providers.dart`
- Modify (optional): `lib/data/services/README.md` multipart bullet

**Interfaces:**
- Consumes: existing Dio via constructor
- Produces:
  - `Future<ApiResponse<UploadFileResponseDto>> uploadFile(List<int> bytes, { required String filename, String? type })`
  - `final storageServiceProvider = Provider<StorageService>(...)`

- [x] **Step 1: Rewrite `uploadFile` to use bytes (remove `dart:io`)**

Replace `lib/data/services/storage_service.dart` contents with:

```dart
import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../models/delete_file_response_dto.dart';
import '../models/upload_file_response_dto.dart';
import '../models/upload_token_response_dto.dart';

/// Service for storage-related API calls (file upload, tokens, deletion).
class StorageService {
  StorageService(this._dio);

  final Dio _dio;

  /// Get a pre-signed upload token.
  ///
  /// GET /storage/upload-token?key={key}
  Future<ApiResponse<UploadTokenResponseDto>> getUploadToken({String? key}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/storage/upload-token',
      queryParameters: <String, dynamic>{
        'key': key,
      }..removeWhere((_, v) => v == null),
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => UploadTokenResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Upload file bytes via multipart form (Web + IO platforms).
  ///
  /// POST /storage/upload
  Future<ApiResponse<UploadFileResponseDto>> uploadFile(
    List<int> bytes, {
    required String filename,
    String? type,
  }) async {
    final formData = FormData.fromMap(<String, dynamic>{
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      'type': type,
    }..removeWhere((_, v) => v == null));
    final response = await _dio.post<Map<String, dynamic>>(
      '/storage/upload',
      data: formData,
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => UploadFileResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Delete a file by key.
  ///
  /// POST /storage/delete
  Future<ApiResponse<DeleteFileResponseDto>> deleteFile(String key) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/storage/delete',
      data: <String, dynamic>{'key': key},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => DeleteFileResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
```

- [x] **Step 2: Add `storageServiceProvider`**

In `lib/core/providers/core_providers.dart`, add import:

```dart
import '../../data/services/storage_service.dart';
```

After `userServiceProvider`, add:

```dart
/// Object-storage upload / delete API service.
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(dioProvider));
});
```

- [x] **Step 3: Analyze**

```bash
flutter analyze lib/data/services/storage_service.dart lib/core/providers/core_providers.dart
```

Expected: No issues. Grep confirms no remaining `dart:io` import in `storage_service.dart`.

---

### Task 3: Shared `userProfileProvider`

**Files:**
- Create: `lib/features/settings/user_profile_provider.dart`

**Interfaces:**
- Consumes: `userServiceProvider`, `UserService.getProfile()` → `ApiResponse<UserProfileDto>`
- Produces:
  - `class UserProfileNotifier extends AsyncNotifier<UserProfileDto>`
  - `Future<UserProfileDto> build()`
  - `Future<void> refresh()`
  - `final userProfileProvider = AsyncNotifierProvider<UserProfileNotifier, UserProfileDto>(...)`

Pattern: mirror `lib/features/wechat/drafts_count_provider.dart`.

- [x] **Step 1: Create provider file**

Create `lib/features/settings/user_profile_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../data/models/user_dtos.dart';

class UserProfileNotifier extends AsyncNotifier<UserProfileDto> {
  @override
  Future<UserProfileDto> build() => _fetch();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }

  Future<UserProfileDto> _fetch() async {
    final response = await ref.read(userServiceProvider).getProfile();
    final data = response.data;
    if (response.isSuccess && data != null) {
      return data;
    }
    throw StateError(
      response.message.isNotEmpty ? response.message : 'profile load failed',
    );
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfileDto>(
  UserProfileNotifier.new,
);
```

- [x] **Step 2: Analyze**

```bash
flutter analyze lib/features/settings/user_profile_provider.dart
```

Expected: No issues.

---

### Task 4: UiStrings for profile / bind states

**Files:**
- Modify: `lib/core/constants/ui_strings.dart`

**Interfaces:**
- Produces string constants listed below (client-only copy; API toasts still use backend `message`)

- [x] **Step 1: Add / adjust strings**

In the settings / account / wechat sections of `ui_strings.dart`, ensure these exist (add if missing; keep existing keys that screens still use):

```dart
  static const String notBound = '未绑定';
  static const String nicknameUnset = '未设置';
  static const String profileLoadFailed = '加载失败，请重试';
  static const String profileRetry = '重试';
  static const String wechatAlreadyBound = '微信已绑定';
  static const String wechatAlreadyBoundHint = '当前账号已绑定微信，可将公众号消息同步到草稿箱';
```

Remove usage of `wechatExampleCode` from the bind screen in Task 7 (constant may remain unused — delete the constant if analyzer flags unused).

Do **not** use `savedToast` / `wechatBindSuccess` for successful API responses — use `response.message` instead. Keep those strings only if still needed as fallbacks when `message` is empty:

```dart
  // Prefer response.message; fallbacks when empty:
  // UiStrings.savedToast / UiStrings.wechatBindSuccess
```

- [x] **Step 2: Analyze**

```bash
flutter analyze lib/core/constants/ui_strings.dart
```

Expected: No issues (unused old keys OK until screens updated).

---

### Task 5: Wire `SettingsScreen`

**Files:**
- Modify: `lib/features/settings/settings_screen.dart`

**Interfaces:**
- Consumes: `userProfileProvider`, `UserProfileDto`, `UiStrings.*`, existing navigation routes

- [x] **Step 1: Import provider**

Add:

```dart
import '../../data/models/user_dtos.dart';
import 'user_profile_provider.dart';
```

- [x] **Step 2: Replace account card body to watch profile**

In `build`, watch:

```dart
final profileAsync = ref.watch(userProfileProvider);
```

Rewrite `_buildAccountCard` to accept `AsyncValue<UserProfileDto>` (or read inside). Behavior:

- `loading` / `AsyncLoading` with no prior value: card with centered `CircularProgressIndicator` (height ~72).
- `error`: show `error.toString()` stripped or `UiStrings.profileLoadFailed` + `TextButton`「重试」→ `ref.read(userProfileProvider.notifier).refresh()`. Prefer displaying `StateError.message` when present.
- `data`: show avatar (`NetworkImage` if `avatar` non-null/non-empty else initial letter), display name, email; tap still → `AppConstants.routeSettingsAccount`.

Display helpers (private methods on state class):

```dart
String _displayName(UserProfileDto p) {
  final n = p.nickname?.trim();
  if (n != null && n.isNotEmpty) return n;
  final email = p.email?.trim();
  if (email != null && email.contains('@')) {
    return email.split('@').first;
  }
  return UiStrings.nicknameUnset;
}

String _initial(UserProfileDto p) {
  final name = _displayName(p);
  if (name.isEmpty || name == UiStrings.nicknameUnset) return '?';
  return String.fromCharCodes(name.runes.take(1));
}

String _emailLabel(UserProfileDto p) {
  final e = p.email?.trim();
  if (e != null && e.isNotEmpty) return e;
  return UiStrings.notBound;
}
```

Avatar widget:

```dart
Widget _avatar(UserProfileDto p, ColorScheme scheme, TextTheme theme) {
  final url = p.avatar?.trim();
  if (url != null && url.isNotEmpty) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: scheme.primary.withValues(alpha: 0.15),
      backgroundImage: NetworkImage(url),
    );
  }
  return CircleAvatar(
    radius: 28,
    backgroundColor: scheme.primary.withValues(alpha: 0.15),
    child: Text(
      _initial(p),
      style: theme.textTheme.titleLarge?.copyWith(
        color: scheme.primary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
```

- [x] **Step 3: Wire email + WeChat binding rows**

Pass profile (or `AsyncValue`) into `_bindingEmailRow` / `_bindingWechatRow`:

- Email: if `email` non-empty → subtitle = email, trailing `UiStrings.bound`; else subtitle/trailing `UiStrings.notBound`.
- WeChat: if `wxBound == true` → subtitle `UiStrings.bound`, show unbind control (toast `UiStrings.unbindComingSoon`); else subtitle `UiStrings.notBound`, hide unbind (or show nothing coral). Row `InkWell` always pushes `routeSettingsWechatBind` except unbind `GestureDetector` stops propagation (keep current hit-target pattern).
- While profile loading/error: binding rows may show placeholders (`—` / `UiStrings.notBound`) or hide until data — prefer show rows with `UiStrings.notBound` during loading to avoid layout jump.

- [x] **Step 4: Keep section order**

Confirm `Column` children order remains: account → sync → thresholds → binding → appearance. Do not move appearance above binding.

- [x] **Step 5: Analyze**

```bash
flutter analyze lib/features/settings/settings_screen.dart
```

Expected: No issues.

**Manual check:** Open Settings tab logged-in — card shows real profile or error+retry; WeChat status matches `wxBound`.

---

### Task 6: Wire `AccountEditScreen`

**Files:**
- Modify: `lib/features/settings/account_edit_screen.dart`

**Interfaces:**
- Consumes: `userProfileProvider`, `userServiceProvider`, `storageServiceProvider`, `UpdateProfileDto`, `file_picker`
- Produces: save flow that refreshes profile then pops

- [x] **Step 1: Convert to `ConsumerStatefulWidget`**

Replace `StatefulWidget` with `ConsumerStatefulWidget` / `ConsumerState`. Imports:

```dart
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/network/api_exception.dart';
import '../../core/providers/core_providers.dart';
import '../../data/models/user_dtos.dart';
import 'user_profile_provider.dart';
```

- [x] **Step 2: Local state fields**

```dart
  late final TextEditingController _nameController;
  Uint8List? _pickedBytes;
  String? _pickedFilename;
  bool _saving = false;
  bool _prefilled = false;
```

Need `import 'dart:typed_data';`.

- [x] **Step 3: Prefill from profile once**

In `build`, `ref.watch(userProfileProvider)`. When `AsyncData` and `!_prefilled`, set controller text from `nickname` and `_prefilled = true` (use `WidgetsBinding.instance.addPostFrameCallback` or set in build carefully once).

Show loading scaffold if profile still loading and not prefilled; error + retry if profile failed.

Email row: show `profile.email` or `UiStrings.notBound` (read-only).

Avatar display priority: `_pickedBytes` → `MemoryImage` → else network `avatar` → else initial.

- [x] **Step 4: Pick image (preview only)**

```dart
  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      $message.error(message: UiStrings.profileLoadFailed);
      return;
    }
    setState(() {
      _pickedBytes = bytes;
      _pickedFilename = file.name;
    });
  }
```

Wire avatar `GestureDetector.onTap` to `_pickAvatar` (remove coming-soon toast).

- [x] **Step 5: Save — upload then update**

```dart
  Future<void> _save() async {
    if (_saving) return;
    final nickname = _nameController.text.trim();
    setState(() => _saving = true);
    try {
      String? avatarUrl;
      final bytes = _pickedBytes;
      if (bytes != null) {
        final upload = await ref.read(storageServiceProvider).uploadFile(
              bytes,
              filename: _pickedFilename ?? 'avatar.jpg',
              type: 'IMAGE',
            );
        if (!upload.isSuccess || upload.data == null) {
          $message.error(
            message: upload.message.isNotEmpty
                ? upload.message
                : UiStrings.profileLoadFailed,
          );
          return;
        }
        avatarUrl = upload.data!.url;
      }

      final response = await ref.read(userServiceProvider).updateProfile(
            UpdateProfileDto(
              nickname: nickname.isEmpty ? null : nickname,
              avatar: avatarUrl,
            ),
          );
      if (!response.isSuccess) {
        $message.error(
          message: response.message.isNotEmpty
              ? response.message
              : UiStrings.profileLoadFailed,
        );
        return;
      }
      $message.success(
        message: response.message.isNotEmpty
            ? response.message
            : UiStrings.savedToast,
      );
      await ref.read(userProfileProvider.notifier).refresh();
      if (!mounted) return;
      context.pop();
    } on DioException catch (e) {
      final err = e.error;
      final msg = err is ApiException && err.message.isNotEmpty
          ? err.message
          : UiStrings.profileLoadFailed;
      $message.error(message: msg);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
```

Disable AppBar save + bottom button while `_saving`; show small progress on button when saving.

- [x] **Step 6: Analyze**

```bash
flutter analyze lib/features/settings/account_edit_screen.dart
```

Expected: No issues.

**Manual check:** Edit nickname → save → settings card updates; pick image → preview before save → after save network avatar shows.

---

### Task 7: Wire `WechatBindScreen` + final verify

**Files:**
- Modify: `lib/features/wechat/wechat_bind_screen.dart`

**Interfaces:**
- Consumes: `userProfileProvider`, `userServiceProvider`, `BindUserDto`

- [x] **Step 1: Convert to `ConsumerStatefulWidget`**

Imports as in Task 6 (dio, riverpod, api_exception, core_providers, user_dtos, user_profile_provider). Remove default text `UiStrings.wechatExampleCode` — init controller empty:

```dart
_codeController = TextEditingController();
```

- [x] **Step 2: Already-bound UI**

Watch `userProfileProvider`. When `value?.wxBound == true`:

- Show banner/text: `UiStrings.wechatAlreadyBound` + `UiStrings.wechatAlreadyBoundHint`
- Disable confirm button (and optionally disable paste)
- Do not call bind API

- [x] **Step 3: Confirm bind**

```dart
  bool _binding = false;

  Future<void> _confirm() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      $message.error(message: UiStrings.wechatBindCodeRequired);
      return;
    }
    if (_binding) return;
    setState(() => _binding = true);
    try {
      final response = await ref.read(userServiceProvider).bindWechat(
            BindUserDto(bindingCode: code),
          );
      if (!response.isSuccess) {
        $message.error(
          message: response.message.isNotEmpty
              ? response.message
              : UiStrings.profileLoadFailed,
        );
        return;
      }
      $message.success(
        message: response.message.isNotEmpty
            ? response.message
            : UiStrings.wechatBindSuccess,
      );
      await ref.read(userProfileProvider.notifier).refresh();
      if (!mounted) return;
      context.pop();
    } on DioException catch (e) {
      final err = e.error;
      final msg = err is ApiException && err.message.isNotEmpty
          ? err.message
          : UiStrings.profileLoadFailed;
      $message.error(message: msg);
    } finally {
      if (mounted) setState(() => _binding = false);
    }
  }
```

Keep paste / clear / steps UI. Confirm button disabled when `_binding` or already bound.

- [x] **Step 4: Remove unused `wechatExampleCode` if unused**

If nothing references it, delete from `ui_strings.dart`.

- [x] **Step 5: Full analyze**

```bash
flutter analyze lib/features/settings lib/features/wechat/wechat_bind_screen.dart lib/data/services/storage_service.dart lib/data/models/user_dtos.dart lib/core/providers/core_providers.dart lib/core/constants/ui_strings.dart
```

Expected: No issues.

- [x] **Step 6: Update plan milestone**

In this plan file and `.cursor/plan/settings-api-wiring.md`, mark tasks 1–7 `[x]` and milestone **7/7 ✅ 已完成**.

**Manual QA checklist (from spec):**

- [ ] Settings shows real nickname / email / avatar; loading and retry work
- [ ] `wxBound` false →「未绑定」→ bind page; true →「已绑定」+ unbind toast
- [ ] Account: change nickname → save → settings reflects change
- [ ] Account: pick image → local preview → save → avatar updates (Chrome)
- [ ] Bind success → settings WeChat row shows bound
- [ ] API errors surface backend `message` via `toly_ui`
- [ ] Appearance section is last; wide layout ≤600px OK

---

## 实现调整

（实施中如有偏离，记在此处）

-

---

## Spec coverage self-check

| Spec requirement | Task |
|------------------|------|
| `wxBound` on DTO | 1 |
| Bytes upload / no dart:io | 2 |
| `userProfileProvider` | 3 |
| Settings card + binding rows | 5 |
| Account preview-then-upload save | 6 |
| WeChat bind + already-bound | 7 |
| Unbind toast only | 5 (unchanged) |
| Sync/thresholds local | 5 (unchanged) |
| Manual QA / no auto tests | Global + Task 7 |
| Section order appearance last | 5 |
| toly_ui + backend message | 6, 7 |
