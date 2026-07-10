# Sebhua Notes — Agent 指南

> 本文档面向 AI Agent / 开发者，说明项目定位、目录结构、架构约定与开发注意事项。  
> **以代码为准**：若本文与源码冲突，以 `sebhua_notes_app/` 下实际代码为准。

---

## 1. 项目简介

**Sebhua Notes（sebhua_notes）** 是一款跨平台 Flutter 笔记应用，目标平台包括 **Android / Windows / macOS**（同时保留 iOS、Linux、Web 工程目录）。

### 核心能力（产品目标）

| 能力 | 说明 |
|------|------|
| 混合笔记 | 富文本（Flutter Quill）+ 图片/音视频等媒体嵌入 |
| 本地优先 | Drift + SQLite 本地持久化，支持离线编辑 |
| 云端同步 | 通过后端 REST API 同步笔记、分类、标签、媒体 |
| 跨端剪贴板 | `super_clipboard` + WebSocket，同步文本/图片/文件 |
| 微信草稿 | 微信登录与草稿同步（`fluwx` / 后端 WeChat 回调） |
| 主题 | 浅色 / 深色主题，Riverpod 管理 `ThemeMode` |

### 当前实现阶段（2026-07）

| 层级 | 状态 |
|------|------|
| 工程脚手架、主题、基础 UI 组件 | ✅ 已完成 |
| 占位功能页（笔记列表/编辑器/设置/剪贴板/微信草稿） | ✅ UI 占位已完成 |
| GoRouter 路由骨架 | ✅ 已完成（路由仍指向占位 Scaffold，尚未挂接真实 Screen） |
| Dio 网络层 + 拦截器 + API Services + Freezed DTOs | ✅ 已完成 |
| Drift 数据库 / Repository 实现 | ⏳ 目录与 README 已就绪，实现待补 |
| Feature 内 domain / presentation 分层 | ⏳ README 约定已写，代码多为扁平 Screen |

---

## 2. 工作区布局（重要）

仓库根目录与真正的 Flutter 应用**不是同一层**：

```
sebhua-notes-app/                 ← 工作区根（本 AGENTS.md 所在位置）
├── AGENTS.md
├── pubspec.yaml                  ← ⚠️ 根级旧/草稿依赖清单，勿当作主工程
├── lib/                          ← ⚠️ 根级极简 stub（main/app），勿在此开发
├── .omo/plans/                   ← 内部实现计划（脚手架、API Client 等）
├── .codegraph/                   ← Codegraph 索引（可选）
└── sebhua_notes_app/             ← ✅ 真正的 Flutter 应用（日常开发目录）
    ├── pubspec.yaml              ← 主依赖清单（以此为准）
    ├── lib/                      ← 全部业务代码
    ├── docs/                     ← OpenAPI 相关 JSON
    ├── android/ ios/ windows/ macos/ linux/ web/
    └── test/
```

**Agent 约定：**

1. 所有功能开发、依赖变更、`flutter` 命令均在 **`sebhua_notes_app/`** 下执行。
2. 不要修改根目录 `lib/` / `pubspec.yaml`，除非用户明确要求清理或合并工程。
3. OpenAPI 参考：`sebhua_notes_app/docs/api-docs.json`、`schemas-only.json`。

---

## 3. 技术栈

| 类别 | 技术 | 用途 |
|------|------|------|
| 框架 | Flutter + Dart SDK ^3.12 | UI / 跨平台 |
| 状态管理 | Riverpod 3 + `riverpod_annotation` | Provider / DI |
| 路由 | go_router | 声明式导航 |
| 本地 DB | Drift + sqlite3 | 离线存储（待完善） |
| 网络 | Dio + web_socket_channel | REST / 实时剪贴板 |
| 模型 | freezed + json_serializable | 不可变 DTO + JSON |
| 富文本 | flutter_quill | 笔记编辑器 |
| 剪贴板 | super_clipboard | 跨平台剪贴板 |
| 文件 | file_picker + path_provider | 选文件 / 路径 |
| 代码生成 | build_runner、riverpod_generator、drift_dev | `.g.dart` / `.freezed.dart` |
| Lint | flutter_lints + riverpod_lint | 静态分析 |

API Base URL 通过编译期常量注入：

```dart
// lib/core/constants/app_constants.dart
String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.example.com')
```

