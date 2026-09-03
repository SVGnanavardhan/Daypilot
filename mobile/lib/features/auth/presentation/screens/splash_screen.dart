import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../providers/auth_provider.dart';

/// Startup screen responsible for showing DayPilot branding
/// while authentication state is being restored.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _initializeAnimation();
    unawaited(_resolveStartupRoute());
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    unawaited(_animationController.forward());
  }

  Future<void> _resolveStartupRoute() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 1800),
    );

    if (!mounted) {
      return;
    }

    while (mounted) {
      final status = ref.read(authProvider).status;

      if (status != AuthStatus.initial && status != AuthStatus.loading) {
        break;
      }

      await Future<void>.delayed(
        const Duration(milliseconds: 100),
      );
    }

    if (!mounted) {
      return;
    }

    final authState = ref.read(authProvider);

    final hasSeenOnboarding = SecureStorageService.get<bool>(
          AppConstants.keyOnboardingCompleted,
        ) ??
        false;

    switch (authState.status) {
      case AuthStatus.authenticated:
        context.go('/dashboard');
        return;

      case AuthStatus.verifyingEmail:
        context.go('/email-verification');
        return;

      case AuthStatus.passwordRecovery:
        context.go('/reset-password');
        return;

      case AuthStatus.unauthenticated:
        context.go(
          hasSeenOnboarding ? '/login' : '/onboarding',
        );
        return;

      case AuthStatus.initial:
      case AuthStatus.loading:
        context.go('/login');
        return;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: 120,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppConstants.appName,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.appDescription,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary.withValues(
                              alpha: 0.8,
                            ),
                          ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
