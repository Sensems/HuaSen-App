import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../core/constants/ui_strings.dart';

/// Pushes a fullscreen image preview (pinch-zoom via [PhotoView]).
Future<void> openImagePreview(
  BuildContext context, {
  required String title,
  String? url,
  Uint8List? bytes,
  String? filePath,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => ImagePreviewScreen(
        title: title,
        url: url,
        bytes: bytes,
        filePath: filePath,
      ),
    ),
  );
}

/// Fullscreen black-canvas image preview.
class ImagePreviewScreen extends StatelessWidget {
  const ImagePreviewScreen({
    super.key,
    required this.title,
    this.url,
    this.bytes,
    this.filePath,
  });

  final String title;
  final String? url;
  final Uint8List? bytes;
  final String? filePath;

  ImageProvider? _resolveProvider() {
    if (bytes != null && bytes!.isNotEmpty) {
      return MemoryImage(bytes!);
    }
    final path = filePath?.trim();
    if (path != null && path.isNotEmpty) {
      return FileImage(File(path));
    }
    final remote = url?.trim();
    if (remote != null && remote.isNotEmpty) {
      return NetworkImage(remote);
    }
    return null;
  }

  Widget _buildLoading(BuildContext context, ImageChunkEvent? event) {
    final expected = event?.expectedTotalBytes;
    final loaded = event?.cumulativeBytesLoaded;
    final progress = expected != null && expected > 0 && loaded != null
        ? loaded / expected
        : null;

    return Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          value: progress,
          color: Colors.white70,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildError() {
    return const Center(
      child: Text(
        UiStrings.attachmentOpenFailed,
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = title.trim().isEmpty
        ? UiStrings.attachmentImagePreviewTitle
        : title.trim();
    final provider = _resolveProvider();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: provider == null
          ? _buildError()
          : PhotoView(
              imageProvider: provider,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 4,
              loadingBuilder: _buildLoading,
              errorBuilder: (_, _, _) => _buildError(),
              gaplessPlayback: true,
            ),
    );
  }
}
