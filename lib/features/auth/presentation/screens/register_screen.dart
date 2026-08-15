import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isSuccess = false;
  Timer? _resendTimer;
  int _resendSeconds = 60;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startResendTimer() {
    setState(() => _resendSeconds = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }

    if (password.length < 8) {
      _showError('Password must be at least 8 characters.');
      return;
    }

    setState(() => _isLoading = true);

    final authRepo = ref.read(authRepositoryProvider);
    final error = await authRepo.register(name, email, password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error != null) {
      _showError(error);
    } else {
      setState(() => _isSuccess = true);
      _startResendTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: !_isSuccess,
        leading: _isSuccess
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isSuccess) ...[
                Text(
                  'Create an Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Join us to review books and save your progress.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMutedLight,
                  ),
                ),
                SizedBox(height: 32),
              ],

              if (_isSuccess) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Lottie.asset(
                        'assets/animations/success.lottie',
                        width: 320,
                        height: 320,
                        repeat: false,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback until the asset is provided
                          return Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 80,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 32),
                      AppButton(
                        text: 'Go to Login',
                        onPressed: () => context.go('/login'),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: _resendSeconds > 0
                            ? null
                            : () {
                                _startResendTimer();
                                // Call resend API if needed
                              },
                        child: Text(
                          _resendSeconds > 0
                              ? 'Resend Verification Email in ${_resendSeconds}s'
                              : 'Resend Verification Email',
                          style: TextStyle(
                            color: _resendSeconds > 0
                                ? AppColors.textMutedLight
                                : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                AppTextField(
                  label: 'Full Name',
                  hintText: 'John Doe',
                  controller: _nameController,
                ),
                SizedBox(height: 24),
                AppTextField(
                  label: 'Email',
                  hintText: 'you@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 24),
                AppTextField(
                  label: 'Password',
                  hintText: '••••••••',
                  controller: _passwordController,
                  isPassword: true,
                ),
                SizedBox(height: 24),
                AppTextField(
                  label: 'Confirm Password',
                  hintText: '••••••••',
                  controller: _confirmPasswordController,
                  isPassword: true,
                ),
                SizedBox(height: 32),
                AppButton(
                  text: 'Create Account',
                  isLoading: _isLoading,
                  onPressed: _register,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: AppColors.textMutedLight),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        "Log in",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                const Divider(),
                SizedBox(height: 16),
                AppButton(
                  text: 'Skip for now',
                  isGhost: true,
                  onPressed: () => context.go('/home'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
