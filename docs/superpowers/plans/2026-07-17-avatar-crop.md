# Avatar Crop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** After picking an avatar image on account edit, open a full-screen circular crop page (pan / zoom / 90° rotate); only a confirmed crop updates the local preview; upload still happens on「保存修改」.

**Architecture:** Imperative `Navigator.push` to a new `AvatarCropScreen` carrying `Uint8List` source bytes. Pure Flutter `crop_your_image` (circle UI + interactive pan/zoom + `cropCircle`) and `image` (90° rotate + JPEG resize). Result pops back as `Uint8List?`; account edit keeps existing save/upload path.

**Tech Stack:** Flutter, `crop_your_image`, `image`, existing `file_picker`, `tolyui_message`, Material 3 theme

**Spec:** `docs/superpowers/specs/2026-07-17-avatar-crop-design.md`

**Working directory for all Flutter commands:** repo root (`d:\lbs\demo\sebhua-notes-app`)

## Global Constraints

- Implement on `master` only — no feature branches / worktrees unless the user explicitly asks.
- Do not add automated tests (manual QA only).
- No GoRouter registration for the crop page (bytes payload; use `Navigator.push`).
- No changes to `StorageService` / `UserService` / profile APIs.
- User-visible client errors: `$message.error` with `UiStrings` fallbacks (not ad-hoc SnackBars).
- Accent via `ColorScheme.primary` / `AppColors`.
- Skip `git commit` steps unless the user explicitly asks to commit in this session.
- Before claiming done: `flutter analyze` must be clean for touched files.
- `crop_your_image` result types: sealed `CropResult` with `CropSuccess(croppedImage)` / `CropFailure(cause)` (verify after `pub get` if package major bumps).

---

## 〇、进度里程碑

| 阶段 | 状态 | 完成度 |
|------|------|--------|
| 当前 | 全部完成 | **3/3** |
| Task 1 | Dependencies + UiStrings | ✅ |
| Task 2 | `AvatarCropScreen` + open helper | ✅ |
| Task 3 | Wire `AccountEditScreen` + analyze | ✅ |

---

## File structure

| File | Responsibility |
|------|----------------|
| `pubspec.yaml` | Add `crop_your_image`, `image` |
| `lib/core/constants/ui_strings.dart` | Crop page + discard dialog + failure copy |
| `lib/features/settings/avatar_crop_screen.dart` | Full-screen crop UI + `openAvatarCrop` helper |
| `lib/features/settings/account_edit_screen.dart` | After pick → open crop → apply confirmed bytes only |

---

### Task 1: Dependencies + UiStrings

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/core/constants/ui_strings.dart`

**Interfaces:**
- Produces: pub deps available; new `UiStrings` constants listed below

- [ ] **Step 1: Add packages**

In `pubspec.yaml` under `dependencies:`, add (use latest compatible versions from `flutter pub add`):

```bash
flutter pub add crop_your_image image
```

Expected: `pubspec.yaml` / `pubspec.lock` updated; exit 0.

- [ ] **Step 2: Add avatar-crop strings**

In `lib/core/constants/ui_strings.dart`, in the Account edit section (near `tapToEditAvatar`), add:

```dart
  static const String avatarCropTitle = '裁剪头像';
  static const String avatarCropCancel = '取消';
  static const String avatarCropDone = '完成';
  static const String avatarCropRotate = '旋转';
  static const String avatarCropDiscardTitle = '放弃本次裁剪？';
  static const String avatarCropDiscardBody = '返回后将丢弃本次选择的图片';
  static const String avatarCropDiscardConfirm = '放弃';
  static const String avatarCropDiscardKeep = '继续裁剪';
  static const String avatarCropFailed = '裁剪失败，请重试';
  static const String avatarRotateFailed = '旋转失败，请重试';
```

Do **not** delete `avatarEditComingSoon` in this task (even if unused).

- [ ] **Step 3: Verify analyze on strings**

```bash
flutter analyze lib/core/constants/ui_strings.dart
```

Expected: No issues.

---

### Task 2: `AvatarCropScreen` + `openAvatarCrop`

**Files:**
- Create: `lib/features/settings/avatar_crop_screen.dart`

**Interfaces:**
- Consumes: `UiStrings` from Task 1; `crop_your_image`; `image`
- Produces:
  - `Future<Uint8List?> openAvatarCrop(BuildContext context, Uint8List sourceBytes)`
  - `AvatarCropScreen({ required Uint8List imageBytes })` — pops `Uint8List` on confirm, `null` on discard

- [ ] **Step 1: Create helper + screen skeleton**

Create `lib/features/settings/avatar_crop_screen.dart` with:

```dart
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/ui_strings.dart';

