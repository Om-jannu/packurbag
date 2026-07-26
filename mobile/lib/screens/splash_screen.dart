import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _minDurationElapsed = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _minDurationElapsed = true;
      _maybeNavigate();
    });
  }

  void _maybeNavigate() {
    if (_navigated || !_minDurationElapsed) return;
    final auth = ref.read(authProvider);
    if (auth.isLoading) return;
    _navigated = true;
    context.go(auth.value != null ? '/home' : '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      _maybeNavigate();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeNavigate());

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0, 0.6, curve: Curves.easeIn),
                ),
                child: Image.asset(
                  'assets/packurbag-logo.png',
                  height: 160,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Packurbag',
              style: AppTextStyles.display(color: AppTheme.textPrimary(context)),
            ),
          ],
        ),
      ),
    );
  }
}
