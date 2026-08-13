import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock user state
  final bool _isLoggedIn = false;

  void _showSettingsModal(BuildContext context, bool isDark) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Settings', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Dark Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      Switch(
                        value: isDark,
                        onChanged: (val) {
                          // TODO: Implement theme switching logic
                        },
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('ACCOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: Implement logout
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.error, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error)),
                        const Icon(Icons.arrow_forward, color: AppColors.error, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 2),
              ),
              child: const Icon(Icons.settings, size: 20),
            ),
            onPressed: () => _showSettingsModal(context, isDark),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoggedIn ? _buildLoggedInState(isDark) : _buildLoggedOutState(isDark),
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
                color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 2),
              ),
              child: const Center(child: Text('👤', style: TextStyle(fontSize: 48))),
            ),
            const SizedBox(height: 24),
            Text(
              'Join Edumynt Library',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black, height: 1.1),
            ),
            const SizedBox(height: 12),
            Text(
              'Sign up to sync your reading progress, leave reviews, and build your digital library.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 2),
                ),
                child: const Text('Log In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 4),
            ),
            child: const Center(
              child: Text('U', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: 16),
          Text('User', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 4),
          Text('user@example.com', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
          
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
            child: Text('My Library', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('📚', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text('Your library is empty', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
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
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 2),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
        ],
      ),
    );
  }
}
