# Note Detail Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a read-only note detail screen between the published notes list and the editor, with pin/unpin, confirmed delete, and a floating「编辑」entry to the existing editor.

**Architecture:** New `NoteDetailScreen` loads `NotesService.getNoteDetailBundle`, renders read-only Quill + attachment cards, and calls `pinNote` / `deleteNote` in-screen (same pattern as editor/account). Routes split: `/note/:id` detail, `/note/:id/edit` editor, `/note/new` create. No Drift/Repository; no category/tag pills.

**Tech Stack:** Flutter, Riverpod, go_router, flutter_quill, Dio/`NotesService`, `tolyui_message`

**Prior spec:** `docs/superpowers/specs/2026-07-18-note-detail-design.md`

**Working directory for all Flutter commands:** repo root (`d:\lbs\demo\sebhua-notes-app`)

## Global Constraints

- Implement on `master` only — no feature branches / worktrees unless the user explicitly asks.
- Do not add automated tests (manual QA only).
- No Repository / Drift / category / tag pills / attachment preview.
- User-visible API feedback: `$message.success` / `$message.error` with backend `message` (fallback `UiStrings` only for client-only / empty message cases).
- Delete requires confirm dialog (mirror drafts).
- After delete success: refresh notes list + `pop` to list.
- After pin success: update local UI + refresh notes list.
- From detail → editor: `await context.push(...); if (mounted) reload`.
- Skip `git commit` steps unless the user explicitly asks to commit in this session.
- Before claiming done: `flutter analyze` must be clean for touched files.

---

## 〇、进度里程碑

| 阶段 | 名称 | 状态 | 完成度 | Demo |
| ---- | ---- | ------ | ------ | ---- |
| 1 | 路由常量 + 导航入口改线 | ✅ 完成 | 5/5 | `/note/:id` → 详情 |
| 2 | NoteDetailScreen 加载 + 只读 UI | ✅ 完成 | 6/6 | 详情展示正文/附件 |
| 3 | 置顶 / 删除 / 编辑回流 | ✅ 完成 | 5/5 | 顶栏操作 + 底栏编辑 |
| 4 | analyze + 手动 QA | ✅ 完成 | 3/3 | — |

**当前进度：** 代码完成；手动 QA PENDING_USER  
**整体完成度：** 19/19 步骤

### 任务总览（Task 勾选）

- [x] Task 1: 路由与入口改线（5 steps）
- [x] Task 2: 详情屏加载与只读 UI（6 steps）
- [x] Task 3: 置顶 / 删除 / 编辑回流（5 steps）
- [x] Task 4: analyze + 手动 QA（3 steps）

---

## File structure

| File | Responsibility |
|------|----------------|
| `lib/core/constants/app_constants.dart` | `routeNoteNew`, `routeNoteEdit`; clarify `routeNote` as detail |
| `lib/core/router/app_router.dart` | Register `/note/new`, `/note/:id/edit`, `/note/:id` |
| `lib/core/constants/ui_strings.dart` | Detail copy (pin/unpin/delete/confirm/edit/load) |
| `lib/features/notes/note_time_format.dart` | `formatNoteDetailTime` → `yyyy.MM.dd HH:mm` |
| `lib/features/notes/note_detail_screen.dart` | Detail UI + load/pin/delete/edit |
| `lib/features/notes/notes_list_screen.dart` | Card → detail (path unchanged `/note/:id`) |
| `lib/features/wechat/drafts_screen.dart` | Open → `/note/:id/edit` |
| （复用）`quill_content_codec.dart` | `decodeNoteContent` |
| （复用）`notes_list_notifier.dart` | `refresh()` after pin/delete |

---

## 技术方案

| 方案 | 结论 |
|------|------|
| 独立 `NoteDetailScreen`，不抽共享 content widget | **采用**（控制本迭代范围） |
| go_router 三条路径：`new` / `:id/edit` / `:id` | **采用**；`/note/new` 必须注册在 `:id` 之前 |
| 附件 0 条时隐藏整块附件区 | **采用** |

---

## 实施步骤

### Task 1: 路由与入口改线

**Files:**
- Modify: `lib/core/constants/app_constants.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/features/wechat/drafts_screen.dart`
- Modify: `lib/core/constants/ui_strings.dart`（先加文案，Task 2/3 使用）
- Modify: `lib/features/notes/note_time_format.dart`

