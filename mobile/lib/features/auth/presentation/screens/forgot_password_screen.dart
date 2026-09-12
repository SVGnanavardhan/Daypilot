import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController =
      TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _emailFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    final success =
        await ref.read(authProvider.notifier).sendPasswordResetOtp(
              email: email,
            );

    if (!mounted) {
      return;
    }

    final authState = ref.read(authProvider);

    setState(() {
      _isSubmitting = false;
    });

    if (!success || authState.error != null) {
      _showMessage(
        authState.error?.message ??
            'Unable to send password reset OTP. Please try again.',
        isError: true,
      );

      ref.read(authProvider.notifier).clearError();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '8-digit password reset OTP sent to your email.',
        ),
      ),
    );

    unawaited(
      context.push(
        '/verify-reset-otp',
        extra: email,
      ),
    );
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? colorScheme.error : null,
        ),
      );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Forgot Password',
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.lock_reset_rounded,
                        size: 88,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Forgot your password?',
                        textAlign: TextAlign.center,
                        style:
                            theme.textTheme.headlineSmall
                                ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Enter your registered email address. '
                        'We will send you an 8-digit OTP to reset your password.',
                        textAlign: TextAlign.center,
                        style:
                            theme.textTheme.bodyMedium
                                ?.copyWith(
                          color:
                              colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        enabled: !_isSubmitting,
                        keyboardType:
                            TextInputType.emailAddress,
                        textInputAction:
                            TextInputAction.done,
                        autofillHints: const [
                          AutofillHints.email,
                        ],
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText:
                              'Enter your registered email',
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        validator: _validateEmail,
                        onFieldSubmitted: (_) {
                          if (!_isSubmitting) {
                            unawaited(
                              _handleResetPassword(),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : _handleResetPassword,
                          icon: _isSubmitting
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                ),
                          label: Text(
                            _isSubmitting
                                ? 'Sending OTP...'
                                : 'Send OTP',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/login');
                                }
                              },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          'Back to Login',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 17,
                            color: colorScheme
                                .onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Use the email address registered with your '
                              'DayPilot account.',
                              style: theme
                                  .textTheme.bodySmall
                                  ?.copyWith(
                                color: colorScheme
                                    .onSurfaceVariant,
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
        ),
      ),
    );
  }
}
