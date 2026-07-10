import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_dtos.freezed.dart';
part 'note_dtos.g.dart';

DateTime? _dateTimeFromJsonNullable(String? json) =>
    json == null ? null : DateTime.parse(json);

String? _dateTimeToJsonNullable(DateTime? dateTime) =>
    dateTime?.toIso8601String();

/// Source of a note.
@JsonEnum()
enum NoteSource {
  @JsonValue('wechat')
  wechat,
  @JsonValue('app_clipboard')
  appClipboard,
  @JsonValue('app_manual')
  appManual,
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