运行示例：

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.example.com
```

---

## 4. 架构总览

采用 **Feature-first + 共享 Core/Data/UI** 分层：

```
┌─────────────────────────────────────────────────────────┐
│  features/*          功能模块（页面、后续 domain/data）   │
├─────────────────────────────────────────────────────────┤
│  ui/                 共享组件 + 主题                      │
├─────────────────────────────────────────────────────────┤
│  data/               共享 DTO、API Services、DB、Repo     │
├─────────────────────────────────────────────────────────┤
│  core/               常量、路由、网络基础设施（无业务依赖） │
└─────────────────────────────────────────────────────────┘
```

**依赖方向（必须遵守）：**

```
features → ui / data / core
ui       → core（可）
data     → core（可）
core     → 不得依赖 features / data / ui
```

**数据流（目标形态）：**

```
UI (Screen / Widget)
  → Riverpod Provider / Notifier
    → Repository（协调本地 Drift + 远程 Service）
      → Service（Dio，薄封装 REST）
      → DAO / Drift（本地）
```

当前阶段：UI 多为占位数据；Service/DTO 已就绪；Repository / Drift 待实现。

---

## 5. 详细目录结构

### 5.1 应用入口

```
sebhua_notes_app/lib/
├── main.dart          # ProviderScope + runApp
└── app.dart           # SebhuaNotesApp：MaterialApp.router + 主题
```

### 5.2 `lib/core/` — 基础设施

```
core/
├── constants/
│   ├── app_constants.dart   # 应用名、路由、API URL、存储 key、笔记限制
│   └── ui_strings.dart      # UI 文案常量
├── network/
│   ├── dio_client.dart      # Dio 工厂（超时、JSON、拦截器链）
│   ├── auth_interceptor.dart# Bearer JWT；401 清 token → UnauthorizedException
│   ├── error_interceptor.dart
│   ├── logging_interceptor.dart
│   ├── token_storage.dart   # TokenStorage 抽象接口（实现待补）
│   └── api_exception.dart
└── router/
    └── app_router.dart      # GoRouter + routerProvider
```

**路由表：**

| Path | Name | 用途 |
|------|------|------|
| `/` | home | 笔记列表 |
| `/note/:id` | note | 编辑器；`id=new` 表示新建 |
| `/settings` | settings | 设置 |
| `/clipboard` | clipboard | 剪贴板历史 |

> 注意：`app_router.dart` 目前渲染 `_PlaceholderScreen`，而 `features/*/…_screen.dart` 已有真实 UI 占位页，**尚未接线**。后续改动应把路由 builder 指向对应 Screen。

### 5.3 `lib/data/` — 共享数据层

```
data/
├── models/            # Freezed + json_serializable DTO
├── services/          # 按后端模块划分的 HTTP Service
├── database/          # Drift（目前仅 README，实现待补）
└── repositories/      # 跨 Feature 仓库（目前仅 README，实现待补）
```

#### API Services

| Service | 模块 | 鉴权 |
|---------|------|------|
| `AuthService` | 微信登录 / refresh / logout | 否 |
| `NotesService` | 笔记 CRUD、发布、归档、媒体、分享 | 是 |
| `CategoriesService` | 分类树、CRUD、排序 | 是 |
| `TagsService` | 标签列表、创建、删除 | 是 |
| `StorageService` | 上传 token、multipart 上传、删除 | 是 |
| `MediaService` | 媒体 ID 校验 | 是 |
| `WechatService` | 服务端微信回调相关 | 否 |

约定：

- 构造注入 `Dio`；方法返回 `Future<ApiResponse<T>>`。
- 读用 `GET`，写/删/更新多用 `POST`（与后端约定一致）。
- JWT 由 `AuthInterceptor` 自动注入，Service 不手动改 Header。

#### 统一响应

```json
{ "code": 200, "message": "OK", "data": { } }
```

`ApiResponse.isSuccess` 当且仅当 `code == 200`。

#### 主要 DTO 分组

| 文件 | 内容 |
|------|------|
| `note_dtos.dart` | Create/Update/Detail、分页、分享、`NoteSource` |
| `auth_dtos.dart` / token / wechat callback | 登录与令牌 |
| `category_dtos.dart` | 分类树与 CRUD |
| `tag_dtos.dart` | 标签 |
| `media_dtos.dart` / `storage_dtos.dart` | 媒体与对象存储 |
| `api_response.dart` / `api_error.dart` | 通用包装与错误 |

部分历史单文件 DTO（如 `create_note_dto.dart`）与聚合文件并存；**新增模型优先写入对应 `*_dtos.dart` 聚合文件**，并跑代码生成。

### 5.4 `lib/features/` — 功能模块

```
features/
├── notes/
│   ├── notes_list_screen.dart    # 列表 + 搜索 + 宽屏双列
│   ├── note_editor_screen.dart   # 编辑器占位
│   └── README.md
├── clipboard/
│   ├── clipboard_history_screen.dart
│   └── README.md
├── settings/
│   ├── settings_screen.dart
│   └── README.md
└── wechat/
    ├── drafts_screen.dart
    └── README.md
```

目标内部结构（README 约定，尚未完全落地）：

```
features/<name>/
├── data/           # 数据源、DTO、Repository 实现
├── domain/         # Entity、Repository 接口、UseCase
└── presentation/   # Page、Widget、Riverpod
```

| Feature | 职责 |
|---------|------|
| **notes** | 富文本笔记 CRUD、媒体嵌入、本地持久化与同步 |
| **clipboard** | 系统剪贴板监听、WebSocket 跨端同步 |
| **settings** | 主题、偏好、账号相关配置 |
| **wechat** | 微信鉴权与草稿同步 |

### 5.5 `lib/ui/` — 共享 UI

```
ui/
├── components/
│   ├── custom_app_bar.dart
│   ├── custom_bottom_nav.dart
│   ├── custom_button.dart
│   ├── custom_card.dart
│   └── custom_input.dart
└── theme/
    ├── app_colors.dart
    ├── app_typography.dart
    ├── app_theme.dart          # light / dark ThemeData
    └── theme_provider.dart     # themeModeProvider
