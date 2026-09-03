import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/providers.dart';
import '../../../core/sync/sync_service.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSyncing = false;
  bool _isLoggingOut = false;

  bool get _isBusy => _isSyncing || _isLoggingOut;

  Future<void> _syncNow() async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      await ref.read(syncServiceProvider).syncNow();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sync completed.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sync failed: $error',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    await ref.read(authProvider.notifier).logout();

    if (!mounted) {
      return;
    }

    final authState = ref.read(authProvider);

    if (authState.error != null) {
      setState(() {
        _isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authState.error!.message,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      ref.read(authProvider.notifier).clearError();

      return;
    }

    context.go('/login');
  }

  void _showThemeSheet() {
    final currentTheme = ref.read(
      appThemeModeProvider,
    );

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    title: Text(
                      'Choose Appearance',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  RadioGroup<ThemeDataMode>(
                    groupValue: currentTheme,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      ref
                          .read(
                            appThemeModeProvider.notifier,
                          )
                          .setThemeMode(value);

                      Navigator.of(sheetContext).pop();
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<ThemeDataMode>(
                          value: ThemeDataMode.system,
                          title: Text('System'),
                          secondary: Icon(
                            Icons.settings_suggest_outlined,
                          ),
                        ),
                        RadioListTile<ThemeDataMode>(
                          value: ThemeDataMode.light,
                          title: Text('Light'),
                          secondary: Icon(
                            Icons.light_mode_outlined,
                          ),
                        ),
                        RadioListTile<ThemeDataMode>(
                          value: ThemeDataMode.dark,
                          title: Text('Dark'),
                          secondary: Icon(
                            Icons.dark_mode_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _themeLabel(
    ThemeDataMode mode,
  ) {
    switch (mode) {
      case ThemeDataMode.light:
        return 'Light';

      case ThemeDataMode.dark:
        return 'Dark';

      case ThemeDataMode.system:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(
      appThemeModeProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        children: [
          ListTile(
            leading: const Icon(
              Icons.person_outline_rounded,
            ),
            title: const Text(
              'Student Profile',
            ),
            subtitle: const Text(
              'Academic details and daily routine',
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
            onTap: _isBusy
                ? null
                : () {
                    unawaited(
                      context.push('/profile'),
                    );
                  },
          ),
          ListTile(
            leading: const Icon(
              Icons.notifications_outlined,
            ),
            title: const Text(
              'Notifications',
            ),
            subtitle: const Text(
              'Manage reminders and alerts',
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
            onTap: _isBusy
                ? null
                : () {
                    unawaited(
                      context.push('/notifications'),
                    );
                  },
          ),
          ListTile(
            leading: const Icon(
              Icons.palette_outlined,
            ),
            title: const Text(
              'Appearance',
            ),
            subtitle: Text(
              _themeLabel(themeMode),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
            onTap: _isBusy ? null : _showThemeSheet,
          ),
          const Divider(),
          ListTile(
            leading: _isSyncing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.sync_rounded,
                  ),
            title: const Text(
              'Sync Now',
            ),
            subtitle: Text(
              _isSyncing
                  ? 'Synchronizing DayPilot data...'
                  : 'Synchronize local and cloud data',
            ),
            onTap: _isBusy ? null : _syncNow,
          ),
          const Divider(),
          ListTile(
            leading: _isLoggingOut
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    Icons.logout_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
            title: Text(
              _isLoggingOut ? 'Logging out...' : 'Logout',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            onTap: _isBusy ? null : _logout,
          ),
        ],
      ),
    );
  }
}