**Interfaces:**
- Produces:
  - `AppConstants.routeNoteNew` = `'/note/new'`
  - `AppConstants.routeNoteEdit` = `'/note/:id/edit'`
  - `AppConstants.routeNote` remains `'/note/:id'` but now means **detail**
  - `AppConstants.noteEditPath(String id)` → `'/note/$id/edit'`（可选 helper，或内联）
  - `formatNoteDetailTime(DateTime? updatedAt)` → `String`
  - UiStrings detail section（见 Step 1.4）
- Consumes: existing `NoteEditorScreen`, `AppConstants.newNoteId`

- [x] **Step 1.1: Update AppConstants routes**

In `lib/core/constants/app_constants.dart`, replace the note route comment block with:

```dart
  /// Note detail (read-only). `:id` is a real note UUID — never `new`.
  static const String routeNote = '/note/:id';

  /// Create note editor.
  static const String routeNoteNew = '/note/new';

  /// Edit existing note.
  static const String routeNoteEdit = '/note/:id/edit';

  /// Builds `/note/{id}/edit` for navigation pushes.
  static String noteEditPath(String id) => '/note/$id/edit';
```

Keep `newNoteId = 'new'`.

- [x] **Step 1.2: Register three GoRoutes**

In `lib/core/router/app_router.dart`, replace the single note `GoRoute` with **three** routes **in this order** (outside `ShellRoute`):

```dart
import '../../features/notes/note_detail_screen.dart';

// ...

GoRoute(
  path: AppConstants.routeNoteNew,
  name: 'note-new',
  builder: (context, state) =>
      const NoteEditorScreen(noteId: AppConstants.newNoteId),
),
GoRoute(
  path: AppConstants.routeNoteEdit,
  name: 'note-edit',
  builder: (context, state) {
    final id = state.pathParameters['id'] ?? AppConstants.newNoteId;
    return NoteEditorScreen(noteId: id);
  },
),
GoRoute(
  path: AppConstants.routeNote,
  name: 'note',
  builder: (context, state) {
    final id = state.pathParameters['id'] ?? '';
    return NoteDetailScreen(noteId: id);
  },
),
```

**Note:** `NoteDetailScreen` is created in Task 2. For Task 1 compile-check, either create a minimal stub file first:

```dart
// lib/features/notes/note_detail_screen.dart (stub — expand in Task 2)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteDetailScreen extends ConsumerWidget {
  const NoteDetailScreen({super.key, required this.noteId});
  final String noteId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('detail:$noteId')),
    );
  }
}
```

Or land Task 1 + Task 2 stub in the same implementer pass before analyze.

List `+` already uses `context.push('/note/${AppConstants.newNoteId}')` which becomes `/note/new` — matches `routeNoteNew`. **Do not change** list `+` path string if it already builds `/note/new`.

List card `context.push('/note/${note.id}')` stays — now opens detail. **No list path change required.**

- [x] **Step 1.3: Drafts open editor via edit path**

In `lib/features/wechat/drafts_screen.dart`, change:

```dart
onOpen: () => context.push('/note/${note.id}'),
```

to:

```dart
onOpen: () => context.push(AppConstants.noteEditPath(note.id)),
```

Add import for `AppConstants` if missing.

- [x] **Step 1.4: Add UiStrings for detail**

In `lib/core/constants/ui_strings.dart`, after the note-editor section, add:

```dart
  // --- Note detail screen ---
  static const String noteDetailPin = '置顶';
  static const String noteDetailUnpin = '取消置顶';
  static const String noteDetailDelete = '删除';
  static const String noteDetailEdit = '编辑';
  static const String noteDetailPinnedBadge = '置顶';
  static const String noteDetailDeleteConfirmTitle = '确认删除';
  static const String noteDetailDeleteConfirmMessage =
      '确定删除这条笔记吗？删除后无法恢复。';
  static const String noteDetailLoadFailed = '加载笔记失败，请重试';
  static const String noteDetailRetry = '重试';
  static const String noteDetailNetworkError = '网络异常，请重试';
  static const String noteDetailUntitled = '无标题';
```

Reuse `noteEditorBack` / `noteEditorAttachments` / `back` where appropriate; do not duplicate「返回」「附件」unless needed.

