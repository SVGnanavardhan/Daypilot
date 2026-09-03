import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_router.dart';
import 'core/config/providers.dart';
import 'core/config/supabase_config.dart';
import 'core/constants/app_constants.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local preferences before the application starts.
  await SecureStorageService.init();

  // Initialize the primary DayPilot backend.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  // Initialize local notification handling.
  await NotificationService.instance.initialize();

  runApp(
    const ProviderScope(
      child: DayPilotApp(),
    ),
  );
}

class DayPilotApp extends ConsumerWidget {
  const DayPilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _resolveThemeMode(themeMode),
      locale: locale,
      supportedLocales: const [
        Locale('en'),
      ],
    );
  }

  ThemeMode _resolveThemeMode(ThemeDataMode mode) {
    switch (mode) {
      case ThemeDataMode.light:
        return ThemeMode.light;

      case ThemeDataMode.dark:
        return ThemeMode.dark;

      case ThemeDataMode.system:
        return ThemeMode.system;
    }
  }
}
