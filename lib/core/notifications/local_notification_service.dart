import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/app_constants.dart';
import '../constants/ui_strings.dart';

/// Thin wrapper around [FlutterLocalNotificationsPlugin].
///
/// Web: all methods are no-ops. Desktop/mobile: system notifications.
class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;
  void Function(String? payload)? _onSelect;

  /// Updates the callback invoked when the user taps a notification.
  void setOnSelect(void Function(String? payload)? onSelect) {
    _onSelect = onSelect;
  }

  Future<void> initialize({void Function(String? payload)? onSelect}) async {
    _onSelect = onSelect;
    if (kIsWeb) {
      _ready = true;
      return;
    }

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings();
      const linuxInit = LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );
      const windowsInit = WindowsInitializationSettings(
        appName: AppConstants.appName,
        appUserModelId: 'Sensems.SebhuaNotes',
        guid: 'a8f3c2e1-4b5d-6e7f-8091-a2b3c4d5e6f7',
      );
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
        linux: linuxInit,
        windows: windowsInit,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          _onSelect?.call(response.payload);
        },
      );

      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          AppConstants.draftsNotificationChannelId,
          UiStrings.draftsNotificationChannelName,
          description: UiStrings.draftsNotificationChannelDescription,
          importance: Importance.defaultImportance,
        ),
      );

      _ready = true;
    } on Object {
      // Linux or other unsupported platforms: treat as no-op.
      _ready = false;
    }
  }

  /// Payload from a notification that launched a terminated app, if any.
  Future<String?> pendingLaunchPayload() async {
    if (kIsWeb || !_ready) return null;

    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details == null ||
          !details.didNotificationLaunchApp ||
          details.notificationResponse == null) {
        return null;
      }
      return details.notificationResponse!.payload;
    } on Object {
      return null;
    }
  }

  Future<void> requestPermission() async {
    if (kIsWeb || !_ready) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    final mac = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    await mac?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showDraftsUpdate({
    required String body,
    String? payload,
  }) async {
    if (kIsWeb || !_ready) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.draftsNotificationChannelId,
        UiStrings.draftsNotificationChannelName,
        channelDescription: UiStrings.draftsNotificationChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
      windows: WindowsNotificationDetails(),
    );

    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        UiStrings.draftsNotificationTitle,
        body,
        details,
        payload: payload ?? AppConstants.routeDrafts,
      );
    } on Object {
      // Spec: silent on show failure.
    }
  }
}
