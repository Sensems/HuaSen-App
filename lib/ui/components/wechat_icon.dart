import 'package:flutter/material.dart';

/// Official WeChat brand icon used across settings and bind flows.
class WechatIcon extends StatelessWidget {
  const WechatIcon({
    super.key,
    this.size = 24,
    this.borderRadius,
  });

  static const assetPath = 'assets/images/wechat_icon.png';

  final double size;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: image,
    );
  }
}
