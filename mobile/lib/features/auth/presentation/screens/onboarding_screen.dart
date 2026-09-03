import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/secure_storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _isCompleting = false;

  static const List<OnboardingItem> _items = [
    OnboardingItem(
      icon: Icons.school_rounded,
      title: 'Welcome to DayPilot',
      description:
          'Your AI-powered student operating system that helps you stay organized and productive.',
    ),
    OnboardingItem(
      icon: Icons.auto_awesome_rounded,
      title: 'AI-Powered Planning',
      description:
          'Let DayPilot intelligently organize your day around tasks, classes, deadlines, and priorities.',
    ),
    OnboardingItem(
      icon: Icons.task_alt_rounded,
      title: 'Stay Organized',
      description:
          'Manage tasks, schedules, deadlines, and reminders from one connected workspace.',
    ),
    OnboardingItem(
      icon: Icons.rocket_launch_rounded,
      title: 'Get Started',
      description:
          'Create your account and start building a smarter, more productive student routine.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    if (_currentPage == page) {
      return;
    }

    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _nextPage() async {
    if (_isCompleting) {
      return;
    }

    if (_currentPage < _items.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      return;
    }

    await _completeOnboarding(
      destination: '/register',
    );
  }

  Future<void> _skipOnboarding() async {
    await _completeOnboarding(
      destination: '/login',
    );
  }

  Future<void> _completeOnboarding({
    required String destination,
  }) async {
    if (_isCompleting) {
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    await SecureStorageService.set(
      AppConstants.keyOnboardingCompleted,
      true,
    );

    if (!mounted) {
      return;
    }

    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _isCompleting ? null : _skipOnboarding,
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    item: _items[index],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  _buildIndicator,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isCompleting ? null : _nextPage,
                  child: _isCompleting
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          _currentPage == _items.length - 1
                              ? 'Get Started'
                              : 'Next',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? colorScheme.primary
            : colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.item,
  });

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0.8,
              end: 1,
            ),
            duration: const Duration(
              milliseconds: 600,
            ),
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
              item.icon,
              size: 120,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            item.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  const OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
