import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sebhua_notes/app.dart';
import 'package:sebhua_notes/core/constants/app_constants.dart';
import 'package:sebhua_notes/core/providers/core_providers.dart';
import 'package:sebhua_notes/features/auth/auth_notifier.dart';
import 'package:sebhua_notes/features/auth/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('auth state is seeded from persisted access token', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.keyAccessToken: 'stored-access',
      AppConstants.keyTokenExpiresAt:
          DateTime.now().millisecondsSinceEpoch + 120000,
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(
      container.read(authNotifierProvider).status,
      AuthStatus.authenticated,
    );
  });

  test('auth state is seeded as unauthenticated without access token', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(
      container.read(authNotifierProvider).status,
      AuthStatus.unauthenticated,
    );
  });

  testWidgets('Unauthenticated app redirects to login', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SebhuaNotesApp(),
      ),
    );

    expect(find.text('花森'), findsOneWidget);
  });
}
