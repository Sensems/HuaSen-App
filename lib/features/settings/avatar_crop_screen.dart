import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/ui_strings.dart';

/// Opens a full-screen circular avatar crop flow.
///
/// Returns JPEG bytes after confirmation, or `null` when the selected image is
/// discarded.
Future<Uint8List?> openAvatarCrop(
  BuildContext context,
  Uint8List sourceBytes,
) {
  return Navigator.of(context).push<Uint8List>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => AvatarCropScreen(imageBytes: sourceBytes),
    ),
  );
}

/// Lets the user pan, zoom, rotate, and export an avatar as a circular crop.
class AvatarCropScreen extends StatefulWidget {
  const AvatarCropScreen({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  static const int _maxEdge = 512;

  final _controller = CropController();
  late Uint8List _workingBytes;
  bool _exporting = false;
  bool _rotating = false;

  @override
  void initState() {
    super.initState();
    _workingBytes = widget.imageBytes;
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(UiStrings.avatarCropDiscardTitle),
        content: const Text(UiStrings.avatarCropDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(UiStrings.avatarCropDiscardKeep),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              UiStrings.avatarCropDiscardConfirm,
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _onCancel() async {
    if (_exporting) return;
    if (!await _confirmDiscard() || !mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _rotate() async {
    if (_exporting || _rotating) return;

    setState(() => _rotating = true);
    try {
      final decoded = img.decodeImage(_workingBytes);
      if (decoded == null) {
        $message.error(message: UiStrings.avatarRotateFailed);
        return;
      }

      final rotated = img.copyRotate(decoded, angle: 90);
      final encoded = Uint8List.fromList(img.encodeJpg(rotated, quality: 92));
      if (!mounted) return;

      setState(() {
        _workingBytes = encoded;
        _controller.image = encoded;
      });
    } catch (_) {
      $message.error(message: UiStrings.avatarRotateFailed);
    } finally {
      if (mounted) setState(() => _rotating = false);
    }
  }

  void _onDone() {
    if (_exporting || _rotating) return;
    setState(() => _exporting = true);
    _controller.cropCircle();
  }

  void _onCropped(CropResult result) {
    switch (result) {
      case CropSuccess(:final croppedImage):
        try {
          final avatarBytes = _toAvatarJpeg(croppedImage);
          if (!mounted) return;
          Navigator.of(context).pop(avatarBytes);
        } catch (_) {
          if (mounted) setState(() => _exporting = false);
          $message.error(message: UiStrings.avatarCropFailed);
        }
      case CropFailure():
        if (mounted) setState(() => _exporting = false);
        $message.error(message: UiStrings.avatarCropFailed);
    }
  }

  Uint8List _toAvatarJpeg(Uint8List input) {
    final decoded = img.decodeImage(input);
    if (decoded == null) {
      throw StateError('Avatar crop output could not be decoded.');
    }

    img.Image sized = decoded;
    final longestEdge = decoded.width > decoded.height
        ? decoded.width
        : decoded.height;
    if (longestEdge > _maxEdge) {
      sized = decoded.width >= decoded.height
          ? img.copyResize(decoded, width: _maxEdge)
          : img.copyResize(decoded, height: _maxEdge);
    }

    final flattened = img.Image(width: sized.width, height: sized.height);
    img.fill(flattened, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(flattened, sized);
    return Uint8List.fromList(img.encodeJpg(flattened, quality: 85));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _onCancel();
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: const Text(UiStrings.avatarCropTitle),
              leading: TextButton(
                onPressed: _exporting ? null : _onCancel,
                child: const Text(
                  UiStrings.avatarCropCancel,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: (_exporting || _rotating) ? null : _onDone,
                  child: Text(
                    UiStrings.avatarCropDone,
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: Crop(
                    image: _workingBytes,
                    controller: _controller,
                    onCropped: _onCropped,
                    withCircleUi: true,
                    interactive: true,
                    fixCropRect: true,
                    baseColor: Colors.black,
                    maskColor: Colors.black.withValues(alpha: 0.65),
                    progressIndicator: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    cornerDotBuilder: (_, _) => const SizedBox.shrink(),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: (_exporting || _rotating) ? null : _rotate,
                        icon: const Icon(Icons.rotate_90_degrees_cw),
                        label: const Text(UiStrings.avatarCropRotate),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_exporting)
            const Positioned.fill(
              child: ModalBarrier(
                dismissible: false,
                color: Color(0x66000000),
              ),
            ),
          if (_exporting) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