```

组件须保持 **Feature 无关**；业务专用 Widget 放进对应 `features/<name>/`。

---

## 6. 关键约定（给 Agent）

### 6.1 改代码前

1. 确认工作目录是 `sebhua_notes_app/`。
2. 优先用 Codegraph / 现有 README 定位模块，避免在根 `lib/` 写代码。
3. 网络相关改动：同步检查 `docs/api-docs.json` 与对应 Service/DTO。

### 6.2 分层与文件放置

| 要做的事 | 放哪里 |
|----------|--------|
| 新页面 / Feature 状态 | `lib/features/<feature>/` |
| 通用按钮、输入框、主题色 | `lib/ui/` |
| 新 REST 接口 | `lib/data/services/` + `lib/data/models/` |
| 路由常量 | `AppConstants` + `app_router.dart` |
| Token / Dio / 异常 | `lib/core/network/` |
| 本地表结构 | `lib/data/database/`（实现时） |

### 6.3 代码风格

- 公共 API 用文档注释说明「为什么 / 如何用」，避免复述显而易见的逻辑。
- DTO 使用 `@freezed` + `fromJson`；改模型后必须跑 build_runner。
- Service 保持薄封装，业务逻辑进 Repository / Notifier。
- 不引入与任务无关的重构；不擅自改无关文件。
- 用户未要求时不主动写 Markdown 文档；本 `AGENTS.md` 除外（用户明确要求）。

### 6.4 代码生成

修改 Freezed / json_serializable / Riverpod / Drift 注解后：

```bash
cd sebhua_notes_app
dart run build_runner build --delete-conflicting-outputs
```

### 6.5 验证

完成功能或修复后，在 `sebhua_notes_app/` 执行：

```bash
flutter analyze
# 如有测试：
flutter test
```

宣称「通过 / 完成」前必须有上述命令的实际输出依据。

---

## 7. 常用命令

```bash
cd sebhua_notes_app

flutter pub get
flutter run -d windows          # 或 android / macos
flutter run --dart-define=API_BASE_URL=https://...
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
```

---

## 8. 关键模块速查

| 需求 | 入口文件 |
|------|----------|
| 启动 / ProviderScope | `lib/main.dart` |
| 主题 + Router 挂载 | `lib/app.dart` |
| 路由定义 | `lib/core/router/app_router.dart` |
| API Base URL / 路由常量 | `lib/core/constants/app_constants.dart` |
| Dio 创建 | `lib/core/network/dio_client.dart` |
| 笔记 API | `lib/data/services/notes_service.dart` |
| 鉴权 API | `lib/data/services/auth_service.dart` |
| 笔记 DTO | `lib/data/models/note_dtos.dart` |
| 笔记列表 UI | `lib/features/notes/notes_list_screen.dart` |
| 主题切换 | `lib/ui/theme/theme_provider.dart` |
| OpenAPI | `docs/api-docs.json` |

---

## 9. 已知缺口（后续任务提示）

1. **路由接线**：`GoRouter` → 真实 `*Screen`，并补 Shell（BottomNav / NavigationRail）。
2. **TokenStorage 实现**：基于 `shared_preferences`（或安全存储）落地接口。
3. **Drift schema + DAO**：笔记 / 剪贴板本地表与迁移。
4. **Repository 层**：打通 Service ↔ 本地 DB，供 Riverpod 消费。
5. **Feature 内部分层**：将扁平 Screen 迁入 `presentation/`，补 domain。
6. **根目录 stub 清理**：合并或删除根级 `lib/` 与旧 `pubspec.yaml`，避免双工程混淆。

---

## 10. 相关计划文档

| 文档 | 内容 |
|------|------|
| `.omo/plans/flutter-scaffold.md` | 脚手架与占位页计划（已完成） |
| `.omo/plans/api-client-architecture.md` | API Client 分层计划（已完成） |
| `sebhua_notes_app/lib/**/README.md` | 各层职责说明 |

---

*生成说明：本文由代码与现有 README / 计划文档归纳而成，供 Agent 快速建立上下文。*

---

## Learned User Preferences

- Always persist auth tokens after successful login; do not use a "remember me" checkbox.
- Prefer closely restoring provided design mocks for branded screens (e.g. login); app primary/accent color is `#ed6f5c`.
- Login brand copy follows the approved mock: title「花森」, slogan「记录，以编辑的方式」.

## Learned Workspace Facts

- Local development API base URL: `http://127.0.0.1:3000`.
- Backend email auth endpoints: `POST /auth/email/login`, `POST /auth/email/register`, `POST /auth/email/send-code`; no forgot-password endpoint.
- Auth delivery scope: login-only first (`features/auth`, `/login` + route guard + `TokenStorage`); register / forgot-password links are placeholders for now.