/// Opens full-screen circular avatar crop. Returns JPEG bytes, or null if discarded.
Future<Uint8List?> openAvatarCrop(
  BuildContext context,
  Uint8List sourceBytes,
) {
  return Navigator.of(context).push<Uint8List>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => AvatarCropScreen(imageBytes: sourceBytes),
    ),
  );
}

class AvatarCropScreen extends StatefulWidget {
  const AvatarCropScreen({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  static const int _maxEdge = 512;

  final _controller = CropController();
  late Uint8List _workingBytes;
  bool _exporting = false;
  bool _rotating = false;

  @override
  void initState() {
    super.initState();
    _workingBytes = widget.imageBytes;
  }

  // ... methods in following steps
}
```

- [ ] **Step 2: Implement discard confirm + PopScope**

```dart
  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(UiStrings.avatarCropDiscardTitle),
        content: const Text(UiStrings.avatarCropDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(UiStrings.avatarCropDiscardKeep),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              UiStrings.avatarCropDiscardConfirm,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _onCancel() async {
    if (_exporting) return;
    if (!await _confirmDiscard()) return;
    if (!mounted) return;
    Navigator.of(context).pop(); // null result
  }
```

- [ ] **Step 3: Implement rotate (90° CW) via `image`**

```dart
  Future<void> _rotate() async {
    if (_exporting || _rotating) return;
    setState(() => _rotating = true);
    try {
      final decoded = img.decodeImage(_workingBytes);
      if (decoded == null) {
        $message.error(message: UiStrings.avatarRotateFailed);
        return;
      }
      final rotated = img.copyRotate(decoded, angle: 90);
      final encoded = Uint8List.fromList(img.encodeJpg(rotated, quality: 92));
      setState(() {
        _workingBytes = encoded;
        _controller.image = encoded;
      });
    } catch (_) {
      $message.error(message: UiStrings.avatarRotateFailed);
    } finally {
      if (mounted) setState(() => _rotating = false);
    }
  }
```

- [ ] **Step 4: Implement confirm export → resize → JPEG → pop**

```dart
  Future<void> _onDone() async {
    if (_exporting || _rotating) return;
    setState(() => _exporting = true);
    _controller.cropCircle();
  }

  void _onCropped(CropResult result) {
    switch (result) {
      case CropSuccess(:final croppedImage):
        try {
          final out = _toAvatarJpeg(croppedImage);
          if (!mounted) return;
          Navigator.of(context).pop(out);
        } catch (_) {
          if (mounted) setState(() => _exporting = false);
          $message.error(message: UiStrings.avatarCropFailed);
        }
      case CropFailure():
        if (mounted) setState(() => _exporting = false);
        $message.error(message: UiStrings.avatarCropFailed);
    }
  }

  Uint8List _toAvatarJpeg(Uint8List input) {
    final decoded = img.decodeImage(input);
    if (decoded == null) {
      throw StateError('decode failed');
    }
    img.Image sized = decoded;
    final longest = decoded.width > decoded.height ? decoded.width : decoded.height;
    if (longest > _maxEdge) {
      sized = decoded.width >= decoded.height
          ? img.copyResize(decoded, width: _maxEdge)
          : img.copyResize(decoded, height: _maxEdge);
    }
    // Flatten alpha onto white for JPEG.
    final flat = img.Image(width: sized.width, height: sized.height);
    img.fill(flat, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(flat, sized);
    return Uint8List.fromList(img.encodeJpg(flat, quality: 85));
  }
```

**Important:** After `flutter pub get`, open the package’s `CropResult` definition and adjust the `switch` so it compiles. Do not leave a non-compiling placeholder.

- [ ] **Step 5: Build UI**

```dart
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onCancel();
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: const Text(UiStrings.avatarCropTitle),
              leading: TextButton(
                onPressed: _exporting ? null : _onCancel,
                child: const Text(
                  UiStrings.avatarCropCancel,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: (_exporting || _rotating) ? null : _onDone,
                  child: Text(
                    UiStrings.avatarCropDone,
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: Crop(
                    image: _workingBytes,
                    controller: _controller,
                    onCropped: _onCropped,
                    withCircleUi: true,
                    interactive: true,
                    fixCropRect: true,
                    baseColor: Colors.black,
                    maskColor: Colors.black.withValues(alpha: 0.65),
                    progressIndicator: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    // Hide default corner dots for circular avatar UX:
                    cornerDotBuilder: (size, edgeAlignment) =>
                        const SizedBox.shrink(),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed:
                            (_exporting || _rotating) ? null : _rotate,
                        icon: const Icon(Icons.rotate_90_degrees_cw),
                        label: const Text(UiStrings.avatarCropRotate),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_exporting)
            const Positioned.fill(
              child: ModalBarrier(
                dismissible: false,
                color: Color(0x66000000),
              ),
            ),
          if (_exporting)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
```

- [ ] **Step 6: Analyze crop screen**

```bash
flutter analyze lib/features/settings/avatar_crop_screen.dart
```

Expected: No issues. Fix `image` API naming (`copyRotate` / `fill` / `compositeImage`) against the resolved `image` package version until clean.

---

### Task 3: Wire `AccountEditScreen` + final verify

**Files:**
- Modify: `lib/features/settings/account_edit_screen.dart` (`_pickAvatar` only; save path unchanged)

**Interfaces:**
- Consumes: `openAvatarCrop` from Task 2
- Produces: `_pickedBytes` / `_pickedFilename` updated **only** when crop returns non-null

- [ ] **Step 1: Import crop helper**

At top of `account_edit_screen.dart`:

```dart
import 'avatar_crop_screen.dart';
```

- [ ] **Step 2: Replace `_pickAvatar` body after successful byte read**

Keep `FilePicker` logic; after validating `bytes`, do **not** `setState` immediately. Instead:

```dart
  Future<void> _pickAvatar() async {
    final result = await FilePicker.pickFiles(
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

    final cropped = await openAvatarCrop(context, bytes);
    if (!mounted || cropped == null || cropped.isEmpty) return;

    setState(() {
      _pickedBytes = cropped;
      _pickedFilename = file.name.isNotEmpty ? file.name : 'avatar.jpg';
      // Prefer .jpg extension for upload mime clarity when original was png/heic:
      if (!_pickedFilename!.toLowerCase().endsWith('.jpg') &&
          !_pickedFilename!.toLowerCase().endsWith('.jpeg')) {
        _pickedFilename = 'avatar.jpg';
      }
    });
  }
```

Do not change `_save`, overlay Progress, or profile loading branches.

- [ ] **Step 3: Analyze touched files**

```bash
flutter analyze lib/features/settings/account_edit_screen.dart lib/features/settings/avatar_crop_screen.dart lib/core/constants/ui_strings.dart
```

Expected: No issues.

- [ ] **Step 4: Manual QA (Chrome + one desktop/mobile if available)**

1. Account edit → tap avatar → pick image → crop page opens with circular mask.
2. Pan / zoom; tap「旋转」four times → orientation returns to start.
3. 「完成」→ back to account edit with updated circular preview;「保存修改」uploads.
4. Pick again →「取消」→ dialog →「放弃」→ preview unchanged.
5. Pick again →「取消」→「继续裁剪」→ stay on crop page.
6. System back on crop → same discard dialog.

Update plan milestone table to 3/3 when done.

---

## Spec coverage (self-review)

| Spec requirement | Task |
|------------------|------|
| Circular crop after pick | Task 2 + 3 |
| Full-screen page | Task 2 |
| Pan + zoom | Task 2 (`interactive` + `fixCropRect`) |
| 90° rotate | Task 2 |
| Cancel confirm then discard | Task 2 |
| Confirm → local preview only | Task 3 |
| Upload on save unchanged | Task 3 (no `_save` edits) |
| JPEG ~512px | Task 2 `_toAvatarJpeg` |
| Pure Flutter packages | Task 1 |
| No GoRouter | Task 2 (`Navigator.push`) |
| Manual QA | Task 3 Step 4 |

## Placeholder / consistency notes

- Filename rule: cropped upload uses `avatar.jpg` when original extension is not jpg/jpeg (matches JPEG output).
- Dialog「继续裁剪」uses `UiStrings.avatarCropDiscardKeep`.
