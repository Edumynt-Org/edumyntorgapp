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

/// Skeleton for the book detail page — matches the real layout structure
class BookDetailSkeleton extends StatelessWidget {
  const BookDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final coverWidth = screenWidth * 0.45;
    final coverHeight = coverWidth * 1.5;

    return ShimmerWrap(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.xl),
            // Cover placeholder
            SkeletonBox(
              width: coverWidth,
              height: coverHeight,
              borderRadius: AppRadius.lg,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Title
            const SkeletonBox(width: 200, height: 24),
            const SizedBox(height: AppSpacing.sm),
            // Author
            const SkeletonBox(width: 140, height: 16),
            const SizedBox(height: AppSpacing.lg),
            // Action buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBox(width: 100, height: 44, borderRadius: AppRadius.pill),
                const SizedBox(width: AppSpacing.md),
                SkeletonBox(width: 100, height: 44, borderRadius: AppRadius.pill),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            // Edition tabs
            const Row(
              children: [
                SkeletonBox(width: 80, height: 32),
                SizedBox(width: AppSpacing.sm),
                SkeletonBox(width: 80, height: 32),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // TOC items
            ...List.generate(6, (i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  const SkeletonBox(width: 32, height: 32, borderRadius: AppRadius.md),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: SkeletonBox(width: double.infinity, height: 16, borderRadius: AppRadius.sm)),
                ],
              ),
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
