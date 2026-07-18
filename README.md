# 花森（HuaSen / sebhua_notes）

跨平台 Flutter 笔记应用：以富文本编辑为核心，支持云端同步、微信草稿箱、账号与主题设置。  
目标平台：**Android / Windows / macOS**（工程内同时保留 iOS、Linux、Web 目录）。

> 口号：记录，以编辑的方式

---

## 功能概览

| 模块 | 能力 |
|------|------|
| **账号** | 邮箱登录 / 注册 / 找回密码；JWT 持久化；过期前主动刷新 + 401 单飞刷新 |
| **笔记** | 已发布笔记列表（搜索、置顶/最近筛选、下拉刷新、分页）；详情阅读；富文本新建/编辑（附件上传后发布） |
| **草稿箱** | 微信/同步草稿列表（文本/图片/音频筛选）；完善编辑、删除；后台轮询新草稿并本地通知 |
| **设置** | 个人资料（头像裁剪上传、昵称等）；微信绑定入口；外观（浅色 / 深色 / 跟随系统）；同步相关开关（部分占位） |
| **剪贴板** | 跨端剪贴板历史页（路由 `/clipboard`，能力持续完善中） |

主界面底部 Tab：**笔记** · **草稿** · **设置**。

---

## 技术栈

- **Flutter** + Dart SDK `^3.12`
- **状态管理**：Riverpod 3
- **路由**：go_router（含登录守卫与 `ShellRoute`）
- **网络**：Dio + Freezed DTO；OpenAPI 见 `docs/api-docs.json`
- **富文本**：flutter_quill
- **本地偏好**：shared_preferences（Token / 主题等）
- **通知**：flutter_local_notifications（草稿更新）

本地 Drift / Repository 分层仍在规划中；当前笔记与草稿主要走后端 REST。

---

## 快速开始

### 环境要求

- Flutter SDK（与项目 `environment.sdk` 兼容）
- 对应平台工具链（Android SDK / Visual Studio 等）

### 安装与运行

```bash
flutter pub get

# 默认 API：http://tv.sensems.top（见 AppConstants）
flutter run -d windows
# 或
flutter run -d android

# 覆盖 API 地址
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

### 构建 Release APK

```bash
flutter build apk --release
# 输出：build/app/outputs/flutter-apk/app-release.apk
```

### 代码生成

修改 Freezed / Riverpod / Drift 注解后：

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 静态检查

```bash
flutter analyze
flutter test
```

---

## 目录结构（简要）

```
lib/
├── main.dart / app.dart          # 入口与 MaterialApp.router
├── core/                         # 常量、路由、Dio / Token
├── data/                         # DTO、API Services
├── features/                     # auth / notes / wechat(草稿) / settings / clipboard
└── ui/                           # 共享组件与主题
docs/
├── api-docs.json                 # OpenAPI
└── schemas-only.json
```

更完整的架构约定与 Agent 指引见 [`AGENTS.md`](./AGENTS.md)。

---

## 主要路由

| 路径 | 说明 |
|------|------|
| `/login` `/register` `/reset-password` | 登录 / 注册 / 重置密码 |
| `/legal/terms` `/legal/privacy` | 用户协议 / 隐私政策（占位页） |
| `/` | 笔记列表（Shell） |
| `/drafts` | 草稿箱（Shell） |
| `/settings` | 设置（Shell） |
| `/note/:id` | 笔记详情 |
| `/note/new` `/note/:id/edit` | 新建 / 编辑 |
| `/settings/account` `/settings/wechat-bind` | 账号编辑 / 微信绑定 |
| `/clipboard` | 剪贴板历史 |

---

## 后端约定

- Base URL：编译期 `API_BASE_URL`，默认 `http://tv.sensems.top`
- 在线文档：`{API_BASE_URL}/api/docs-json`
- 统一响应：`{ "code": 200|0, "message": "...", "data": ... }`
- 邮箱鉴权：`POST /auth/email/login|register|send-code|reset-password`

---

## 仓库

- GitHub：https://github.com/Sensems/HuaSen-App

---

## License

Private / unpublished (`publish_to: 'none'`).
