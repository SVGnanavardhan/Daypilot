import 'package:daypilot/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-publishable-key',
    );
  });

  testWidgets('DayPilot app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DayPilotApp(),
      ),
    );

    // Verify that the main Flutter app builds successfully.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Splash screen intentionally waits about 1.8 seconds.
    // Advance the fake test clock so the startup timer completes.
    await tester.pump(const Duration(seconds: 2));

    // Process any frame triggered after the splash timer completes.
    await tester.pump();
  });
}
