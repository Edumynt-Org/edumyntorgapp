import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class ScaffoldWithNav extends StatefulWidget {
  const ScaffoldWithNav({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithNav> createState() => _ScaffoldWithNavState();
}

class _ScaffoldWithNavState extends State<ScaffoldWithNav> {
  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 72, // Fixed height for consistent layout
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: borderColor, width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 3;
              final currentIndex = widget.navigationShell.currentIndex;

              // Pill dimensions
              const pillWidth = 64.0;
              const pillHeight = 34.0;

              return Stack(
                alignment: Alignment.center,
                children: [
                  // The animated sliding pill
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve:
                        Curves.easeOutBack, // Gives a nice little bounce effect
                    left:
                        (currentIndex * tabWidth) +
                        (tabWidth / 2) -
                        (pillWidth / 2),
                    top: 10, // Position behind the icons
                    child: Container(
                      width: pillWidth,
                      height: pillHeight,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  // The navigation icons
                  Row(
                    children: [
                      _NavBarItem(
                        icon: Icons.home_rounded,
                        label: 'HOME',
                        isSelected: currentIndex == 0,
                        onTap: () => _goBranch(0),
                        width: tabWidth,
                      ),
                      _NavBarItem(
                        icon: Icons.menu_book_rounded,
                        label: 'BOOKS',
                        isSelected: currentIndex == 1,
                        onTap: () => _goBranch(1),
                        width: tabWidth,
                      ),
                      _NavBarItem(
                        icon: Icons.person_rounded,
                        label: 'PROFILE',
                        isSelected: currentIndex == 2,
                        onTap: () => _goBranch(2),
                        width: tabWidth,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final color = isSelected ? primaryColor : mutedColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 34, // Matches the pill height exactly
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutQuint,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontFamily: 'Nunito',
                letterSpacing: 0.5,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
