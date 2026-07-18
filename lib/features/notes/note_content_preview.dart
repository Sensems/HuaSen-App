import 'package:sebhua_notes/features/notes/quill_content_codec.dart';

/// Extracts readable plain text from note [content] for list-card previews.
///
/// Quill Delta JSON and legacy plain-text notes both go through
/// [decodeNoteContent]; whitespace is collapsed to single spaces.
String plainTextPreviewFromNoteContent(String? content) {
  if (content == null || content.trim().isEmpty) {
    return '';
  }
  final plain = decodeNoteContent(content).toPlainText();
  return plain.replaceAll(RegExp(r'\s+'), ' ').trim();
}
