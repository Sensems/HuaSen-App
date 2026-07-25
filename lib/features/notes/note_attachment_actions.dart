import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/ui_strings.dart';
import 'image_preview_screen.dart';

/// Attachment source for open / download actions.
class NoteAttachmentRef {
  const NoteAttachmentRef({
    required this.name,
    this.extension,
    this.url,
    this.localPath,
    this.bytes,
    this.mimeType,
    this.mediaType,
  });

  final String name;
  final String? extension;
  final String? url;
  final String? localPath;
  final List<int>? bytes;
  final String? mimeType;
  final String? mediaType; // e.g. IMAGE
}

/// Open / download helpers for note attachments.
class NoteAttachmentActions {
  NoteAttachmentActions._();

  /// Matches [note_file_type_style] image extensions (png/jpg/jpeg/webp/gif/heic).
  static const _kImageExtensions = {
    'png',
    'jpg',
    'jpeg',
    'webp',
    'gif',
    'heic',
  };

  /// Image if extension / mime / mediaType matches note_file_type_style rules.
  static bool isImage(NoteAttachmentRef ref) {
    final ext = _resolvedExtension(ref);
    if (ext != null && _kImageExtensions.contains(ext)) return true;

    final mime = ref.mimeType?.toLowerCase().trim();
    if (mime != null && mime.startsWith('image/')) return true;

    if (ref.mediaType?.toUpperCase().trim() == 'IMAGE') return true;

    return false;
  }

  /// Open: image → preview route; else ensure local file → [OpenFilex.open].
  static Future<void> open(BuildContext context, NoteAttachmentRef ref) async {
    if (isImage(ref)) {
      await openImagePreview(
        context,
        title: ref.name,
        url: ref.url,
        bytes: ref.bytes == null ? null : Uint8List.fromList(ref.bytes!),
        filePath: ref.localPath,
      );
      return;
    }

    $message.info(message: UiStrings.attachmentOpening);
    try {
      final file = await _ensureLocalFile(ref);
      if (file == null) {
        $message.error(message: UiStrings.attachmentSourceMissing);
        return;
      }
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        $message.error(
          message: result.message.isNotEmpty
              ? result.message
              : UiStrings.attachmentOpenFailed,
        );
      }
    } catch (_) {
      $message.error(message: UiStrings.attachmentOpenFailed);
    }
  }

  /// Download into Downloads (or fallback dir); toast success/failure.
  static Future<void> download(
    BuildContext context,
    NoteAttachmentRef ref,
  ) async {
    try {
      final src = await _ensureLocalFile(ref);
      if (src == null) {
        $message.error(message: UiStrings.attachmentSourceMissing);
        return;
      }
      final dir = await _resolveDownloadDirectory();
      var target = File('${dir.path}/${_safeFileName(ref.name)}');
      if (await target.exists()) {
        target = File('${dir.path}/${_uniqueDownloadName(ref.name)}');
      }
      await src.copy(target.path);
      $message.success(message: UiStrings.attachmentDownloadSuccess);
    } catch (_) {
      $message.error(message: UiStrings.attachmentDownloadFailed);
    }
  }

  static Future<Directory> _resolveDownloadDirectory() async {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) return downloads;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/Downloads');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Prefer localPath → bytes → url (independent [Dio] download).
  static Future<File?> _ensureLocalFile(NoteAttachmentRef ref) async {
    if (ref.localPath != null) {
      final f = File(ref.localPath!);
      if (await f.exists()) return f;
    }

    final tmpRoot = await getTemporaryDirectory();
    final dir = Directory('${tmpRoot.path}/note_attachments');
    await dir.create(recursive: true);
    final out = File('${dir.path}/${_safeFileName(ref.name)}');

    if (ref.bytes != null) {
      await out.writeAsBytes(ref.bytes!, flush: true);
      return out;
    }

    final url = ref.url?.trim();
    if (url == null || url.isEmpty) return null;

    final dio = Dio();
    try {
      await dio.download(url, out.path);
      return out;
    } catch (_) {
      return null;
    } finally {
      dio.close();
    }
  }

  static String _safeFileName(String name) =>
      name.replaceAll(RegExp(r'[\\/]'), '_');

  /// `name_yyyyMMdd_HHmmss.ext` when the target already exists.
  static String _uniqueDownloadName(String name) {
    final safe = _safeFileName(name);
    final now = DateTime.now();
    final stamp =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';

    final dot = safe.lastIndexOf('.');
    if (dot <= 0 || dot == safe.length - 1) {
      return '${safe}_$stamp';
    }
    return '${safe.substring(0, dot)}_$stamp${safe.substring(dot)}';
  }

  static String? _resolvedExtension(NoteAttachmentRef ref) {
    final fromField = _normalizeExtension(ref.extension);
    if (fromField != null) return fromField;

    final name = ref.name.trim();
    final dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) return null;
    return _normalizeExtension(name.substring(dot + 1));
  }

  static String? _normalizeExtension(String? value) {
    if (value == null) return null;
    var ext = value.trim().toLowerCase();
    if (ext.startsWith('.')) ext = ext.substring(1);
    if (ext.isEmpty) return null;
    return ext;
  }
}
