import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// A single shimmer placeholder box with rounded corners
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.borderLight,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Wraps children in a shimmer animation
class ShimmerWrap extends StatelessWidget {
  final Widget child;

  const ShimmerWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
      highlightColor: isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5),
      child: child,
    );
  }
}

class BookDetailSkeleton extends StatelessWidget {
  const BookDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ShimmerWrap(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Safe area space equivalent and padding matching detail screen
            const SizedBox(height: 16.0 + 48.0), // typical top padding + close button space
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left space (for sticky close button)
                      const SizedBox(width: 48, height: 48),
                      // Center cover
                      SkeletonBox(width: 160, height: 240, borderRadius: 16),
                      // Right share & download buttons
                      Column(
                        children: [
                          SkeletonBox(width: 48, height: 48, borderRadius: 16),
                          const SizedBox(height: 12),
                          SkeletonBox(width: 48, height: 48, borderRadius: 16),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Title
                  SkeletonBox(width: screenWidth * 0.7, height: 32),
                  const SizedBox(height: 8),
                  // Author
                  SkeletonBox(width: screenWidth * 0.4, height: 20),
                  const SizedBox(height: 12),
                  // Year and Language
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkeletonBox(width: 40, height: 16),
                      const SizedBox(width: 12),
                      SkeletonBox(width: 10, height: 16),
                      const SizedBox(width: 12),
                      SkeletonBox(width: 40, height: 16),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Description
                  SkeletonBox(width: double.infinity, height: 16),
                  const SizedBox(height: 6),
                  SkeletonBox(width: double.infinity, height: 16),
                  const SizedBox(height: 6),
                  SkeletonBox(width: screenWidth * 0.8, height: 16),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Edition Selector Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SkeletonBox(width: double.infinity, height: 48, borderRadius: 12),
            ),
            const SizedBox(height: 16),
            // Content Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(child: SkeletonBox(width: double.infinity, height: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SkeletonBox(width: 60, height: 16),
                  ),
                  Expanded(child: SkeletonBox(width: double.infinity, height: 1)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // TOC List
            ...List.generate(6, (i) => Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0),
              child: SkeletonBox(width: double.infinity, height: 48),
            )),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a grid of book covers (used in BooksScreen)
class BookGridSkeleton extends StatelessWidget {
  final int count;

  const BookGridSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.55,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: count,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SkeletonBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: AppRadius.lg,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const SkeletonBox(width: 80, height: 12),
            ],
          );
        },
      ),
    );
  }
}

/// Skeleton for horizontal book list section on home screen
class BookListHorizontalSkeleton extends StatelessWidget {
  const BookListHorizontalSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SkeletonBox(width: 160, height: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          // Horizontal scroll of cover cards
          SizedBox(
            height: 270,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: 140,
                        height: 210,
                        borderRadius: AppRadius.lg,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const SkeletonBox(width: 100, height: 14),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
