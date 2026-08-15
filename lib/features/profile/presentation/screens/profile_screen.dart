import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _showSettingsModal(BuildContext context, bool isDark, bool isLoggedIn) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return Consumer(
            builder: (context, modalRef, child) {
              return Scaffold(
                backgroundColor: isDark
                    ? AppColors.surfaceDark
                    : AppColors.backgroundLight,
                appBar: AppBar(
                  backgroundColor: isDark
                      ? AppColors.surfaceDark
                      : AppColors.backgroundLight,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Text(
                    'Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PREFERENCES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Dark Mode',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                modalRef.read(themeProvider).toggleTheme();
                              },
                              child: Container(
                                width: 48,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Theme.of(context).colorScheme.primary
                                      : AppColors.borderLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    AnimatedPositioned(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      curve: Curves.easeInOut,
                                      left: isDark ? 26 : 2,
                                      top: 2,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.surfaceDark
                                              : Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isLoggedIn) ...[
                        const SizedBox(height: 32),
                        Text(
                          'ACCOUNT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            await modalRef
                                .read(authRepositoryProvider)
                                .logout();
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('skipped_login');
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.error,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Log Out',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authRepo = ref.watch(authRepositoryProvider);
    final isLoggedIn = authRepo.isAuthenticated;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: false,
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : AppColors.backgroundLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: const Icon(Icons.settings, size: 20),
            ),
            onPressed: () => _showSettingsModal(context, isDark, isLoggedIn),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoggedIn
          ? _buildLoggedInState(isDark, authRepo)
          : _buildLoggedOutState(isDark),
    );
  }

  Widget _buildLoggedOutState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : AppColors.backgroundLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text('👤', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Join Edumynt Library',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sign up to sync your reading progress, leave reviews, and build your digital library.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    width: 2,
                  ),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInState(bool isDark, var authRepo) {
    final userName = authRepo.userName ?? 'Reader';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'R';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
                width: 4,
              ),
              image: authRepo.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(authRepo.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: authRepo.avatarUrl == null
                ? Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Verified account',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildStatCard('0', 'BOOKS READ', isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('0h', 'LISTENING TIME', isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('0', 'REVIEWS', isDark)),
            ],
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'My Library',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('📚', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  'Your library is empty',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}
