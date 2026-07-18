# Avatar Crop After Pick — Design Spec

**Date:** 2026-07-17  
**Status:** Approved (brainstorm)  
**App:** Flutter app at repository root  
**Related:** Account edit (`AccountEditScreen`) avatar pick → local preview → save upload

## Goal

After the user picks an image for the profile avatar on the account edit screen, open a **full-screen circular crop** flow (pan, zoom, 90° rotate). Only a confirmed crop updates the local preview; upload still happens on「保存修改」via existing `StorageService` + `UserService.updateProfile`.

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Crop shape | **A** — circular (matches `CircleAvatar`) |
| Presentation | **A** — full-screen crop page after `FilePicker` |
| Gestures / tools | **B** — pan + zoom + rotate (90° clockwise per tap) |
| Cancel / back | **C** — confirm dialog「放弃本次裁剪？」then discard pick; keep previous preview |
| Implementation | **A** — pure Flutter (`crop_your_image` + `image`), not native `image_cropper` |
| Routing | Imperative `Navigator.push` / `MaterialPageRoute` (bytes payload; no GoRouter deep link) |
| Upload timing | Unchanged — only on account「保存修改」 |
| Feedback | `toly_ui` / `tolyui_message` for errors; reuse existing Progress overlay style for slow export if needed |
| Verification | Manual QA only (no new automated tests unless asked) |

## Out of scope

- Free-aspect or square crop UI
- Continuous free-angle rotation (only 90° steps)
- Changing settings / profile API contracts
- GoRouter registration or deep-link to crop
- Persisting uncropped pick when user cancels crop
- Feature domain/repository layering migration

## Flow

```
AccountEditScreen
  → tap avatar → FilePicker (image, withData)
  → if cancelled: no-op
  → if picked: push AvatarCropScreen(imageBytes)
       → Confirm: pop with cropped Uint8List → set _pickedBytes (+ filename) → CircleAvatar preview
       → Cancel / system back:
            → dialog「放弃本次裁剪？」
            → Yes: pop with null / discard → preview unchanged
            → No: stay on crop screen
  → Save changes: existing upload + updateProfile (cropped bytes if any)
```

## Architecture

Dependency direction unchanged: `features → ui / data / core`.

| Layer | Changes |
|-------|---------|
| **Dependencies** | Add `crop_your_image` and `image` |
| **Feature settings** | New `avatar_crop_screen.dart`; wire `_pickAvatar` in `account_edit_screen.dart` to open crop then apply result |
| **Core / constants** | Chinese strings in `UiStrings` (crop title/actions, discard dialog, failure toasts) |
| **Router** | No GoRouter change |
| **Data / services** | No API change |

### Crop screen contract

```dart
// Conceptual — implementation may use a typedef / simple class
Future<Uint8List?> openAvatarCrop(BuildContext context, Uint8List sourceBytes);
// null => discarded; non-null => JPEG bytes for local preview / later upload
```

Prefer returning result via `Navigator.pop(croppedBytes)` rather than a shared provider.

## UI

Full-screen page, dark dimmed canvas, fixed circular crop window centered:

| Region | Content |
|--------|---------|
| App bar | Leading「取消」; trailing「完成」(primary) |
| Body | `crop_your_image` with circle UI; pan + pinch/scroll zoom; crop rect fixed |
| Bottom |「旋转」— rotate display image 90° clockwise via `image` package, then refresh cropper input |

### Behaviors

- **完成:** run circle crop export → on success `pop` with JPEG bytes; on failure toast and stay
- **取消 / PopScope back:** show confirm dialog before leaving; confirmed leave discards this pick
- **旋转:** updates in-memory working bytes for the cropper; does not leave the page
- While exporting: disable double-submit; show button/page Progress indicator (same spirit as account save overlay — not a misleading idle button)

## Output specs

| Spec | Value |
|------|-------|
| Format | JPEG |
| Size | Longest side ≈ **512px** (square bounding box of circular crop) |
| Delivery | `Uint8List` to `AccountEditScreen._pickedBytes` |
| Filename | Keep picker name when present, else `avatar.jpg` |

## Error handling

| Case | Behavior |
|------|----------|
| User cancels file picker | Do not open crop |
| Crop export fails | `$message.error` with `UiStrings` fallback (e.g. crop failed); stay on crop |
| Rotate fails | `$message.error` with `UiStrings` fallback; keep previous working image |
| Account save / upload | Unchanged existing error + Progress overlay path |

## Manual QA checklist

1. Pick image → crop page opens with circular mask.
2. Pan / zoom; rotate 90° ×4 returns to original orientation.
3. Confirm → preview updates on account edit; save uploads new avatar.
4. Cancel crop → confirm dialog → Yes → preview unchanged (no new pick).
5. Cancel dialog → No → remain on crop.
6. Smoke on Chrome (Web) and at least one of Android / Windows if available.

## Success criteria

- Circular crop is required after pick before preview changes.
- Pan, zoom, and 90° rotate work on the crop page.
- Discard path never applies uncropped bytes.
- Save/upload path remains the existing account edit flow with cropped bytes only when confirmed.
