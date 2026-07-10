import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_dtos.freezed.dart';
part 'tag_dtos.g.dart';

DateTime _dateTimeFromJson(String json) => DateTime.parse(json);

String _dateTimeToJson(DateTime dateTime) => dateTime.toIso8601String();

/// DTO representing a tag response.
@freezed
abstract class TagResponseDto with _$TagResponseDto {
  const factory TagResponseDto({
    required String id,
    required String name,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime createdAt,
    int? count,
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
