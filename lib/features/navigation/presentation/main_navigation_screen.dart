import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gezdirelim/features/home/presentation/home_screen.dart';
import 'package:gezdirelim/features/route/presentation/add_route_screen.dart';
import 'package:gezdirelim/features/favorites/presentation/favorites_screen.dart';
import 'package:gezdirelim/features/profile/presentation/profile_screen.dart';
import 'package:gezdirelim/features/route/presentation/map_route_planner_screen.dart';
import 'package:gezdirelim/features/navigation/presentation/navigation_provider.dart';
import 'package:gezdirelim/core/app_colors.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  final List<Widget> _screens = const [
    HomeScreen(),
    AddRouteScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(currentIndex),
          child: _screens[currentIndex],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const MapRoutePlannerScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                var tween =
                    Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeOutQuart));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(
          LucideIcons.compass,
          color: Colors.white,
          size: 26,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFFC8E1E),
              width: 2.5,
            ),
          ),
        ),
        child: BottomAppBar(
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: 60,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / 5;

                double leftOffset = 0;
                if (currentIndex == 0) leftOffset = 0;
                if (currentIndex == 1) leftOffset = itemWidth;
                if (currentIndex == 2) leftOffset = itemWidth * 3;
                if (currentIndex == 3) leftOffset = itemWidth * 4;

                return Stack(
                  children: [
                    // Animated Sliding Indicator with enhanced glow
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutBack,
                      left: leftOffset,
                      top: 0,
                      bottom: 0,
                      width: itemWidth,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // The Icons Row
                    Row(
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: _buildNavItem(
                              ref, 0, LucideIcons.home, 'Anasayfa'),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildNavItem(
                              ref, 1, LucideIcons.navigation, 'Rotalarım'),
                        ),
                        SizedBox(width: itemWidth), // Space for FAB
                        SizedBox(
                          width: itemWidth,
                          child: _buildNavItem(
                              ref, 2, LucideIcons.heart, 'Favorilerim'),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildNavItem(
                              ref, 3, LucideIcons.user, 'Profil'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      WidgetRef ref, int index, IconData icon, String label) {
    final isSelected = ref.read(navigationIndexProvider) == index;
    return GestureDetector(
      onTap: () =>
          ref.read(navigationIndexProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Column(
              key: ValueKey<bool>(isSelected),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: isSelected ? 24 : 22,
                ),
                if (isSelected) const SizedBox(height: 2),
                if (isSelected)
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
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
