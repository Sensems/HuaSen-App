import 'package:flutter/material.dart';
import 'package:sebhua_notes/data/models/note_dtos.dart';

/// Visual style (icon + accent color) for a note attachment file type.
class NoteFileTypeStyle {
  const NoteFileTypeStyle({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

const _kWordStyle = NoteFileTypeStyle(
  icon: Icons.description,
  color: Color(0xFF2B579A),
);
const _kExcelStyle = NoteFileTypeStyle(
  icon: Icons.table_chart,
  color: Color(0xFF217346),
);
const _kPowerPointStyle = NoteFileTypeStyle(
  icon: Icons.slideshow,
  color: Color(0xFFD24726),
);
const _kPdfStyle = NoteFileTypeStyle(
  icon: Icons.picture_as_pdf,
  color: Color(0xFFE53935),
);
const _kImageStyle = NoteFileTypeStyle(
  icon: Icons.image_outlined,
  color: Color(0xFF00897B),
);
const _kAudioStyle = NoteFileTypeStyle(
  icon: Icons.audiotrack,
  color: Color(0xFF8E24AA),
);
const _kVideoStyle = NoteFileTypeStyle(
  icon: Icons.videocam_outlined,
  color: Color(0xFF5E35B1),
);
const _kArchiveStyle = NoteFileTypeStyle(
  icon: Icons.folder_zip_outlined,
  color: Color(0xFF6D4C41),
);
const _kTextStyle = NoteFileTypeStyle(
  icon: Icons.article_outlined,
  color: Color(0xFF546E7A),
);

/// Neutral gray for unrecognized attachments.
///
/// Fixed alpha-blended gray (~onSurfaceVariant @ 65%) so list cards can render
/// fallback icons without a [BuildContext].
NoteFileTypeStyle noteFileTypeStyleUnknown() {
  return _kUnknownStyle;
}

const _kUnknownStyle = NoteFileTypeStyle(
  icon: Icons.insert_drive_file_outlined,
  color: Color(0xA699A3AF),
);

/// Resolves icon/color for a single [NoteMediaItemDto].
///
/// Priority: `qiniuKey` extension → `mimeType` → `type` string → unknown.
NoteFileTypeStyle noteFileTypeStyleFromMedia(NoteMediaItemDto media) {
  final extension = _extensionFromQiniuKey(media.qiniuKey);
  if (extension != null) {
    final fromExtension = _styleForExtension(extension);
    if (fromExtension != null) return fromExtension;
  }

  final mime = media.mimeType?.toLowerCase().trim();
  if (mime != null && mime.isNotEmpty) {
    final fromMime = _styleForMime(mime);
    if (fromMime != null) return fromMime;
  }

  final type = media.type?.toUpperCase().trim();
  if (type != null && type.isNotEmpty) {
    final fromType = _styleForMediaType(type);
    if (fromType != null) return fromType;
  }

  return noteFileTypeStyleUnknown();
}

/// Maps joined [media] (one icon per file) or falls back to [mediaIds].
List<NoteFileTypeStyle> noteFileTypeStylesForList({
  required List<NoteMediaItemDto> media,
  List<String>? mediaIds,
}) {
  if (media.isNotEmpty) {
    return media.map(noteFileTypeStyleFromMedia).toList(growable: false);
  }
  if (mediaIds != null && mediaIds.isNotEmpty) {
    final unknown = noteFileTypeStyleUnknown();
    return List<NoteFileTypeStyle>.filled(mediaIds.length, unknown,
        growable: false);
  }
  return const [];
}

String? _extensionFromQiniuKey(String? qiniuKey) {
  if (qiniuKey == null || qiniuKey.isEmpty) return null;
  final fileName = qiniuKey.split('/').last;
  final dotIndex = fileName.lastIndexOf('.');
  if (dotIndex <= 0 || dotIndex == fileName.length - 1) return null;
  return fileName.substring(dotIndex + 1).toLowerCase();
}

NoteFileTypeStyle? _styleForExtension(String extension) {
  switch (extension) {
    case 'doc':
    case 'docx':
      return _kWordStyle;
    case 'xls':
    case 'xlsx':
    case 'csv':
      return _kExcelStyle;
    case 'ppt':
    case 'pptx':
      return _kPowerPointStyle;
    case 'pdf':
      return _kPdfStyle;
    case 'png':
    case 'jpg':
    case 'jpeg':
    case 'webp':
    case 'gif':
    case 'heic':
      return _kImageStyle;
    case 'mp3':
    case 'm4a':
    case 'wav':
    case 'aac':
      return _kAudioStyle;
    case 'mp4':
    case 'mov':
    case 'webm':
      return _kVideoStyle;
    case 'zip':
    case 'rar':
    case '7z':
      return _kArchiveStyle;
    case 'txt':
    case 'md':
    case 'json':
      return _kTextStyle;
    default:
      return null;
  }
}

NoteFileTypeStyle? _styleForMime(String mime) {
  if (mime.contains('word') || mime.contains('msword')) {
    return _kWordStyle;
  }
  if (mime.contains('spreadsheet') || mime.contains('excel')) {
    return _kExcelStyle;
  }
  if (mime.contains('presentation') || mime.contains('powerpoint')) {
    return _kPowerPointStyle;
  }
  if (mime.contains('application/pdf')) {
    return _kPdfStyle;
  }
  if (mime.startsWith('image/')) {
    return _kImageStyle;
  }
  if (mime.startsWith('audio/')) {
    return _kAudioStyle;
  }
  if (mime.startsWith('video/')) {
    return _kVideoStyle;
  }
  if (mime.contains('zip') || mime.contains('compressed')) {
    return _kArchiveStyle;
  }
  if (mime.startsWith('text/')) {
    return _kTextStyle;
  }
  return null;
}

NoteFileTypeStyle? _styleForMediaType(String type) {
  switch (type) {
    case 'IMAGE':
      return _kImageStyle;
    case 'VOICE':
      return _kAudioStyle;
    case 'VIDEO':
      return _kVideoStyle;
    default:
      return null;
  }
}
