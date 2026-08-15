import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  Timer? _resendTimer;
  int _resendSeconds = 60;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
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

  Future<void> _submit() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter a valid email address.');
      return;
    }

    setState(() => _isLoading = true);

    final authRepo = ref.read(authRepositoryProvider);
    final error = await authRepo.forgotPassword(email);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error != null) {
      _showError(error);
    } else {
      setState(() {
        _isSuccess = true;
      });
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
                Center(
                  child: Lottie.asset(
                    'assets/animations/forgot_password.lottie',
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Reset Password',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Enter your email and we'll send you a link to reset your password.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMutedLight,
                  ),
                ),
                SizedBox(height: 48),
              ],

              if (_isSuccess) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
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
                              ? 'Resend Email in ${_resendSeconds}s'
                              : 'Resend Email',
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
                  label: 'Email',
                  hintText: 'you@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 32),
                AppButton(
                  text: 'Send Reset Link',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
