import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_dtos.freezed.dart';
part 'media_dtos.g.dart';

DateTime? _dateTimeFromJsonNullable(String? json) =>
    json == null ? null : DateTime.parse(json);

String? _dateTimeToJsonNullable(DateTime? dateTime) =>
    dateTime?.toIso8601String();

/// Type of media file.
@JsonEnum()
enum MediaType {
  @JsonValue('IMAGE')
  image,
  @JsonValue('VOICE')
  voice,
  @JsonValue('VIDEO')
  video,
  @JsonValue('FILE')
  file,
}

/// DTO representing a media item.
@freezed
abstract class MediaDto with _$MediaDto {
  const factory MediaDto({
    required String mediaId,
    required String key,
    required String url,
    required String mimeType,
    required int size,
    MediaType? type,
    @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
    DateTime? createdAt,
  }) = _MediaDto;

  factory MediaDto.fromJson(Map<String, dynamic> json) =>
      _$MediaDtoFromJson(json);
}

/// DTO for checking media IDs.
@freezed
abstract class CheckMediaDto with _$CheckMediaDto {
  const factory CheckMediaDto({
    required List<String> mediaIds,
  }) = _CheckMediaDto;

  factory CheckMediaDto.fromJson(Map<String, dynamic> json) =>
      _$CheckMediaDtoFromJson(json);
}

/// DTO for check media result.
@freezed
abstract class CheckMediaResultDto with _$CheckMediaResultDto {
  const factory CheckMediaResultDto({
    required List<String> validIds,
    required List<String> invalidIds,
  }) = _CheckMediaResultDto;

  factory CheckMediaResultDto.fromJson(Map<String, dynamic> json) =>
      _$CheckMediaResultDtoFromJson(json);
}
