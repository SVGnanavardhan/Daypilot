import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class VerifyResetOtpScreen extends ConsumerStatefulWidget {
  const VerifyResetOtpScreen({
    required this.email,
    super.key,
  });

  final String email;

  @override
  ConsumerState<VerifyResetOtpScreen> createState() =>
      _VerifyResetOtpScreenState();
}

class _VerifyResetOtpScreenState
    extends ConsumerState<VerifyResetOtpScreen> {
  static const int _otpLength = 8;

  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  bool _isVerifying = false;
  bool _isResending = false;

  bool get _isBusy => _isVerifying || _isResending;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_isBusy) {
      return;
    }

    final otp = _otpController.text.trim();
    final email = widget.email.trim();

    if (email.isEmpty) {
      _showMessage(
        'Recovery email is unavailable. Start again.',
        isError: true,
      );
      return;
    }

    if (otp.isEmpty) {
      _showMessage(
        'Please enter the OTP.',
        isError: true,
      );

      _otpFocusNode.requestFocus();
      return;
    }

    if (otp.length != _otpLength) {
      _showMessage(
        'Please enter the $_otpLength-digit OTP.',
        isError: true,
      );

      _otpFocusNode.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isVerifying = true;
    });

    final success =
        await ref.read(authProvider.notifier).verifyPasswordResetOtp(
              email: email,
              otp: otp,
            );

    if (!mounted) {
      return;
    }

    final authState = ref.read(authProvider);

    setState(() {
      _isVerifying = false;
    });

    if (!success || authState.error != null) {
      _showMessage(
        authState.error?.message ??
            'Unable to verify OTP. Please try again.',
        isError: true,
      );

      ref.read(authProvider.notifier).clearError();

      _otpController.clear();
      _otpFocusNode.requestFocus();
      return;
    }

    if (authState.status != AuthStatus.passwordRecovery) {
      _showMessage(
        'Unable to start password recovery. Please try again.',
        isError: true,
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'OTP verified successfully.',
        ),
      ),
    );

    context.go('/reset-password');
  }

  Future<void> _resendOtp() async {
    if (_isBusy) {
      return;
    }

    final email = widget.email.trim();

    if (email.isEmpty) {
      _showMessage(
        'Recovery email is unavailable. Start again.',
        isError: true,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isResending = true;
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
      _isResending = false;
    });

    if (!success || authState.error != null) {
      _showMessage(
        authState.error?.message ??
            'Unable to resend OTP. Please try again.',
        isError: true,
      );

      ref.read(authProvider.notifier).clearError();
      return;
    }

    _otpController.clear();
    _otpFocusNode.requestFocus();

    _showMessage(
      'A new $_otpLength-digit OTP has been sent to your email.',
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

  String _maskEmail(String email) {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty ||
        !trimmedEmail.contains('@')) {
      return trimmedEmail;
    }

    final parts = trimmedEmail.split('@');

    if (parts.length != 2) {
      return trimmedEmail;
    }

    final username = parts.first;
    final domain = parts.last;

    if (username.isEmpty) {
      return trimmedEmail;
    }

    if (username.length == 1) {
      return '${username[0]}***@$domain';
    }

    if (username.length == 2) {
      return '${username[0]}***${username[1]}@$domain';
    }

    return '${username.substring(0, 2)}***@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final email = widget.email.trim();

    return PopScope(
      canPop: !_isBusy,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Verify Reset OTP',
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
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.password_rounded,
                      size: 88,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Verify OTP',
                      textAlign: TextAlign.center,
                      style:
                          theme.textTheme.headlineSmall
                              ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter the $_otpLength-digit OTP sent to your registered email address.',
                      textAlign: TextAlign.center,
                      style:
                          theme.textTheme.bodyMedium
                              ?.copyWith(
                        color:
                            colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme
                              .surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _maskEmail(email),
                                textAlign:
                                    TextAlign.center,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: theme
                                    .textTheme.bodyLarge
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    TextField(
                      controller: _otpController,
                      focusNode: _otpFocusNode,
                      enabled: !_isBusy,
                      keyboardType:
                          TextInputType.number,
                      textInputAction:
                          TextInputAction.done,
                      textAlign: TextAlign.center,
                      maxLength: _otpLength,
                      autofillHints: const [
                        AutofillHints.oneTimeCode,
                      ],
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly,
                        LengthLimitingTextInputFormatter(
                          _otpLength,
                        ),
                      ],
                      style: theme
                          .textTheme.headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: 'OTP',
                        hintText: '00000000',
                        prefixIcon: const Icon(
                          Icons.pin_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      onSubmitted: (_) {
                        if (!_isBusy) {
                          unawaited(
                            _verifyOtp(),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed:
                            _isBusy ? null : _verifyOtp,
                        icon: _isVerifying
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
                                Icons.verified_rounded,
                              ),
                        label: Text(
                          _isVerifying
                              ? 'Verifying...'
                              : 'Verify OTP',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed:
                            _isBusy ? null : _resendOtp,
                        icon: _isResending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                              ),
                        label: Text(
                          _isResending
                              ? 'Sending...'
                              : 'Resend OTP',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _isBusy
                          ? null
                          : () {
                              ref
                                  .read(
                                    authProvider.notifier,
                                  )
                                  .cancelPasswordRecovery();

                              context.go(
                                '/forgot-password',
                              );
                            },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        'Change Email',
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
