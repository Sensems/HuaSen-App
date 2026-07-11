/// Abstract interface for persisting and retrieving JWT tokens.
///
/// A concrete [SharedPreferencesTokenStorage] implementation exists in
/// `shared_preferences_token_storage.dart`. This interface lives in the core
/// layer so that interceptors can depend on it without knowing the storage
/// backend.
abstract interface class TokenStorage {
  /// Returns the current access token, or `null` if none is stored.
  Future<String?> getToken();

  /// Persists the access token.
  Future<void> setToken(String token);

  /// Clears the access token, refresh token, and expiry timestamp.
  Future<void> clearToken();

  /// Returns the current refresh token, or `null` if none is stored.
  Future<String?> getRefreshToken();

  /// Persists the refresh token.
  Future<void> setRefreshToken(String token);

  /// Returns the token expiry as epoch milliseconds, or `null` if unset.
  Future<int?> getExpiresAt();

  /// Persists the token expiry as epoch milliseconds.
  Future<void> setExpiresAt(int epochMs);
}
