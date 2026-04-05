import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/features/admin/presentation/admin_route_provider.dart';
import 'package:gezdirelim/features/admin/presentation/admin_log_provider.dart';
import 'package:gezdirelim/features/home/presentation/destination_detail_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminRouteManagementScreen extends ConsumerWidget {
  const AdminRouteManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(adminRouteProvider).destinations;
    final routeNotifier = ref.read(adminRouteProvider.notifier);
    final logNotifier = ref.read(adminLogProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Destinasyon Yönetimi'),
        actions: [
          IconButton(
            onPressed: () => _showAddDestinationDialog(context, routeNotifier, logNotifier),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.plus,
                  color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
      body: destinations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.mapPin,
                      size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  const Text('Henüz destinasyon yok',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showAddDestinationDialog(context, routeNotifier, logNotifier),
                    icon: const Icon(LucideIcons.plus, size: 18),
                    label: const Text('Destinasyon Ekle'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final dest = destinations[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.surfaceBorder, width: 0.5),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: dest.imagePath.isNotEmpty
                          ? Image.asset(dest.imagePath,
                              width: 56, height: 56, fit: BoxFit.cover)
                          : Container(
                              width: 56,
                              height: 56,
                              color: AppColors.surfaceHighlight,
                              child: const Icon(LucideIcons.image,
                                  color: AppColors.textMuted),
                            ),
                    ),
                    title: Text(dest.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(dest.location,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(dest.category,
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.star,
                                size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(dest.rating.toString(),
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      icon: const Icon(LucideIcons.moreVertical,
                          size: 18, color: AppColors.textSecondary),
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(LucideIcons.eye,
                                  size: 16, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Görüntüle'),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DestinationDetailScreen(
                                  title: dest.title,
                                  location: dest.location,
                                  imagePath: dest.imagePath,
                                  rating: dest.rating,
                                  category: dest.category,
                                  isAdmin: true,
                                ),
                              ),
                            );
                          },
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(LucideIcons.edit3,
                                  size: 16, color: AppColors.secondary),
                              SizedBox(width: 8),
                              Text('Düzenle'),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              _showEditDestinationDialog(
                                  context, dest, routeNotifier, logNotifier);
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(LucideIcons.trash2,
                                  size: 16, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Sil',
                                  style:
                                      TextStyle(color: AppColors.error)),
                            ],
                          ),
                          onTap: () {
                            logNotifier.addLog('destination', 'Destinasyon silindi: ${dest.title}');
                            routeNotifier.removeDestination(dest.id);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DestinationDetailScreen(
                            title: dest.title,
                            location: dest.location,
                            imagePath: dest.imagePath,
                            rating: dest.rating,
                            category: dest.category,
                            isAdmin: true,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showAddDestinationDialog(
      BuildContext context, AdminRouteNotifier routeNotifier, AdminLogNotifier logNotifier) {
    final titleCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(LucideIcons.plus, color: AppColors.primary, size: 20),
            SizedBox(width: 12),
            Text('Destinasyon Ekle', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Başlık'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(hintText: 'Konum'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(hintText: 'Kategori'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Açıklama'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                routeNotifier.addDestination(DestinationModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  location: locationCtrl.text,
                  category: categoryCtrl.text,
                  createdAt: DateTime.now().toIso8601String(),
                ));
                logNotifier.addLog('destination', 'Destinasyon eklendi: ${titleCtrl.text}');
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showEditDestinationDialog(
      BuildContext context, DestinationModel dest,
      AdminRouteNotifier routeNotifier, AdminLogNotifier logNotifier) {
    final titleCtrl = TextEditingController(text: dest.title);
    final locationCtrl = TextEditingController(text: dest.location);
    final categoryCtrl = TextEditingController(text: dest.category);
    final descCtrl = TextEditingController(text: dest.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(LucideIcons.edit3, color: AppColors.secondary, size: 20),
            SizedBox(width: 12),
            Text('Düzenle', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(hintText: 'Başlık'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(hintText: 'Konum'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(hintText: 'Kategori'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Açıklama'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              routeNotifier.updateDestination(
                dest.id,
                dest.copyWith(
                  title: titleCtrl.text,
                  location: locationCtrl.text,
                  category: categoryCtrl.text,
                  description: descCtrl.text,
                ),
              );
              logNotifier.addLog('destination', 'Destinasyon güncellendi: ${titleCtrl.text}');
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
