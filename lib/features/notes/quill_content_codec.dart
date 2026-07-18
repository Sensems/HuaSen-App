import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart' as quill;

/// Serializes / deserializes note `content` for the API.
///
/// Wire format is Quill Delta JSON (`jsonEncode(document.toDelta().toJson())`).
/// Older plain-text notes fall back to a single-paragraph document.
String encodeQuillDocument(quill.Document document) {
  return jsonEncode(document.toDelta().toJson());
}

quill.Document decodeNoteContent(String? content) {
  final raw = content?.trim() ?? '';
  if (raw.isEmpty) {
    return quill.Document();
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return quill.Document.fromJson(decoded);
    }
  } on Object {
    // Fall through to plain text.
  }
  return quill.Document()..insert(0, raw);
}
