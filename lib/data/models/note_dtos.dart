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
/// / `fileSize`), not the upload-response `MediaDto` (`mediaId` / `key` / `url`).
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
    );
  }

  final String id;
  final String? type;
  final String? qiniuKey;
  final String? qiniuUrl;
  final String? status;
  final String? mimeType;
  final int? fileSize;
}

/// Detail payload: note fields + joined `media` from the same response.
class NoteDetailBundle {
  const NoteDetailBundle({
    required this.note,
    required this.media,
  });

  final NoteDetailDto note;
  final List<NoteMediaItemDto> media;
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

/// DTO representing a note detail response.
@freezed
abstract class NoteDetailDto with _$NoteDetailDto {
  const factory NoteDetailDto({
    required String id,
    String? title,
    String? content,
    NoteSource? source,
    String? type,
    String? categoryId,
    List<String>? tagIds,
    List<String>? mediaIds,
    NoteMetaDto? meta,
    @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
    DateTime? pinnedAt,
    @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
    DateTime? createdAt,
    @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
    DateTime? updatedAt,
  }) = _NoteDetailDto;

  factory NoteDetailDto.fromJson(Map<String, dynamic> json) =>
      _$NoteDetailDtoFromJson(json);
}

/// DTO for paginated note list response.
@freezed
abstract class PaginatedNotes with _$PaginatedNotes {
  const factory PaginatedNotes({
    required List<NoteDetailDto> items,
    required int total,
    required int page,
    required int size,
  }) = _PaginatedNotes;

  factory PaginatedNotes.fromJson(Map<String, dynamic> json) =>
      _$PaginatedNotesFromJson(json);
}

/// DTO for note share information.
@freezed
abstract class ShareInfoDto with _$ShareInfoDto {
  const factory ShareInfoDto({
    required String id,
    required String title,
    String? type,
    required String shareUrl,
  }) = _ShareInfoDto;

  factory ShareInfoDto.fromJson(Map<String, dynamic> json) =>
      _$ShareInfoDtoFromJson(json);
}
