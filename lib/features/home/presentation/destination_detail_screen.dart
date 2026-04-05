import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/features/favorites/presentation/favorites_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Trendyol-style destination detail screen
/// Admin: CRUD enabled | User: view-only
class DestinationDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final String location;
  final String imagePath;
  final double rating;
  final String category;
  final bool isAdmin;

  const DestinationDetailScreen({
    super.key,
    required this.title,
    required this.location,
    required this.imagePath,
    required this.rating,
    this.category = '',
    this.isAdmin = false,
  });

  @override
  ConsumerState<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends ConsumerState<DestinationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final isFavorite = ref.watch(favoritesProvider).isFavorite(widget.title);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image App Bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.chevronLeft,
                    color: Colors.white, size: 22),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  ref.read(favoritesProvider.notifier).toggleFavorite(
                        destinationId: widget.title,
                        type: 'place',
                        title: widget.title,
                        subtitle: widget.location,
                        imagePath: widget.imagePath,
                        rating: widget.rating,
                      );
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isFavorite
                        ? AppColors.error.withOpacity(0.85)
                        : Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'dest_hero_${widget.title}',
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  if (widget.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.category,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (widget.category.isNotEmpty) const SizedBox(height: 12),

                  // Title
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Location row
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        widget.location,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              widget.rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.surfaceBorder),
                  const SizedBox(height: 24),

                  // Açıklama Section
                  _buildSectionTitle('Açıklama', LucideIcons.fileText),
                  const SizedBox(height: 12),
                  Text(
                    _getDescription(widget.title),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Tarihçe Section
                  _buildSectionTitle('Tarihçe', LucideIcons.clock),
                  const SizedBox(height: 12),
                  Text(
                    _getHistory(widget.title),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Ek Bilgiler
                  _buildSectionTitle('Ek Bilgiler', LucideIcons.info),
                  const SizedBox(height: 16),

                  _buildInfoRow(
                      LucideIcons.clock, 'Ziyaret Saatleri', '09:00 - 18:00'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                      LucideIcons.ticket, 'Giriş Ücreti', 'Ücretsiz'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                      LucideIcons.navigation, 'Ulaşım', 'Metro / Tramvay'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                      LucideIcons.phone, 'İletişim', '+90 212 XXX XX XX'),

                  const SizedBox(height: 28),

                  // Konum Section
                  _buildSectionTitle('Konum', LucideIcons.map),
                  const SizedBox(height: 16),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.map,
                              size: 36, color: AppColors.textMuted),
                          SizedBox(height: 8),
                          Text(
                            'Harita yakında eklenecek',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Admin Actions
                  if (widget.isAdmin) ...[
                    const SizedBox(height: 28),
                    const Divider(color: AppColors.surfaceBorder),
                    const SizedBox(height: 16),
                    _buildSectionTitle(
                        'Admin İşlemleri', LucideIcons.shieldCheck),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Düzenleme yakında...')),
                              );
                            },
                            icon: const Icon(LucideIcons.edit3, size: 16),
                            label: const Text('Düzenle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Silme yakında...')),
                              );
                            },
                            icon: const Icon(LucideIcons.trash2, size: 16),
                            label: const Text('Sil'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDescription(String title) {
    switch (title) {
      case 'Sultanahmet Camii':
        return 'Sultan I. Ahmed tarafından 1609-1616 yılları arasında yaptırılan Sultanahmet Camii, İstanbul\'un en ikonik yapılarından biridir. Altı minaresiyle dünyada benzersiz olan cami, içindeki mavi İznik çinileri nedeniyle "Mavi Cami" olarak da bilinir. UNESCO Dünya Mirası Listesi\'nde yer almaktadır.';
      case 'Gezgin Mutfağı':
        return 'Ankara\'nın kalbinde yer alan Gezgin Mutfağı, Anadolu\'nun eşsiz lezzetlerini modern bir sunumla buluşturur. Yerel çiftçilerden temin edilen taze malzemelerle hazırlanan menüsü, her mevsim değişen özel tatlarla zenginleştirilir.';
      case 'Gece Hayatı':
        return 'İzmir\'in canlı gece hayatı, Alsancak ve Kordon boyunca uzanan barlar sokağından başlayarak, sahil şeridindeki mekanlarla devam eder. Canlı müzik, DJ performansları ve Ege\'nin eşsiz atmosferi bir arada.';
      default:
        return 'Bu destinasyon hakkında detaylı bilgi yakında eklenecektir.';
    }
  }

  String _getHistory(String title) {
    switch (title) {
      case 'Sultanahmet Camii':
        return '1609 yılında inşaatına başlanan cami, 7 yıllık yapım sürecinin ardından 1616\'da tamamlanmıştır. Mimar Sedefkâr Mehmed Ağa tarafından tasarlanan yapı, Osmanlı mimarisinin en önemli eserlerinden biridir. Yüzyıllar boyunca İstanbul\'un siluetini belirleyen cami, günümüzde de aktif ibadethane olarak kullanılmaktadır.';
      case 'Gezgin Mutfağı':
        return '2018 yılında kurulan Gezgin Mutfağı, Anadolu mutfak kültürünü modern dünyaya taşıma misyonuyla yola çıkmıştır. İlk şubesinden bu yana binlerce misafir ağırlamış ve Türk mutfağını tanıtmada öncü rol üstlenmiştir.';
      case 'Gece Hayatı':
        return 'İzmir\'in gece eğlence kültürü, şehrin kozmopolit yapısıyla şekillenmiştir. Cumhuriyet döneminden itibaren gelişen eğlence sektörü, günümüzde uluslararası standartlarda hizmet vermektedir.';
      default:
        return 'Bu destinasyonun tarihçesi yakında eklenecektir.';
    }
  }
}