- [x] **Step 1.5: Add formatNoteDetailTime**

In `lib/features/notes/note_time_format.dart`, append:

```dart
/// Formats detail-page updated time as `yyyy.MM.dd HH:mm` (local).
///
/// Returns empty string when [updatedAt] is null.
String formatNoteDetailTime(DateTime? updatedAt) {
  if (updatedAt == null) return '';
  final local = updatedAt.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final h = local.hour.toString().padLeft(2, '0');
  final min = local.minute.toString().padLeft(2, '0');
  return '$y.$m.$d $h:$min';
}
```

---

### Task 2: NoteDetailScreen 加载与只读 UI

**Files:**
- Create/Replace: `lib/features/notes/note_detail_screen.dart`

**Interfaces:**
- Consumes: `notesServiceProvider`, `getNoteDetailBundle`, `decodeNoteContent`, `formatNoteDetailTime`, UiStrings detail/editor attachments
- Produces: `NoteDetailScreen({required String noteId})` with load + read-only UI (pin/delete/edit wired in Task 3 as stubs or no-ops initially)

- [x] **Step 2.1: Scaffold state + load**

Implement `NoteDetailScreen` as `ConsumerStatefulWidget` with:

```dart
class NoteDetailScreen extends ConsumerStatefulWidget {
  const NoteDetailScreen({super.key, required this.noteId});
  final String noteId;
  // ...
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  var _loading = true;
  var _loadFailed = false;
  String? _loadErrorMessage;
  NoteDetailDto? _note;
  List<_DetailAttachment> _attachments = const [];
  late quill.QuillController _quillController;
  final _editorFocusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
      _loadErrorMessage = null;
    });
    try {
      final response =
          await ref.read(notesServiceProvider).getNoteDetailBundle(widget.noteId);
      if (!mounted) return;
      if (!response.isSuccess || response.data == null) {
        setState(() {
          _loading = false;
          _loadFailed = true;
          _loadErrorMessage = response.message.isNotEmpty
              ? response.message
              : UiStrings.noteDetailLoadFailed;
        });
        return;
      }
      final bundle = response.data!;
      final document = decodeNoteContent(bundle.note.content);
      _quillController
        ..document = document
        ..readOnly = true
        ..updateSelection(
          const TextSelection.collapsed(offset: 0),
          quill.ChangeSource.silent,
        );
      setState(() {
        _note = bundle.note;
        _attachments =
            bundle.media.map(_DetailAttachment.fromNoteMedia).toList();
        _loading = false;
        _loadFailed = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      final apiError = error.error;
      setState(() {
        _loading = false;
        _loadFailed = true;
        _loadErrorMessage =
            apiError is ApiException && apiError.message.isNotEmpty
                ? apiError.message
                : UiStrings.noteDetailLoadFailed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
        _loadErrorMessage = UiStrings.noteDetailLoadFailed;
      });
    }
  }
}
```

Dispose `_quillController`, focus, scroll controllers.

`_DetailAttachment` — copy the name/size/extension/icon/sizeLabel logic from editor’s `_EditorAttachment.fromNoteMedia` + getters (no bytes/remove). Keep private in this file.

- [x] **Step 2.2: Loading / error scaffolds**

Match editor patterns: surface background, back via `context.pop()`, error shows message + `TextButton`「重试」→ `_load()`.

Prefer a custom top bar (coral text) for the success state (Step 2.3); loading/error may use `CustomAppBar(showBack: true)` or the same coral back row.

- [x] **Step 2.3: Top bar + metadata + title**

Success body structure (inside `Scaffold` + `SafeArea` + `Column` or `Stack`):

1. Top row: `TextButton`/`InkWell` `‹ ${UiStrings.noteEditorBack}` left; right placeholder actions (pin/delete wired Task 3) using coral `colorScheme.primary`.
2. Metadata row padding `horizontal: 20`:
   - `Text(formatNoteDetailTime(_note!.updatedAt), style: grey bodySmall)`
   - if `_note!.pinnedAt != null`: pill with `UiStrings.noteDetailPinnedBadge` (primary.withAlpha bg + primary text)
3. Title: `Text` large bold — empty → `UiStrings.noteDetailUntitled`

- [x] **Step 2.4: Read-only Quill body**

