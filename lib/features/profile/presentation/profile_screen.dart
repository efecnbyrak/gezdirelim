import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/features/profile/presentation/profile_provider.dart';
import 'package:gezdirelim/features/profile/presentation/settings_screen.dart';
import 'package:gezdirelim/features/profile/presentation/edit_profile_screen.dart';
import 'package:gezdirelim/features/profile/presentation/achievements_screen.dart';
import 'package:gezdirelim/features/profile/presentation/statistics_screen.dart';
import 'package:gezdirelim/features/profile/presentation/help_screen.dart';
import 'package:gezdirelim/features/admin/presentation/admin_login_screen.dart';
import 'package:gezdirelim/features/navigation/presentation/navigation_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Hidden admin gesture — 5 taps on profile photo
  int _adminTapCount = 0;
  DateTime? _lastTapTime;

  void _onProfilePhotoTap() {
    final now = DateTime.now();

    // Reset counter if > 2 seconds since last tap
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inSeconds > 2) {
      _adminTapCount = 0;
    }

    _lastTapTime = now;
    _adminTapCount++;

    if (_adminTapCount >= 5) {
      _adminTapCount = 0;
      HapticFeedback.heavyImpact();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      );
    } else if (_adminTapCount >= 3) {
      // Subtle feedback at 3 taps
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Profil fotoğrafı — 5 tap = admin access
                    GestureDetector(
                      onTap: _onProfilePhotoTap,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primary, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: AppColors.surfaceLight,
                          backgroundImage: profile.photoPath.isNotEmpty
                              ? FileImage(File(profile.photoPath))
                              : const AssetImage('assets/images/min.png')
                                  as ImageProvider,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.bio.isNotEmpty
                                ? profile.bio
                                : 'Gezgin',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14),
                          ),
                          if (profile.city.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(LucideIcons.mapPin,
                                    size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${profile.city}${profile.district.isNotEmpty ? ', ${profile.district}' : ''}',
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Ayarlar butonu
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      ),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.surfaceBorder, width: 0.5),
                        ),
                        child: const Icon(LucideIcons.settings,
                            color: AppColors.textSecondary, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // İstatistikler
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppColors.surfaceBorder, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('${profile.routeCount}', 'Rota',
                          AppColors.primary),
                      Container(
                          width: 1,
                          height: 30,
                          color: AppColors.surfaceBorder),
                      _buildStatColumn('${profile.favoriteCount}',
                          'Favori', AppColors.secondary),
                      Container(
                          width: 1,
                          height: 30,
                          color: AppColors.surfaceBorder),
                      _buildStatColumn(
                          '0', 'Yorum', AppColors.success),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Profil düzenle butonu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.ciniMavisi.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.edit3,
                            size: 16, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Profili Düzenle',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Dashboard Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.15,
                  children: [
                    _buildDashboardItem(
                      context,
                      'Aktif Rotalar',
                      LucideIcons.navigation,
                      AppColors.primary,
                      '${profile.routeCount} Rota',
                    ),
                    _buildDashboardItem(
                      context,
                      'Başarılar',
                      LucideIcons.award,
                      AppColors.secondary,
                      'Rozet Kazan',
                    ),
                    _buildDashboardItem(
                      context,
                      'İstatistikler',
                      LucideIcons.barChart2,
                      AppColors.success,
                      'Gezi Analizi',
                    ),
                    _buildDashboardItem(
                      context,
                      'Yardım',
                      LucideIcons.helpCircle,
                      AppColors.accent,
                      '7/24 Destek',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Çıkış Yap Butonu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.error.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.logOut,
                            size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(
                          'Çıkış Yap',
                          style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // RESPONSIVE FIX: Bottom padding to ensure button is above bottom bar
              SizedBox(height: bottomPadding + 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDashboardItem(BuildContext context, String title,
      IconData icon, Color color, String subtitle) {
    return InkWell(
      onTap: () {
        Widget screen;
        switch (title) {
          case 'Aktif Rotalar':
            ref.read(navigationIndexProvider.notifier).state = 1;
            return;
          case 'Başarılar':
            screen = const AchievementsScreen();
            break;
          case 'İstatistikler':
            screen = const StatisticsScreen();
            break;
          case 'Yardım':
            screen = const HelpScreen();
            break;
          default:
            return;
        }
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => screen));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.logOut,
                  color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Çıkış Yap',
                style: TextStyle(fontSize: 17)),
          ],
        ),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal',
                style:
                    TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context, rootNavigator: true)
                  .pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
