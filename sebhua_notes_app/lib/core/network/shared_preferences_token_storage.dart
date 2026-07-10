import 'package:sebhua_notes/core/constants/app_constants.dart';
import 'package:sebhua_notes/core/network/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [TokenStorage] backed by [SharedPreferences].
class SharedPreferencesTokenStorage implements TokenStorage {
  SharedPreferencesTokenStorage(this._prefs);

  final SharedPreferences _prefs;

  /// Computes expiry epoch ms from a relative `expiresIn` (seconds).
  static int expiresAtFromExpiresIn(int expiresInSeconds) =>
      DateTime.now().millisecondsSinceEpoch + expiresInSeconds * 1000;

  @override
  Future<String?> getToken() async =>
      _prefs.getString(AppConstants.keyAccessToken);

  @override
  Future<void> setToken(String token) async {
    await _prefs.setString(AppConstants.keyAccessToken, token);
  }

  @override
  Future<String?> getRefreshToken() async =>
      _prefs.getString(AppConstants.keyRefreshToken);

  @override
  Future<void> setRefreshToken(String token) async {
    await _prefs.setString(AppConstants.keyRefreshToken, token);
  }

  @override
  Future<int?> getExpiresAt() async =>
      _prefs.getInt(AppConstants.keyTokenExpiresAt);

  @override
  Future<void> setExpiresAt(int epochMs) async {
    await _prefs.setInt(AppConstants.keyTokenExpiresAt, epochMs);
  }

  @override
  Future<void> clearToken() async {
    await _prefs.remove(AppConstants.keyAccessToken);
    await _prefs.remove(AppConstants.keyRefreshToken);
    await _prefs.remove(AppConstants.keyTokenExpiresAt);
  }
}