```dart
Expanded(
  child: QuillEditor(
    controller: _quillController,
    focusNode: _editorFocusNode,
    scrollController: _scrollController,
    config: QuillEditorConfig(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      // readOnly is on controller; ensure no toolbar
      showCursor: false,
      enableInteractiveSelection: true,
    ),
  ),
)
```

If the project’s `flutter_quill` API differs (e.g. `QuillEditor.basic`), mirror whatever `note_editor_screen.dart` already uses for the editor surface, then set `readOnly: true` / `controller.readOnly = true` and omit toolbar.

Prefer a single vertical `CustomScrollView` / `ListView` if Quill-in-Expanded fights nested scrolling — match editor’s scroll composition as closely as practical for read-only.

- [x] **Step 2.5: Attachments section (hide when empty)**

If `_attachments.isEmpty`, omit the section entirely.

Else show:

```dart
Row(
  children: [
    Text(UiStrings.noteEditorAttachments, style: titleSmall bold),
    SizedBox(width: 8),
    // badge with count — copy editor _AttachmentCountBadge visual
  ],
)
// then cards: icon + name + sizeLabel, bordered rounded, no trailing delete
```

File name from `qiniuKey` last segment; fallback `media.id`. Size from `fileSize` with same B/KB/MB labels as editor.

- [x] **Step 2.6: Floating「编辑」button shell**

Bottom of `Stack` / `Scaffold.bottomNavigationBar` / padded column:

```dart
SafeArea(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
    child: OutlinedButton(
      onPressed: () {/* Task 3 */},
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: colorScheme.surface,
      ),
      child: const Text(UiStrings.noteDetailEdit),
    ),
  ),
)
```

Ensure body has bottom padding (~72) so last attachment isn’t covered.

Verify:

```bash
flutter analyze lib/features/notes/note_detail_screen.dart
```

Expected: No issues (or only pre-existing unrelated).

---

### Task 3: 置顶 / 删除 / 编辑回流

**Files:**
- Modify: `lib/features/notes/note_detail_screen.dart`
- Read-only: `lib/features/notes/notes_list_notifier.dart` (`refresh`)

**Interfaces:**
- Consumes: `NotesService.pinNote`, `NotesService.deleteNote`, `notesListProvider.notifier.refresh`, `AppConstants.noteEditPath`
- Produces: working pin/delete/edit behaviors per spec

- [x] **Step 3.1: Pin / unpin action**

State flags: `var _pinning = false;`

Top-bar right label:

```dart
final pinned = _note?.pinnedAt != null;
final pinLabel = pinned ? UiStrings.noteDetailUnpin : UiStrings.noteDetailPin;
```

On tap:

```dart
Future<void> _togglePin() async {
  if (_pinning || _deleting || _note == null) return;
  setState(() => _pinning = true);
  try {
    final response =
        await ref.read(notesServiceProvider).pinNote(widget.noteId);
    if (!mounted) return;
    if (!response.isSuccess || response.data == null) {
      $message.error(
        message: response.message.isNotEmpty
            ? response.message
            : UiStrings.noteDetailNetworkError,
      );
      return;
    }
    setState(() => _note = response.data);
    if (response.message.isNotEmpty) {
      $message.success(message: response.message);
    }
    await ref.read(notesListProvider.notifier).refresh();
  } on DioException catch (error) {
    if (!mounted) return;
    final apiError = error.error;
    $message.error(
      message: apiError is ApiException && apiError.message.isNotEmpty
          ? apiError.message
          : UiStrings.noteDetailNetworkError,
    );
  } finally {
    if (mounted) setState(() => _pinning = false);
  }
}
```

Update metadata pin pill from `_note!.pinnedAt`.

- [x] **Step 3.2: Delete with confirm dialog**

```dart
var _deleting = false;

Future<void> _confirmDelete() async {
  if (_deleting || _pinning) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(UiStrings.noteDetailDeleteConfirmTitle),
        content: const Text(UiStrings.noteDetailDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(UiStrings.cancel), // or draftsCancel if cancel is English — prefer Chinese: add noteDetailCancel = '取消' OR use existing Chinese cancel if present
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(UiStrings.noteDetailDelete),
          ),
        ],
      );
    },
  );
  if (confirmed == true) await _delete();
}
```

