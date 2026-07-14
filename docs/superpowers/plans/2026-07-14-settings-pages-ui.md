# Settings + Account Edit + WeChat Bind UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship UI-only settings, account-edit, and WeChat-bind screens matching the approved mock/spec (no API).

**Architecture:** Flat feature screens with local `StatefulWidget` / `ConsumerStatefulWidget` state. Dark mode alone uses `themeModeProvider`. Sub-pages live outside `ShellRoute` so the bottom tab bar is hidden. Toasts via `tolyui_message` (`$message`).

**Tech Stack:** Flutter, Riverpod, go_router, Material, `tolyui_message`, existing `AppColors` / `CustomAppBar` / `CustomButton`

**Spec:** `docs/superpowers/specs/2026-07-14-settings-pages-design.md`

**Working directory for all Flutter commands:** repo root (`d:\lbs\demo\sebhua-notes-app`)

## Global Constraints

- Implement on `master` only — no feature branches / worktrees unless the user explicitly asks.
- Do not add automated tests (manual QA only).
- No REST / Repository / Drift / profile providers.
- No hardcoded hex in widgets — use `AppColors` (add `wechat` green there).
- Accent via `ColorScheme.primary` / `AppColors.coral`; canvas `#f8f7f4` via theme / `AppColors.lightBackground`.
- User-visible feedback: `$message.success` / `$message.error` from `tolyui_message` with `UiStrings` (not SnackBar).
- Theme toggle is **session-only** (do not wire `keyThemeMode` / SharedPreferences).
- Keep bottom nav as 笔记 / 草稿 / 设置 (do not add clipboard tab).
- Chinese UI copy in `UiStrings`.

---

## File structure

| File | Responsibility |
|------|----------------|
| `lib/core/constants/app_constants.dart` | `routeSettingsAccount`, `routeSettingsWechatBind` |
| `lib/core/constants/ui_strings.dart` | All Chinese strings for the three screens |
| `lib/ui/theme/app_colors.dart` | Add `wechat` brand green |
| `lib/core/router/app_router.dart` | Register two shell-external routes |
| `lib/features/settings/settings_screen.dart` | Rebuild settings tab UI |
| `lib/features/settings/account_edit_screen.dart` | Account edit page |
| `lib/features/wechat/wechat_bind_screen.dart` | WeChat bind page |

---

### Task 1: Constants, strings, WeChat color

**Files:**
- Modify: `lib/core/constants/app_constants.dart`
- Modify: `lib/core/constants/ui_strings.dart`
- Modify: `lib/ui/theme/app_colors.dart`

**Interfaces:**
- Produces: `AppConstants.routeSettingsAccount` (`'/settings/account'`), `AppConstants.routeSettingsWechatBind` (`'/settings/wechat-bind'`), `AppColors.wechat`, settings-related `UiStrings.*` listed below

- [ ] **Step 1: Add route constants**

In `app_constants.dart`, after `routeSettings`, add:

```dart
  /// Account profile edit (outside shell).
  static const String routeSettingsAccount = '/settings/account';

  /// WeChat bind flow (outside shell).
  static const String routeSettingsWechatBind = '/settings/wechat-bind';
```

- [ ] **Step 2: Add WeChat green to AppColors**

In `app_colors.dart`, after `teal`:

```dart
  /// WeChat brand green (bind screen / WeChat row accents).
  static const Color wechat = Color(0xFF07C160);
```

- [ ] **Step 3: Replace / extend settings `UiStrings` with Chinese copy**

Replace the existing `// --- Settings screen ---` block and add account / WeChat / shared strings. Keep unused old English keys out of the way by overwriting the settings section:

