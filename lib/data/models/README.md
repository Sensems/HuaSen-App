# lib/data/models

Shared data transfer objects (DTOs) used across multiple features.

## Guidelines

- Use `json_serializable` for JSON serialization annotations
- Use `freezed` for immutable model classes with copyWith
- Models here are shared; feature-specific DTOs stay in their feature folder
- Run `dart run build_runner build` to generate `.g.dart` and `.freezed.dart` files