# lib/data/services

HTTP service layer: thin wrappers around the backend REST API.

## Overview

Each service class maps to a backend module and exposes typed methods that
return `Future<ApiResponse<T>>`.  They are intentionally thin—no business logic,
no caching, no state management.  That responsibility lives in repositories
and use-cases.

## Services

| File | Backend Module | Auth Required |
|------|---------------|---------------|
| `auth_service.dart` | Authentication (wechat login, refresh, logout) | No |
| `notes_service.dart` | Notes (CRUD, publish, archive, media, share) | Yes |
| `categories_service.dart` | Categories (tree, CRUD, reorder) | Yes |
| `tags_service.dart` | Tags (list, create, delete) | Yes |
| `storage_service.dart` | File storage (upload token, upload, delete) | Yes |
| `media_service.dart` | Media validation (check IDs) | Yes |
| `wechat_service.dart` | WeChat server callbacks | No |

## Usage

```dart
final dio = DioClient.create(tokenStorage: tokenStorage);
final notesService = NotesService(dio);

final response = await notesService.listNotes(page: 1, size: 20);
if (response.isSuccess) {
  print('Notes: ${response.data!.items}');
}
```

## Conventions

- **Constructor injection**: every service accepts a [Dio] instance.
- **Typed responses**: every method returns `Future<ApiResponse<T>>`.
- **HTTP methods**: `GET` for reads, `POST` for mutations (the backend uses
  POST for updates and deletes as well).
- **Query parameters**: passed via `queryParameters` for GET requests.
- **Request body**: passed via `data` for POST requests.
- **Multipart**: `StorageService.uploadFile` uses `FormData` for file uploads.
- **JWT auth**: handled automatically by [AuthInterceptor] wired into the Dio
  client; services do not manipulate headers manually.
