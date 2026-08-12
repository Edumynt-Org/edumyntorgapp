import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary;
  final bool isGhost;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.isGhost = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isGhost) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: AppColors.textMutedLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      );
    }

    // 3D effect achieved via Container with bottom border simulating elevation
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSecondary ? AppColors.surfaceLight : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          border: isSecondary 
            ? Border.all(color: AppColors.borderLight)
            : Border(
                top: const BorderSide(color: Colors.transparent),
                left: const BorderSide(color: Colors.transparent),
                right: const BorderSide(color: Colors.transparent),
                bottom: BorderSide(
                  color: AppColors.primaryDark,
                  width: 4,
                ),
              ),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        isSecondary ? AppColors.primary : Colors.white),
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: isSecondary ? AppColors.textLight : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
