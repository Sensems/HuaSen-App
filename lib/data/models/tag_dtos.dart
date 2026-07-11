import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_dtos.freezed.dart';
part 'tag_dtos.g.dart';

DateTime _dateTimeFromJson(String json) => DateTime.parse(json);

String _dateTimeToJson(DateTime dateTime) => dateTime.toIso8601String();

int? _notesCountFromJson(Object? json) {
  if (json == null) return null;
  if (json is num) return json.toInt();
  if (json is Map) {
    final dynamic direct = json['notes'] ?? json['Note'];
    if (direct is num) return direct.toInt();
    for (final value in json.values) {
      if (value is num) return value.toInt();
    }
  }
  return null;
}

Object? _notesCountToJson(int? count) => count;

/// DTO representing a tag response.
@freezed
abstract class TagResponseDto with _$TagResponseDto {
  const factory TagResponseDto({
    required String id,
    required String name,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime createdAt,
    @JsonKey(
      name: '_count',
      fromJson: _notesCountFromJson,
      toJson: _notesCountToJson,
    )
    int? notesCount,
  }) = _TagResponseDto;

  factory TagResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TagResponseDtoFromJson(json);
}

/// DTO for creating a new tag.
@freezed
abstract class CreateTagDto with _$CreateTagDto {
  const factory CreateTagDto({
    required String name,
  }) = _CreateTagDto;

  factory CreateTagDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTagDtoFromJson(json);
}
