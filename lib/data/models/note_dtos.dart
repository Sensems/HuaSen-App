import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_dtos.freezed.dart';
part 'note_dtos.g.dart';

DateTime? _dateTimeFromJsonNullable(String? json) =>
    json == null ? null : DateTime.parse(json);

String? _dateTimeToJsonNullable(DateTime? dateTime) =>
    dateTime?.toIso8601String();

/// Source of a note.
///
/// Wire values match the live API (`WECHAT` / `APP_CLIPBOARD` / `APP_MANUAL`).
@JsonEnum()
enum NoteSource {
  @JsonValue('WECHAT')
  wechat,
  @JsonValue('APP_CLIPBOARD')
  appClipboard,
  @JsonValue('APP_MANUAL')
  appManual,
}

/// List view for `GET /notes?view=`.
///
/// Omit ([null]) for the default order (pinned first).
@JsonEnum()
enum NotesListView {
  @JsonValue('pinned')
  pinned,
  @JsonValue('recent')
  recent,
}

/// DTO for creating a new note.
@freezed
abstract class CreateNoteDto with _$CreateNoteDto {
  const factory CreateNoteDto({
    String? title,
    String? content,
    NoteSource? source,
    String? categoryId,
    List<String>? tagIds,
    List<String>? mediaIds,
  }) = _CreateNoteDto;

  factory CreateNoteDto.fromJson(Map<String, dynamic> json) =>
      _$CreateNoteDtoFromJson(json);
}

/// DTO for updating an existing note.
@freezed
abstract class UpdateNoteDto with _$UpdateNoteDto {
  const factory UpdateNoteDto({
    required String id,
    String? title,
    String? content,
    String? categoryId,
    List<String>? tagIds,
    List<String>? mediaIds,
  }) = _UpdateNoteDto;

  factory UpdateNoteDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateNoteDtoFromJson(json);
}

/// Optional note metadata (e.g. WeChat draft media).
///
/// Wire keys use snake_case (`media_url`, `media_type`).
@freezed
abstract class NoteMetaDto with _$NoteMetaDto {
  const factory NoteMetaDto({
    @JsonKey(name: 'media_url') String? mediaUrl,
    @JsonKey(name: 'media_type') String? mediaType,
  }) = _NoteMetaDto;

  factory NoteMetaDto.fromJson(Map<String, dynamic> json) =>
      _$NoteMetaDtoFromJson(json);
}

/// Nested media on `GET /notes/detail` (`media` array).
///
/// Wire shape matches live OpenAPI `MediaItemDto` (`id` / `qiniuKey` / `qiniuUrl`
/// / `fileSize` / optional `originalFilename`), not the upload-response
/// `MediaDto` (`mediaId` / `key` / `url`).
/// Plain class (not freezed) so it can ship without regenerating `NoteDetailDto`.
class NoteMediaItemDto {
  const NoteMediaItemDto({
    required this.id,
    this.type,
    this.qiniuKey,
    this.qiniuUrl,
    this.status,
    this.mimeType,
    this.fileSize,
    this.originalFilename,
  });