```dart
  // --- Settings screen ---
  static const String settings = '设置';
  static const String appearance = '外观';
  static const String darkMode = '深色模式';
  static const String darkModeHint = '切换深色配色';
  static const String syncSection = '同步设置';
  static const String draftsSync = '草稿箱同步';
  static const String draftsSyncHint = '自动同步微信草稿到本地';
  static const String clipboardSync = '剪贴板同步';
  static const String clipboardSyncHint = '跨设备同步剪贴板内容';
  static const String sizeThresholds = '同步阈值';
  static const String maxImageSize = '图片同步阈值';
  static const String maxImageSizeHint = '超过此大小的图片不同步';
  static const String maxFileSize = '文件同步阈值';
  static const String maxFileSizeHint = '超过此大小的文件不同步';
  static const String accountBinding = '账号绑定';
  static const String edit = '编辑';
  static const String bound = '已绑定';
  static const String unbind = '解绑';
  static const String emailLabel = '邮箱';
  static const String wechatLabel = '微信';
  static const String unbindComingSoon = '解绑功能即将开放';
  static const String placeholderDisplayName = '张明';
  static const String placeholderAvatarInitial = '张';
  static const String placeholderEmail = 'zhangming@example.com';

  // --- Account edit ---
  static const String accountEditTitle = '账号信息';
  static const String save = '保存';
  static const String saveChanges = '保存修改';
  static const String savedToast = '已保存';
  static const String avatarEditComingSoon = '头像编辑即将开放';
  static const String usernameLabel = '用户名';
  static const String boundEmailLabel = '绑定邮箱';
  static const String boundEmailHint = '修改邮箱请在设置页的账号绑定中操作';
  static const String tapToEditAvatar = '点击编辑头像';

  // --- WeChat bind ---
  static const String wechatBindTitle = '绑定微信';
  static const String wechatBindSubtitle = '绑定后可将公众号消息同步到草稿箱';
  static const String wechatBindCodeHint = '请输入绑定码';
  static const String wechatPaste = '粘贴';
  static const String wechatConfirmBind = '确认绑定';
  static const String wechatBindSuccess = '绑定成功，消息将同步至草稿箱';
  static const String wechatBindCodeRequired = '请输入绑定码';
  static const String wechatClipboardEmpty = '剪贴板为空';
  static const String wechatExampleCode = 'HS-8K2M-N4X';
  static const String wechatStepsTitle = '绑定步骤';
  static const String wechatStep1 = '关注花森公众号';
  static const String wechatStep2 = '发送关键词「绑定」';
  static const String wechatStep3 = '复制收到的绑定码';
  static const String wechatStep4 = '回到 App 粘贴并确认';
```

Also set common back if still English (optional for this task — sub-pages may use `CustomAppBar(showBack: true)` without relying on `UiStrings.back`):

```dart
  static const String back = '返回';
```

- [ ] **Step 4: Commit**

```bash
git add lib/core/constants/app_constants.dart lib/core/constants/ui_strings.dart lib/ui/theme/app_colors.dart
git commit -m "chore: add settings pages routes, strings, and WeChat color"
```

---

### Task 2: Account edit screen + route

**Files:**
- Create: `lib/features/settings/account_edit_screen.dart`
- Modify: `lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: `AppConstants.routeSettingsAccount`, `UiStrings.*` account strings, `$message.success`
- Produces: `AccountEditScreen` widget; named route `settings-account`

- [ ] **Step 1: Create `account_edit_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/ui_strings.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_button.dart';
import '../../ui/theme/app_colors.dart';

