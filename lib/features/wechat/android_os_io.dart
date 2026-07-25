import 'dart:io' show Platform;

/// Whether the host OS is Android.
///
/// Prefer this over [defaultTargetPlatform]: widget tests default the latter
/// to Android even when the host is Windows/Linux/macOS.
bool get isAndroidOperatingSystem => Platform.isAndroid;
