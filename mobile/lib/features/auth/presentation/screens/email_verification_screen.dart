import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  Timer? _verificationTimer;

  bool _isResending = false;
  bool _isRefreshing = false;
  bool _isLoggingOut = false;

  bool get _isBusy => _isResending || _isRefreshing || _isLoggingOut;

  @override
  void initState() {
    super.initState();
    _startVerificationTimer();
  }

  void _startVerificationTimer() {
    _verificationTimer?.cancel();

    _verificationTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        if (!mounted || _isBusy) {
          return;
        }

        unawaited(
          _refreshVerification(
            showError: false,
          ),
        );
      },
    );
  }

  Future<void> _resendEmail() async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    await ref.read(authProvider.notifier).sendEmailVerification();

    if (!mounted) {
      return;
    }

    final authState = ref.read(authProvider);

    setState(() {
      _isResending = false;
    });

    if (authState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error!.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      ref.read(authProvider.notifier).clearError();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification email sent successfully.'),
      ),
    );
  }

  Future<void> _refreshVerification({
    bool showError = true,
  }) async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    await ref.read(authProvider.notifier).reloadUser();

    if (!mounted) {
      return;
    }

    final authState = ref.read(authProvider);

    setState(() {
      _isRefreshing = false;
    });

    if (authState.status == AuthStatus.authenticated) {
      _verificationTimer?.cancel();
      context.go('/dashboard');
      return;
    }

    if (authState.error != null) {
      if (showError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }

      ref.read(authProvider.notifier).clearError();
      return;
    }

    if (showError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email is not verified yet.'),
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    if (_isBusy) {
      return;
    }

    _verificationTimer?.cancel();

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
          content: Text(authState.error!.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      ref.read(authProvider.notifier).clearError();
      _startVerificationTimer();
      return;
    }

    context.go('/login');
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _isBusy ? null : _handleLogout,
            icon: _isLoggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0.8,
                      end: 1,
                    ),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    builder: (
                      context,
                      value,
                      child,
                    ) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Icon(
                      Icons.mark_email_read_rounded,
                      size: 100,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Verify Your Email',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a verification link to:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user?.email ?? 'Your email address',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next steps',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInstructionStep(
                            '1',
                            'Check your email inbox',
                          ),
                          _buildInstructionStep(
                            '2',
                            'Open the DayPilot verification link',
                          ),
                          _buildInstructionStep(
                            '3',
                            'Return to DayPilot',
                          ),
                          _buildInstructionStep(
                            '4',
                            'Tap "I\'ve Verified"',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _isBusy ? null : _refreshVerification,
                      icon: _isRefreshing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.refresh_rounded),
                      label: Text(
                        _isRefreshing ? 'Checking...' : "I've Verified",
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _isBusy ? null : _resendEmail,
                      icon: _isResending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_outlined),
                      label: Text(
                        _isResending ? 'Sending...' : 'Resend Email',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sync_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Verification is checked automatically every 10 seconds',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(
    String number,
    String text,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