/// UI-only account profile editor (no API).
class AccountEditScreen extends StatefulWidget {
  const AccountEditScreen({super.key});

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: UiStrings.placeholderDisplayName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    $message.success(message: UiStrings.savedToast);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CustomAppBar(
        title: UiStrings.accountEditTitle,
        showBack: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              UiStrings.save,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => $message.success(
                  message: UiStrings.avatarEditComingSoon,
                ),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: scheme.primary.withValues(alpha: 0.15),
                          child: Text(
                            UiStrings.placeholderAvatarInitial,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.lightSurface,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      UiStrings.tapToEditAvatar,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  UiStrings.usernameLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.lightSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  UiStrings.boundEmailLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        UiStrings.placeholderEmail,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  UiStrings.boundEmailHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              CustomButton(
                label: UiStrings.saveChanges,
                expanded: true,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Notes for implementer:
- Prefer `Theme.of(context).brightness` / `colorScheme.surface` for dark-mode avatar border instead of hardcoding only `AppColors.lightSurface` if analyze/dark looks wrong — use `scheme.surface` or `theme.cardColor` for the camera badge border when in dark mode.
- Do **not** navigate when tapping the email row.

- [ ] **Step 2: Register route outside `ShellRoute`**

In `app_router.dart`:
1. Import `account_edit_screen.dart`.
2. After the `ShellRoute` block (alongside `/note/:id`), add:

```dart
      GoRoute(
        path: AppConstants.routeSettingsAccount,
        name: 'settings-account',
        builder: (context, state) => const AccountEditScreen(),
      ),
```

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/features/settings/account_edit_screen.dart lib/core/router/app_router.dart`
Expected: no issues (or only pre-existing unrelated warnings).

- [ ] **Step 4: Commit**

```bash
git add lib/features/settings/account_edit_screen.dart lib/core/router/app_router.dart
git commit -m "feat: add account edit screen and route"
```

---

### Task 3: WeChat bind screen + route

**Files:**
- Create: `lib/features/wechat/wechat_bind_screen.dart`
- Modify: `lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: `AppConstants.routeSettingsWechatBind`, `AppColors.wechat`, `UiStrings` wechat strings, `Clipboard`
- Produces: `WechatBindScreen`; named route `settings-wechat-bind`

- [ ] **Step 1: Create `wechat_bind_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/ui_strings.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/theme/app_colors.dart';

/// UI-only WeChat bind flow (no API).
class WechatBindScreen extends StatefulWidget {
  const WechatBindScreen({super.key});

  @override
  State<WechatBindScreen> createState() => _WechatBindScreenState();
}

class _WechatBindScreenState extends State<WechatBindScreen> {
  late final TextEditingController _codeController;

  static const _steps = [
    UiStrings.wechatStep1,
    UiStrings.wechatStep2,
    UiStrings.wechatStep3,
    UiStrings.wechatStep4,
  ];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: UiStrings.wechatExampleCode);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      $message.error(message: UiStrings.wechatClipboardEmpty);
      return;
    }
    setState(() => _codeController.text = text);
  }

  void _confirm() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      $message.error(message: UiStrings.wechatBindCodeRequired);
      return;
    }
    $message.success(message: UiStrings.wechatBindSuccess);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: const CustomAppBar(
        title: UiStrings.wechatBindTitle,
        showBack: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.wechat,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                UiStrings.wechatBindTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                UiStrings.wechatBindSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        hintText: UiStrings.wechatBindCodeHint,
                        filled: true,
                        fillColor: scheme.surface,
                        suffixIcon: _codeController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(
                                  () => _codeController.clear(),
                                ),
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _paste,
                            icon: const Icon(Icons.content_paste, size: 18),
                            label: const Text(UiStrings.wechatPaste),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: scheme.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: _confirm,
                            icon: const Icon(Icons.link, size: 18),
                            label: const Text(UiStrings.wechatConfirmBind),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.wechat,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  UiStrings.wechatStepsTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < _steps.length; i++) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.wechat,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _steps[i],
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                if (i < _steps.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

Do **not** show a persistent bottom「已绑定」banner.

- [ ] **Step 2: Register route**

```dart
      GoRoute(
        path: AppConstants.routeSettingsWechatBind,
        name: 'settings-wechat-bind',
        builder: (context, state) => const WechatBindScreen(),
      ),
```

Import `wechat_bind_screen.dart`.

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/features/wechat/wechat_bind_screen.dart lib/core/router/app_router.dart`
Expected: clean for these files.

- [ ] **Step 4: Commit**

```bash
git add lib/features/wechat/wechat_bind_screen.dart lib/core/router/app_router.dart lib/core/constants/ui_strings.dart
git commit -m "feat: add WeChat bind screen and route"
```

---

### Task 4: Rebuild SettingsScreen

**Files:**
- Modify: `lib/features/settings/settings_screen.dart` (full rewrite)

**Interfaces:**
- Consumes: `themeModeProvider`, `AppConstants.routeSettingsAccount` / `routeSettingsWechatBind`, `UiStrings`, `$message`
- Produces: Tab settings UI with navigation to Tasks 2–3 routes

- [ ] **Step 1: Rewrite `settings_screen.dart`**

Replace the file with a `ConsumerStatefulWidget` that:

1. Title「设置」, `CustomAppBar(showBack: false)`.
2. Account card → `context.push(AppConstants.routeSettingsAccount)`.
3. Appearance: Switch `value: ref.watch(themeModeProvider) == ThemeMode.dark` (treat non-dark as off); `onChanged: (v) => ref.read(themeModeProvider.notifier).set(v ? ThemeMode.dark : ThemeMode.light)`.
4. Sync: two local bools default `true` (drafts + clipboard).
5. Thresholds: keep Slider ranges from spec (image 1–50 / div 49 / default 10; file 1–200 / div 199 / default 50).
6. Account binding: email static「已绑定」; WeChat row — body `push` wechat-bind;「解绑」`GestureDetector` with `$message.success(message: UiStrings.unbindComingSoon)` and **must not** navigate (use separate hit targets; `InkWell` on row + `TextButton`/`GestureDetector` on 解绑 with empty `onTap` absorption).
7. Wide layout `maxWidth: 600`.
8. Cards: white/surface, radius ~14, light border like previous `_SettingsTile`.

Skeleton (implementer should flesh widgets to match; keep structure):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _draftsSync = true;
  bool _clipboardSync = true;
  double _maxImageSizeMb = 10;
  double _maxFileSizeMb = 50;

  bool get _isWide => MediaQuery.sizeOf(context).width >= 600;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAccountCard(context),
          const SizedBox(height: 24),
          _sectionTitle(UiStrings.appearance),
          _settingsTile(
            icon: Icons.dark_mode_outlined,
            title: UiStrings.darkMode,
            subtitle: UiStrings.darkModeHint,
            trailing: Switch.adaptive(
              value: isDark,
              onChanged: (v) {
                ref.read(themeModeProvider.notifier).set(
                      v ? ThemeMode.dark : ThemeMode.light,
                    );
              },
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(UiStrings.syncSection),
          _settingsTile(
            icon: Icons.inventory_2_outlined,
            title: UiStrings.draftsSync,
            subtitle: UiStrings.draftsSyncHint,
            trailing: Switch.adaptive(
              value: _draftsSync,
              onChanged: (v) => setState(() => _draftsSync = v),
            ),
          ),
          const SizedBox(height: 12),
          _settingsTile(
            icon: Icons.content_paste_go_outlined,
            title: UiStrings.clipboardSync,
            subtitle: UiStrings.clipboardSyncHint,
            trailing: Switch.adaptive(
              value: _clipboardSync,
              onChanged: (v) => setState(() => _clipboardSync = v),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(UiStrings.sizeThresholds),
          _settingsTile(
            icon: Icons.image_outlined,
            title: UiStrings.maxImageSize,
            subtitle: UiStrings.maxImageSizeHint,
            trailing: Text('${_maxImageSizeMb.round()} MB'),
            extra: Slider(
              value: _maxImageSizeMb,
              min: 1,
              max: 50,
              divisions: 49,
              label: '${_maxImageSizeMb.round()} MB',
              onChanged: (v) => setState(() => _maxImageSizeMb = v),
            ),
          ),
          const SizedBox(height: 12),
          _settingsTile(
            icon: Icons.insert_drive_file_outlined,
            title: UiStrings.maxFileSize,
            subtitle: UiStrings.maxFileSizeHint,
            trailing: Text('${_maxFileSizeMb.round()} MB'),
            extra: Slider(
              value: _maxFileSizeMb,
              min: 1,
              max: 200,
              divisions: 199,
              label: '${_maxFileSizeMb.round()} MB',
              onChanged: (v) => setState(() => _maxFileSizeMb = v),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(UiStrings.accountBinding),
          _bindingEmailRow(context),
          const SizedBox(height: 12),
          _bindingWechatRow(context),
        ],
      ),
    );

    return Scaffold(
      appBar: const CustomAppBar(
        title: UiStrings.settings,
        showBack: false,
      ),
      body: _isWide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: content,
              ),
            )
          : content,
    );
  }

  // Implement _buildAccountCard, _sectionTitle, _settingsTile,
  // _bindingEmailRow, _bindingWechatRow per spec:
  // - Account card: avatar initial, name, email, coral「编辑」→ push account
  // - Email binding: non-tappable, show bound
  // - WeChat: row tap → push wechat-bind; 解绑 TextButton → toast only
}
```

Implement the private helpers fully in code (do not leave stubs). Account card and binding rows should use `AppColors.lightSurface` / theme borders consistent with `_settingsTile`.

WeChat row pattern:

```dart
  Widget _bindingWechatRow(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: AppColors.lightSurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(AppConstants.routeSettingsWechatBind),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // wechat icon circle using AppColors.wechat
              // title + 「已绑定」
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  $message.success(message: UiStrings.unbindComingSoon);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    UiStrings.unbind,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/features/settings/settings_screen.dart`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/settings/settings_screen.dart
git commit -m "feat: rebuild settings screen UI with account and sync sections"
```

---

### Task 5: End-to-end verify

**Files:** none (verification only)

- [ ] **Step 1: Full analyze**

Run: `flutter analyze`
Expected: no issues in touched files; project should be clean or only pre-existing warnings unrelated to this work.

- [ ] **Step 2: Manual QA checklist** (run app with local API define as usual)

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

- [ ] Settings tab: all sections visible; bottom nav visible
- [ ] Dark mode toggles theme immediately
- [ ] Sync switches + sliders move
- [ ] 编辑 → account page, no bottom nav; save toast + pop; avatar toast
- [ ] WeChat row → bind page; 解绑 toast stays on settings
- [ ] Bind: paste / clear / empty confirm error / filled success toast
- [ ] Wide: settings content ≤600 centered

- [ ] **Step 3: No extra commit unless fixes were needed** — if analyze/QA found bugs, fix on `master` and commit with `fix: ...`.

---

## Spec coverage (self-review)

| Spec requirement | Task |
|------------------|------|
| Settings rebuild (account, appearance, sync, thresholds, binding) | 4 |
| Account edit page | 2 |
| WeChat bind page | 3 |
| Routes outside shell | 2, 3 |
| `themeModeProvider` wire (no prefs) | 4 |
| Slider divisions | 4 |
| Toasts via tolyui_message | 2, 3, 4 |
| Hit-target split 解绑 vs row | 4 |
| Save → toast + pop | 2 |
| No API / no tests | Global |
| Strings / routes / wechat color | 1 |

**Placeholder scan:** No TBD left. Task 4 includes a skeleton plus required helper behavior; implementer must complete helpers (not leave `// Implement` comments in committed code).

**Type consistency:** Route constants and screen class names match across tasks (`AccountEditScreen`, `WechatBindScreen`, `routeSettingsAccount`, `routeSettingsWechatBind`).
