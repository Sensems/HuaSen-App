/// App-wide constants for sebhua_notes.
///
/// Centralizes values that are referenced from multiple files so that
/// magic strings and numbers live in exactly one place.
class AppConstants {
  AppConstants._();

  // ── App identity ──────────────────────────────────────────────
  static const String appName = 'sebhua notes';
  static const String appVersion = '1.0.0';

  // ── Route paths ───────────────────────────────────────────────
  /// Notes list / home screen.
  static const String routeHome = '/';

  /// Note detail (read-only). `:id` is a real note UUID — never `new`.
  static const String routeNote = '/note/:id';

  /// Create note editor.
  static const String routeNoteNew = '/note/new';

  /// Edit existing note.
  static const String routeNoteEdit = '/note/:id/edit';

  /// Builds `/note/{id}/edit` for navigation pushes.
  static String noteEditPath(String id) => '/note/$id/edit';

  /// Settings screen.
  static const String routeSettings = '/settings';

  /// Account profile edit (outside shell).
  static const String routeSettingsAccount = '/settings/account';

  /// WeChat bind flow (outside shell).
  static const String routeSettingsWechatBind = '/settings/wechat-bind';

  /// WeChat drafts screen.
  static const String routeDrafts = '/drafts';

  /// Default page size for notes list.
  static const int notesPageSize = 20;

  /// Clipboard / scratch space screen.
  static const String routeClipboard = '/clipboard';

  /// Login screen.
  static const String routeLogin = '/login';

  /// Email registration screen.
  static const String routeRegister = '/register';

  /// Email reset-password screen.
  static const String routeResetPassword = '/reset-password';

  /// User agreement placeholder.
  static const String routeLegalTerms = '/legal/terms';

  /// Privacy policy placeholder.
  static const String routeLegalPrivacy = '/legal/privacy';

  // ── Storage keys ──────────────────────────────────────────────
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotes = 'notes';
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyTokenExpiresAt = 'token_expires_at';

  // ── Note editor ───────────────────────────────────────────────
  /// Sentinel `id` value that means "creating a new note".
  static const String newNoteId = 'new';

  /// Soft character limit for a single note body (advisory, not enforced
  /// at the type level).
  static const int noteBodySoftLimit = 100_000;

  // ── Networking ────────────────────────────────────────────────
  /// Base URL for the backend API.
  ///
  /// Override this at runtime (e.g. via `--dart-define`) or replace
  /// with a real endpoint before release.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://tv.sensems.top',
  );

  /// Seconds before access-token expiry to trigger proactive refresh.
  static const int tokenRefreshSkewSeconds = 60;

  /// Default timeout for network operations (seconds).
  static const int apiTimeoutSeconds = 30;

  /// Polling interval for draft watch while the app process is alive.
  static const int draftsWatchIntervalSeconds = 30;

  /// Android notification channel id for draft updates.
  static const String draftsNotificationChannelId = 'drafts_updates';
}
