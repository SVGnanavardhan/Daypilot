import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/verify_reset_otp_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/planner/presentation/planner_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/schedule/presentation/schedule_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';

part 'app_router.g.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshNotifier = _RouterRefreshNotifier();

  ref
    ..listen<AuthState>(
      authProvider,
      (previous, next) {
        refreshNotifier.refresh();
      },
    )
    ..onDispose(
      refreshNotifier.dispose,
    );

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    errorBuilder: (context, state) {
      return _RouterErrorScreen(
        error: state.error,
      );
    },
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      final location = state.matchedLocation;

      final isAuthenticated =
          authState.status == AuthStatus.authenticated;

      final isVerifyingEmail =
          authState.status == AuthStatus.verifyingEmail;

      final isPasswordRecovery =
          authState.status == AuthStatus.passwordRecovery;

      const publicRoutes = <String>{
        '/splash',
        '/onboarding',
        '/login',
        '/register',
        '/forgot-password',
        '/verify-reset-otp',
        '/reset-password',
      };

      const protectedRoutes = <String>{
        '/dashboard',
        '/schedule',
        '/tasks',
        '/planner',
        '/profile',
        '/settings',
        '/notifications',
      };

      final isPublicRoute = publicRoutes.contains(location);

      final isProtectedRoute = protectedRoutes.any(
        location.startsWith,
      );

      final isEmailVerificationRoute =
          location == '/email-verification';

      final isResetOtpRoute =
          location == '/verify-reset-otp';

      final isResetPasswordRoute =
          location == '/reset-password';

      /*
       * Password recovery:
       *
       * Once the recovery OTP has been verified, AuthProvider enters
       * passwordRecovery state. At that point the user is only allowed
       * to continue to the create-new-password screen.
       */
      if (isPasswordRecovery && !isResetPasswordRoute) {
        return '/reset-password';
      }

      /*
       * New registrations waiting for email OTP verification must remain
       * inside the email verification flow.
       */
      if (isVerifyingEmail && !isEmailVerificationRoute) {
        return '/email-verification';
      }

      /*
       * Unauthenticated users cannot open application screens.
       */
      if (!isAuthenticated &&
          !isVerifyingEmail &&
          !isPasswordRecovery &&
          isProtectedRoute) {
        return '/login';
      }

      /*
       * Authenticated users should not return to login, registration,
       * forgot-password or reset OTP screens.
       */
      if (isAuthenticated &&
          isPublicRoute &&
          location != '/splash' &&
          location != '/reset-password') {
        return '/dashboard';
      }

      /*
       * A fully authenticated user no longer needs email verification.
       */
      if (isAuthenticated && isEmailVerificationRoute) {
        return '/dashboard';
      }

      /*
       * Keep the OTP route accessible while the user is still
       * unauthenticated and waiting to verify the password-reset OTP.
       */
      if (!isAuthenticated &&
          !isPasswordRecovery &&
          isResetOtpRoute) {
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) {
          return const OnboardingScreen();
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) {
          return const ForgotPasswordScreen();
        },
      ),
      GoRoute(
        path: '/verify-reset-otp',
        name: 'verify-reset-otp',
        builder: (context, state) {
          final extra = state.extra;

          final email = extra is String
              ? extra.trim()
              : '';

          if (email.isEmpty) {
            return const _MissingResetEmailScreen();
          }

          return VerifyResetOtpScreen(
            email: email,
          );
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          return const ResetPasswordScreen();
        },
      ),
      GoRoute(
        path: '/email-verification',
        name: 'email-verification',
        builder: (context, state) {
          return const EmailVerificationScreen();
        },
      ),
      GoRoute(
        path: '/planner',
        name: 'planner',
        builder: (context, state) {
          return const PlannerScreen();
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) {
          return const ProfileScreen();
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) {
          return const SettingsScreen();
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) {
          return const NotificationsScreen();
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          context,
          state,
          navigationShell,
        ) {
          return MainScaffold(
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) {
                  return const DashboardScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/schedule',
                name: 'schedule',
                builder: (context, state) {
                  return const ScheduleScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                name: 'tasks',
                builder: (context, state) {
                  return const TasksScreen();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation:
                index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            selectedIcon: Icon(
              Icons.dashboard,
            ),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.calendar_month_outlined,
            ),
            selectedIcon: Icon(
              Icons.calendar_month,
            ),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.task_outlined,
            ),
            selectedIcon: Icon(
              Icons.task,
            ),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }
}

class _MissingResetEmailScreen extends StatelessWidget {
  const _MissingResetEmailScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reset Password',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 72,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Email address missing',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Start the password reset process again so we know where to send your OTP.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    context.go('/forgot-password');
                  },
                  icon: const Icon(
                    Icons.restart_alt_rounded,
                  ),
                  label: const Text(
                    'Start Again',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RouterErrorScreen extends StatelessWidget {
  const _RouterErrorScreen({
    this.error,
  });

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Navigation Error',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ??
                    'The requested screen could not be opened.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text(
                  'Return to Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
