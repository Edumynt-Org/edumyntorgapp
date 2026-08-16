import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/home_providers.dart';
import '../widgets/book_list_horizontal_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authRepo = ref.watch(authRepositoryProvider);
    final isAuthenticated = authRepo.isAuthenticated;

    final homepageListsAsync = ref.watch(homepageListsProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            titleSpacing: 16,
            toolbarHeight: 72,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (isAuthenticated) {
                      context.go('/profile');
                    } else {
                      context.go('/login');
                    }
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: isAuthenticated && authRepo.avatarUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  authRepo.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                        child: Text(
                                          authRepo.userName?.isNotEmpty == true
                                              ? authRepo.userName![0]
                                                    .toUpperCase()
                                              : 'R',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  isAuthenticated
                                      ? (authRepo.userName?.isNotEmpty == true
                                            ? authRepo.userName![0]
                                                  .toUpperCase()
                                            : 'R')
                                      : '👤',
                                  style: TextStyle(
                                    fontSize: isAuthenticated ? 20 : 24,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isAuthenticated ? 'Welcome,' : 'Login',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            isAuthenticated
                                ? (authRepo.userName?.split(' ').first ??
                                      'Reader')
                                : 'Guest',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.accentDark,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '0',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          homepageListsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error loading lists: $err')),
            ),
            data: (lists) {
              if (lists.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No book lists found.')),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 32.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final list = lists[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: BookListHorizontalSection(bookList: list),
                    );
                  }, childCount: lists.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
