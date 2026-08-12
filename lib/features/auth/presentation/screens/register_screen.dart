import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/auth_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSuccess = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
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

    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final error = await authRepo.register(name, email, password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error != null) {
      _showError(error);
    } else {
      setState(() => _isSuccess = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Edumynt Org',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isSuccess 
                  ? "We've sent you a verification email."
                  : 'Join us to review books and save your progress.',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textMutedLight,
                ),
              ),
              const SizedBox(height: 48),
              
              if (_isSuccess) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 40),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Check your inbox',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'We sent a verification link to your email. Please click it to activate your account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMutedLight),
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: 'Go to Login',
                        isSecondary: true,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                CustomTextField(
                  label: 'Full Name',
                  hintText: 'John Doe',
                  controller: _nameController,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Email',
                  hintText: 'you@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Password',
                  hintText: '••••••••',
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Confirm Password',
                  hintText: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Create Account',
                  isLoading: _isLoading,
                  onPressed: _register,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: AppColors.textMutedLight),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                CustomButton(
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
