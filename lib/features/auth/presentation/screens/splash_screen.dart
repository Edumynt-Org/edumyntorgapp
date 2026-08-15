import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:math' as math;

import '../../../../core/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<Offset> _edumyntSlideAnimation;
  late Animation<Offset> _librarySlideAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // 3 seconds total animation
    );

    // Circle Reveal (0% to 40% -> 1.2s)
    _radiusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOutCubic),
      ),
    );

    // EDUMYNT slides from left (40% to 80% -> 1.2s)
    _edumyntSlideAnimation =
        Tween<Offset>(begin: const Offset(-1.5, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    // LIBRARY slides from right (40% to 80% -> 1.2s)
    _librarySlideAnimation =
        Tween<Offset>(begin: const Offset(1.5, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    // Text fades in (40% to 80%)
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _runSplashSequence();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runSplashSequence() async {
    // 1. Play the entire animation forward (3 seconds)
    await _controller.forward();

    // 2. Keep the completed logo on screen for some moments (1.5 seconds)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final authRepo = ref.read(authRepositoryProvider);
    if (authRepo.isAuthenticated) {
      context.go('/home');
    } else {
      final prefs = ref.read(sharedPreferencesProvider);
      final skippedLogin = prefs.getBool('skipped_login') ?? false;
      if (skippedLogin) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Calculate the maximum radius needed to cover the screen from the center.
    final maxRadius = math.sqrt(
      math.pow(size.width / 2, 2) + math.pow(size.height / 2, 2),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final currentRadius = _radiusAnimation.value * maxRadius;
          return Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: _CircleRevealPainter(
                  radius: currentRadius,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (_controller.value >= 0.5)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SlideTransition(
                        position: _edumyntSlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Text(
                            'EDUMYNT',
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 8.0,
                                ),
                          ),
                        ),
                      ),
                      SlideTransition(
                        position: _librarySlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Text(
                            'LIBRARY',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 12.0,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CircleRevealPainter extends CustomPainter {
  final double radius;
  final Color color;

  _CircleRevealPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _CircleRevealPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.color != color;
  }
}
