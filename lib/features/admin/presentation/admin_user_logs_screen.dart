import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/features/admin/presentation/admin_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminUserLogsScreen extends ConsumerWidget {
  const AdminUserLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Kullanıcı Logları'),
        actions: [
          if (adminState.logs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${adminState.logs.length} kayıt',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: adminState.logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.fileText,
                      size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  const Text('Henüz log kaydı yok',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text(
                    'Kullanıcı aksiyonları burada görünecek',
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: adminState.logs.length,
              itemBuilder: (context, index) {
                final log = adminState.logs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.surfaceBorder, width: 0.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getColor(log.action).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIcon(log.action),
                          size: 18,
                          color: _getColor(log.action),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getColor(log.action)
                                        .withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _getLabel(log.action),
                                    style: TextStyle(
                                      color: _getColor(log.action),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatTime(log.timestamp),
                                  style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              log.detail,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Color _getColor(String action) {
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

  IconData _getIcon(String action) {
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

  String _getLabel(String action) {
    switch (action) {
      case 'login':
        return 'GİRİŞ';
      case 'favorite':
        return 'FAVORİ';
      case 'search':
        return 'ARAMA';
      case 'category':
        return 'KATEGORİ';
      case 'destination':
        return 'DEST.';
      default:
        return 'DİĞER';
    }
  }

  String _formatTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timestamp;
    }
  }
}
