import 'package:flutter_test/flutter_test.dart';
import 'package:sebhua_notes/core/network/shared_preferences_token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists and clears access, refresh, expiresAt', () async {
    final prefs = await SharedPreferences.getInstance();
    final storage = SharedPreferencesTokenStorage(prefs);

    await storage.setToken('a');
    await storage.setRefreshToken('r');
    await storage.setExpiresAt(1_700_000_000_000);

    expect(await storage.getToken(), 'a');
    expect(await storage.getRefreshToken(), 'r');
    expect(await storage.getExpiresAt(), 1_700_000_000_000);

    await storage.clearToken();
    expect(await storage.getToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
    expect(await storage.getExpiresAt(), isNull);
  });
}