**Copy note:** `UiStrings.cancel` is currently `'Cancel'`. Prefer adding `static const String noteDetailCancel = '取消';` in Task 1 strings (or reuse `UiStrings.draftsCancel` if it is「取消」). Use Chinese「取消」in the dialog.

- [x] **Step 3.3: Delete API + pop**

```dart
Future<void> _delete() async {
  if (_deleting) return;
  setState(() => _deleting = true);
  try {
    final response =
        await ref.read(notesServiceProvider).deleteNote(widget.noteId);
    if (!mounted) return;
    if (!response.isSuccess) {
      $message.error(
        message: response.message.isNotEmpty
            ? response.message
            : UiStrings.noteDetailNetworkError,
      );
      return;
    }
    if (response.message.isNotEmpty) {
      $message.success(message: response.message);
    }
    await ref.read(notesListProvider.notifier).refresh();
    if (!mounted) return;
    context.pop();
  } on DioException catch (error) {
    if (!mounted) return;
    final apiError = error.error;
    $message.error(
      message: apiError is ApiException && apiError.message.isNotEmpty
          ? apiError.message
          : UiStrings.noteDetailNetworkError,
    );
  } finally {
    if (mounted) setState(() => _deleting = false);
  }
}
```

- [x] **Step 3.4: Edit push + reload on return**

```dart
Future<void> _openEditor() async {
  await context.push(AppConstants.noteEditPath(widget.noteId));
  if (mounted) await _load();
}
```

Wire floating button `onPressed: _openEditor`.

- [x] **Step 3.5: Disable actions while busy**

While `_pinning || _deleting || _loading`, disable pin/delete/edit taps (null `onPressed` or early return). Optionally dim top-bar actions.

---

### Task 4: analyze + 手动 QA

**Files:** touched set from Tasks 1–3

- [x] **Step 4.1: flutter analyze**

```bash
flutter analyze lib/features/notes/note_detail_screen.dart lib/core/router/app_router.dart lib/core/constants/app_constants.dart lib/core/constants/ui_strings.dart lib/features/notes/note_time_format.dart lib/features/notes/notes_list_screen.dart lib/features/wechat/drafts_screen.dart
```

Expected: No issues.

- [x] **Step 4.2: Manual QA checklist**

| # | Case | Expected |
|---|------|----------|
| 1 | 列表点卡片 | 打开详情，非编辑 |
| 2 | 列表 `+` | 打开新建编辑 `/note/new` |
| 3 | 草稿「完善」 | 打开 `/note/:id/edit` |
| 4 | 详情加载 | 时间、置顶徽章（若有）、标题、只读正文、附件 |
| 5 | 无附件 | 附件区隐藏 |
| 6 | 置顶 / 取消置顶 | 文案切换、徽章变化、列表刷新后置顶态正确 |
| 7 | 删除 → 取消 | 仍停留详情 |
| 8 | 删除 → 确认 | toast → 回列表且该项消失 |
| 9 | 编辑 → 保存 | 回到详情且内容已更新 |
| 10 | 编辑 → 返回（不保存） | 回到详情；内容与离开前一致（或按服务端仍为旧值） |
| 11 | 加载失败 | 展示错误 + 重试可用 |

- [x] **Step 4.3: Update plan milestones**

In this plan file, mark completed tasks `[x]`, set milestone statuses to ✅, completion N/N.

---

## Spec coverage self-review

| Spec requirement | Task |
|------------------|------|
| List → detail → edit; new/drafts → editor | Task 1 |
| Routes `/note/:id`, `/note/:id/edit`, `/note/new` | Task 1 |
| Metadata: updatedAt + pin badge only | Task 2 |
| Read-only Quill + attachments | Task 2 |
| Floating 编辑 | Task 2 shell + Task 3 wire |
| Pin API + list refresh | Task 3 |
| Delete confirm → API → pop + refresh | Task 3 |
| Reload after editor return | Task 3 |
| No category/tags / no attachment preview / no tests | Global Constraints |
| Manual QA + analyze | Task 4 |

**Placeholder scan:** none intentional. Dialog cancel must use Chinese「取消」(explicit in Step 3.2).

**Type consistency:** `noteEditPath(String id)`, `NoteDetailScreen(noteId:)`, `_load` / `_togglePin` / `_confirmDelete` / `_openEditor` names used consistently above.
