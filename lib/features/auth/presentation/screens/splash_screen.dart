import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/auth_repository.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait for a second just to show the splash
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    if (authRepo.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        // The splash screen is just the primary color as requested.
        // We can add a logo here later.
        child: SizedBox.shrink(),
      ),
    );
  }
}
