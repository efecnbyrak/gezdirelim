import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/features/admin/presentation/admin_provider.dart';
import 'package:gezdirelim/features/admin/presentation/admin_route_provider.dart';
import 'package:gezdirelim/features/admin/presentation/admin_category_provider.dart';
import 'package:gezdirelim/features/admin/presentation/admin_log_provider.dart';
import 'package:gezdirelim/features/admin/presentation/admin_route_management_screen.dart';
import 'package:gezdirelim/features/admin/presentation/admin_category_management_screen.dart';
import 'package:gezdirelim/features/admin/presentation/admin_user_logs_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(adminRouteProvider).destinations;
    final categories = ref.watch(adminCategoryProvider).categories;
    final logs = ref.watch(adminLogProvider).logs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Row(
          children: [
            Icon(LucideIcons.shieldCheck, color: AppColors.error, size: 22),
            SizedBox(width: 10),
            Text('Admin Panel'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(adminAuthProvider.notifier).logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(LucideIcons.logOut, color: AppColors.error),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İstatistik kartları
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Destinasyonlar',
                    '${destinations.length}',
                    LucideIcons.mapPin,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Kategoriler',
                    '${categories.length}',
                    LucideIcons.layers,
                    AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Loglar',
                    '${logs.length}',
                    LucideIcons.fileText,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            const Text(
              'Yönetim',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Dashboard Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.15,
              children: [
                _buildDashboardItem(
                  context,
                  'Rota Yönetimi',
                  'Listele, Ekle, Düzenle, Sil',
                  LucideIcons.navigation,
                  AppColors.primary,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminRouteManagementScreen()),
                  ),
                ),
                _buildDashboardItem(
                  context,
                  'Kategori Yönetimi',
                  'Ekle & Sil',
                  LucideIcons.layers,
                  AppColors.secondary,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const AdminCategoryManagementScreen()),
                  ),
                ),
                _buildDashboardItem(
                  context,
                  'Kullanıcı Logları',
                  'Login, Favori, Arama',
                  LucideIcons.fileText,
                  AppColors.success,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminUserLogsScreen()),
                  ),
                ),
                _buildDashboardItem(
                  context,
                  'Destinasyonlar',
                  'CRUD Yönetimi',
                  LucideIcons.mapPin,
                  AppColors.accent,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminRouteManagementScreen()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Son Loglar
            const Text(
              'Son Aktiviteler',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (logs.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: const Center(
                  child: Text(
                    'Henüz log kaydı yok',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...logs.take(5).map((log) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.surfaceBorder, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getLogColor(log.action).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getLogIcon(log.action),
                            size: 16,
                            color: _getLogColor(log.action),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.detail,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(
                                _formatTimestamp(log.timestamp),
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, String title,
      String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
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
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 3),
            Text(subtitle,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Color _getLogColor(String action) {
    switch (action) {
      case 'login':
        return AppColors.primary;
      case 'favorite':
        return AppColors.error;
      case 'search':
        return AppColors.secondary;
      case 'category':
        return AppColors.accent;
      case 'destination':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getLogIcon(String action) {
    switch (action) {
      case 'login':
        return LucideIcons.logIn;
      case 'favorite':
        return LucideIcons.heart;
      case 'search':
        return LucideIcons.search;
      case 'category':
        return LucideIcons.layers;
      case 'destination':
        return LucideIcons.mapPin;
      default:
        return LucideIcons.fileText;
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timestamp;
    }
  }
}
