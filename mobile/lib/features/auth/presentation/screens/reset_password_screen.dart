import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends ConsumerState<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _passwordFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  Future<void> _updatePassword() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await ref.read(authProvider.notifier).updatePassword(
          newPassword: _passwordController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    final authState = ref.read(authProvider);

    setState(() {
      _isSubmitting = false;
    });

    if (authState.error != null) {
      _showMessage(
        authState.error!.message,
        isError: true,
      );

      ref.read(authProvider.notifier).clearError();
      return;
    }

    _passwordController.clear();
    _confirmPasswordController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password updated successfully. '
          'Please sign in with your new password.',
        ),
      ),
    );

    context.go('/login');
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
          backgroundColor: isError ? colorScheme.error : null,
        ),
      );
  }

  String? _validatePassword(String? value) {
    final password = value?.trim() ?? '';

    if (password.isEmpty) {
      return 'Please enter a new password';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp('[A-Za-z]').hasMatch(password)) {
      return 'Include at least one letter';
    }

    if (!RegExp('[0-9]').hasMatch(password)) {
      return 'Include at least one number';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value?.trim() ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (confirmPassword != _passwordController.text.trim()) {
      return 'Passwords do not match';
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
          automaticallyImplyLeading: false,
          title: const Text(
            'Create New Password',
          ),
          actions: [
            IconButton(
              tooltip: 'Back to Login',
              onPressed: _isSubmitting
                  ? null
                  : () {
                      ref
                          .read(authProvider.notifier)
                          .cancelPasswordRecovery();

                      context.go('/login');
                    },
              icon: const Icon(
                Icons.close_rounded,
              ),
            ),
          ],
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
                        'Create a new password',
                        textAlign: TextAlign.center,
                        style:
                            theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your OTP has been verified. '
                        'Enter a new password for your DayPilot account.',
                        textAlign: TextAlign.center,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(
                          color:
                              colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        enabled: !_isSubmitting,
                        obscureText: _obscurePassword,
                        textInputAction:
                            TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.newPassword,
                        ],
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          hintText:
                              'Minimum 8 characters',
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                          ),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: _isSubmitting
                                ? null
                                : () {
                                    setState(() {
                                      _obscurePassword =
                                          !_obscurePassword;
                                    });
                                  },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        validator: _validatePassword,
                        onFieldSubmitted: (_) {
                          _confirmPasswordFocusNode
                              .requestFocus();
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller:
                            _confirmPasswordController,
                        focusNode:
                            _confirmPasswordFocusNode,
                        enabled: !_isSubmitting,
                        obscureText:
                            _obscureConfirmPassword,
                        textInputAction:
                            TextInputAction.done,
                        autofillHints: const [
                          AutofillHints.newPassword,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                          ),
                          suffixIcon: IconButton(
                            tooltip:
                                _obscureConfirmPassword
                                    ? 'Show password'
                                    : 'Hide password',
                            onPressed: _isSubmitting
                                ? null
                                : () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        validator:
                            _validateConfirmPassword,
                        onFieldSubmitted: (_) {
                          if (!_isSubmitting) {
                            unawaited(
                              _updatePassword(),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 14),
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
                              'Use at least 8 characters '
                              'with one letter and one number.',
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
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : _updatePassword,
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
                                  Icons
                                      .check_circle_outline_rounded,
                                ),
                          label: Text(
                            _isSubmitting
                                ? 'Updating Password...'
                                : 'Update Password',
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                ref
                                    .read(
                                      authProvider.notifier,
                                    )
                                    .cancelPasswordRecovery();

                                context.go('/login');
                              },
                        child: const Text(
                          'Back to Login',
                        ),
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
