import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gezdirelim/features/home/presentation/home_screen.dart';
import 'package:gezdirelim/features/route/presentation/add_route_screen.dart';
import 'package:gezdirelim/features/favorites/presentation/favorites_screen.dart';
import 'package:gezdirelim/features/profile/presentation/profile_screen.dart';
import 'package:gezdirelim/features/route/presentation/map_route_planner_screen.dart';
import 'package:gezdirelim/core/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AddRouteScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Needed for notched FAB to look good
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (context, animation, secondaryAnimation) => const MapRoutePlannerScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                var tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOutQuart));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        },
        backgroundColor: AppColors.ciniMavisi, // Emphasized color
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.map, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.background,
        surfaceTintColor: Colors.transparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60, // Fixed height to prevent overflow
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / 5; // 5 slots: 0, 1, FAB, 2, 3

              // Calculate left offset based on current index
              double leftOffset = 0;
              if (_currentIndex == 0) leftOffset = 0;
              if (_currentIndex == 1) leftOffset = itemWidth;
              if (_currentIndex == 2) leftOffset = itemWidth * 3; // Skips FAB slot
              if (_currentIndex == 3) leftOffset = itemWidth * 4;

              return Stack(
                children: [
                  // Animated Sliding Circle
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack, // Gives that bouncy "ball" effect
                    left: leftOffset,
                    top: 0,
                    bottom: 0,
                    width: itemWidth,
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.ciniMavisi.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  
                  // The Icons Row
                  Row(
                    children: [
                      SizedBox(width: itemWidth, child: _buildNavItem(0, LucideIcons.home, 'Anasayfa')),
                      SizedBox(width: itemWidth, child: _buildNavItem(1, LucideIcons.navigation, 'Rotalarım')),
                      SizedBox(width: itemWidth), // Space for FAB
                      SizedBox(width: itemWidth, child: _buildNavItem(2, LucideIcons.heart, 'Favorilerim')),
                      SizedBox(width: itemWidth, child: _buildNavItem(3, LucideIcons.user, 'Profil')),
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

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: Column(
              key: ValueKey<bool>(isSelected),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.ciniMavisi : AppColors.textSecondary,
                  size: isSelected ? 24 : 22,
                ),
                if (isSelected) const SizedBox(height: 2),
                if (isSelected) 
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.ciniMavisi,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
