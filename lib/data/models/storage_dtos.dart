import 'package:freezed_annotation/freezed_annotation.dart';

part 'storage_dtos.freezed.dart';
part 'storage_dtos.g.dart';

/// DTO for upload token response.
@freezed
abstract class UploadTokenResponseDto with _$UploadTokenResponseDto {
  const factory UploadTokenResponseDto({
    required String token,
  }) = _UploadTokenResponseDto;

  factory UploadTokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UploadTokenResponseDtoFromJson(json);
}

/// DTO for upload file response.
@freezed
abstract class UploadFileResponseDto with _$UploadFileResponseDto {
  const factory UploadFileResponseDto({
    required String mediaId,
    required String key,
    required String url,
    required String mimeType,
    required int size,
  }) = _UploadFileResponseDto;

  factory UploadFileResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UploadFileResponseDtoFromJson(json);
}

/// DTO for deleting a file.
@freezed
abstract class DeleteFileDto with _$DeleteFileDto {
  const factory DeleteFileDto({
    required String key,
  }) = _DeleteFileDto;

  factory DeleteFileDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteFileDtoFromJson(json);
}

/// DTO for delete file response.
@freezed
abstract class DeleteFileResponseDto with _$DeleteFileResponseDto {
  const factory DeleteFileResponseDto({
    required bool success,
  }) = _DeleteFileResponseDto;

  factory DeleteFileResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteFileResponseDtoFromJson(json);
}