  factory NoteMediaItemDto.fromJson(Map<String, dynamic> json) {
    return NoteMediaItemDto(
      id: json['id'] as String,
      type: json['type'] as String?,
      qiniuKey: json['qiniuKey'] as String?,
      qiniuUrl: json['qiniuUrl'] as String?,
      status: json['status'] as String?,
      mimeType: json['mimeType'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      originalFilename: json['originalFilename'] as String?,
    );
  }

  final String id;
  final String? type;
  final String? qiniuKey;
  final String? qiniuUrl;
  final String? status;
  final String? mimeType;
  final int? fileSize;

  /// User-facing original upload name when the API provides it.
  final String? originalFilename;

  /// Display / download basename: prefer [originalFilename], else last segment
  /// of [qiniuKey], else [id].
  String get displayFileName {
    final original = originalFilename?.trim();
    if (original != null && original.isNotEmpty) return original;
    final key = qiniuKey ?? '';
    final fromKey = key.split('/').last;
    if (fromKey.isNotEmpty) return fromKey;
    return id;
  }
}

/// Extracts tag ids from either `tagIds: string[]` or nested
/// `tags: [{ tagId, tag: { id, name } }]`.
List<String>? extractNoteTagIds(Map<String, dynamic> json) {
  final direct = json['tagIds'];
  if (direct is List) {
    return [
      for (final item in direct)
        if (item is String && item.isNotEmpty) item,
    ];
  }

  final tags = json['tags'];
  if (tags is! List) return null;

  final ids = <String>[];
  for (final item in tags) {
    if (item is String && item.isNotEmpty) {
      ids.add(item);
      continue;
    }
    if (item is! Map) continue;
    final tagId = item['tagId'];
    if (tagId is String && tagId.isNotEmpty) {
      ids.add(tagId);
      continue;
    }
    final tag = item['tag'];
    if (tag is Map) {
      final id = tag['id'];
      if (id is String && id.isNotEmpty) ids.add(id);
    }
  }
  return ids;
}

/// Tag display names parallel to [extractNoteTagIds] from nested `tags`.
List<String> extractNoteTagNames(Map<String, dynamic> json) {
  final tags = json['tags'];
  if (tags is! List) return const [];

  final names = <String>[];
  for (final item in tags) {
    if (item is! Map) {
      names.add('');
      continue;
    }
    final tag = item['tag'];
    if (tag is Map && tag['name'] is String) {
      names.add(tag['name'] as String);
    } else {
      names.add('');
    }
  }
  return names;
}

/// Nested `category: { id, name }` display name.
String? extractNoteCategoryName(Map<String, dynamic> json) {
  final category = json['category'];
  if (category is Map && category['name'] is String) {
    final name = category['name'] as String;
    if (name.isNotEmpty) return name;
  }
  return null;
}

/// Detail payload: note fields + joined `media` from the same response.
class NoteDetailBundle {
  const NoteDetailBundle({
    required this.note,
    required this.media,
    this.categoryName,
    this.tagNames = const [],
  });

  final NoteDetailDto note;
  final List<NoteMediaItemDto> media;

  /// From nested `category.name` when present.
  final String? categoryName;

  /// From nested `tags[].tag.name`, parallel to [NoteDetailDto.tagIds].
  final List<String> tagNames;
}

/// List row: note fields + optional joined `media` from the same list-item JSON.
class NotesListItem {
  const NotesListItem({required this.note, this.media = const []});
  final NoteDetailDto note;
  final List<NoteMediaItemDto> media;
}

/// Paginated list payload with optional per-item `media` (plain class).
class PaginatedNotesList {
  const PaginatedNotesList({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
  });

  final List<NotesListItem> items;
  final int total;
  final int page;
  final int size;
}

/// DTO representing a note detail / list-item response.
///
/// Matches OpenAPI `NoteDetailDto` / `NoteListItemDto` core fields. Nested
/// `category` / `tags` / `media` are parsed via helpers / [NoteDetailBundle].
@freezed
abstract class NoteDetailDto with _$NoteDetailDto {
  const factory NoteDetailDto({
    required String id,
    String? userId,
    String? title,
    String? content,
    String? rawContent,
    NoteSource? source,
    String? type,
    String? categoryId,
    List<String>? tagIds,
    List<String>? mediaIds,
    NoteMetaDto? meta,
    @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
    DateTime? deletedAt,
    @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
    DateTime? pinnedAt,
    @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
    DateTime? createdAt,
    @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
    DateTime? updatedAt,
  }) = _NoteDetailDto;

  factory NoteDetailDto.fromJson(Map<String, dynamic> json) =>
      _$NoteDetailDtoFromJson(_normalizeNoteDetailJson(json));
}

Map<String, dynamic> _normalizeNoteDetailJson(Map<String, dynamic> json) {
  final map = Map<String, dynamic>.from(json);
  final tagIds = extractNoteTagIds(map);
  if (tagIds != null) {
    map['tagIds'] = tagIds;
  }
  return map;
}

/// Legacy paginated list shape without per-item `media`.
///
/// Prefer [PaginatedNotesList] for `GET /notes` parsing.
class PaginatedNotes {
  const PaginatedNotes({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
  });

  factory PaginatedNotes.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return PaginatedNotes(
      items: rawItems
          .map((e) => NoteDetailDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
    );
  }

  final List<NoteDetailDto> items;
  final int total;
  final int page;
  final int size;

}

/// DTO for note share information (`NoteShareResponseDto`).
@freezed
abstract class ShareInfoDto with _$ShareInfoDto {
  const factory ShareInfoDto({
    required String id,
    String? title,
    String? type,
    required String shareUrl,
  }) = _ShareInfoDto;

  factory ShareInfoDto.fromJson(Map<String, dynamic> json) =>
      _$ShareInfoDtoFromJson(json);
}
