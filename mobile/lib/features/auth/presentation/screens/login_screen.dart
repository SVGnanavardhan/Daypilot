import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const String _rememberedEmailKey = 'remembered_email';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  String? _loginError;

  @override
  void initState() {
    super.initState();
    unawaited(_loadRememberedEmail());
  }

  Future<void> _loadRememberedEmail() async {
    final email = await SecureStorageService.getSecure(
      _rememberedEmailKey,
    );

    if (!mounted || email == null || email.isEmpty) {
      return;
    }

    _emailController.text = email;

    setState(() {
      _rememberMe = true;
    });
  }

  Future<void> _saveRememberedEmail() async {
    if (_rememberMe) {
      await SecureStorageService.setSecure(
        _rememberedEmailKey,
        _emailController.text.trim(),
      );
    } else {
      await SecureStorageService.deleteSecure(
        _rememberedEmailKey,
      );
    }
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _loginError = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await _saveRememberedEmail();

    final failure = await ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    if (failure != null) {
      setState(() {
        _loginError = 'Incorrect email or password.';
      });

      ref.read(authProvider.notifier).clearError();

      return;
    }

    final authState = ref.read(authProvider);

    switch (authState.status) {
      case AuthStatus.authenticated:
        context.go('/dashboard');
        break;

      case AuthStatus.verifyingEmail:
        context.go('/email-verification');
        break;

      case AuthStatus.passwordRecovery:
        context.go('/reset-password');
        break;

      case AuthStatus.initial:
      case AuthStatus.loading:
      case AuthStatus.unauthenticated:
        setState(() {
          _loginError = 'Incorrect email or password.';
        });
        break;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: 80,
                      color: colorScheme.primary,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to continue to DayPilot',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 48),

                    TextFormField(
                      controller: _emailController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.email,
                      ],
                      onChanged: (_) {
                        if (_loginError != null) {
                          setState(() {
                            _loginError = null;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                      ),
                      validator: (value) {
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
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      enabled: !isLoading,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [
                        AutofillHints.password,
                      ],
                      onChanged: (_) {
                        if (_loginError != null) {
                          setState(() {
                            _loginError = null;
                          });
                        }
                      },
                      onFieldSubmitted: (_) {
                        if (!isLoading) {
                          unawaited(
                            _handleLogin(),
                          );
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(
                          Icons.lock_outlined,
                        ),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _obscurePassword =
                                        !_obscurePassword;
                                  });
                                },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                        ),

                        const Text(
                          'Remember me',
                        ),

                        const Spacer(),

                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  unawaited(
                                    context.push(
                                      '/forgot-password',
                                    ),
                                  );
                                },
                          child: const Text(
                            'Forgot Password?',
                          ),
                        ),
                      ],
                    ),

                    if (_loginError != null) ...[
                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 20,
                              color: colorScheme.error,
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                _loginError!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: isLoading
                            ? null
                            : _handleLogin,
                        child: isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Text(
                                'Login',
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        const Expanded(
                          child: Divider(),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: Text(
                            'or',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),

                        const Expanded(
                          child: Divider(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                        ),

                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  unawaited(
                                    context.push(
                                      '/register',
                                    ),
                                  );
                                },
                          child: const Text(
                            'Register',
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
    );
  }
}
