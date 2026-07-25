import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/constants/ui_strings.dart';

/// Pushes a fullscreen image preview (pinch-zoom via [InteractiveViewer]).
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
      body: Center(
        child: provider == null
            ? const Text(
                UiStrings.attachmentOpenFailed,
                style: TextStyle(color: Colors.white70),
              )
            : InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image(
                  image: provider,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Text(
                    UiStrings.attachmentOpenFailed,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
      ),
    );
  }
}
