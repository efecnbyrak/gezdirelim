import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/core/common_widgets.dart';
import 'package:gezdirelim/features/favorites/presentation/favorites_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favState = ref.watch(favoritesProvider);
    final notifier = ref.read(favoritesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
      ),
      body: Column(
        children: [
          // Kategori Tab'ları
          _buildCategoryTabs(favState, notifier),

          // İçerik
          Expanded(
            child: favState.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.ciniMavisi))
                : _buildContent(context, favState, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(FavoritesState state, FavoritesNotifier notifier) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Row(
        children: [
          _buildTab(
            title: 'Gezdiğim Yerler',
            icon: LucideIcons.mapPin,
            isSelected: state.selectedTab == 0,
            count: state.places.length,
            onTap: () => notifier.selectTab(0),
          ),
          const SizedBox(width: 4),
          _buildTab(
            title: 'Rotalarım',
            icon: LucideIcons.navigation,
            isSelected: state.selectedTab == 1,
            count: state.routes.length,
            onTap: () => notifier.selectTab(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required int count,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.ciniMavisi : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.ciniMavisi.withOpacity(0.3), blurRadius: 8)]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.2) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FavoritesState state, FavoritesNotifier notifier) {
    final items = state.selectedTab == 0 ? state.places : state.routes;

    if (items.isEmpty) {
      return _buildEmptyState(state.selectedTab);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildFavoriteCard(context, item, notifier);
      },
    );
  }

  Widget _buildEmptyState(int tab) {
    final isPlaces = tab == 0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (isPlaces ? AppColors.osmanliAltini : AppColors.ciniMavisi).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaces ? LucideIcons.heart : LucideIcons.navigation,
                color: isPlaces ? AppColors.osmanliAltini : AppColors.ciniMavisi,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPlaces ? 'Henüz Gezdiğiniz Yer Yok' : 'Henüz Favori Rotanız Yok',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isPlaces
                  ? 'Gezdiğiniz yerleri buraya ekleyerek takip edin!'
                  : 'Beğendiğiniz rotaları favorilere ekleyin!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, FavoriteItem item, FavoritesNotifier notifier) {
    return Dismissible(
      key: Key('fav_${item.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDeleteConfirmDialog(
          context: context,
          title: 'Favoriyi Kaldır',
          message: '"${item.title}" favorilerinizden kaldırmak istediğinize emin misiniz?',
        );
      },
      onDismissed: (_) => notifier.removeFavorite(item.id!),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.mercanKirmizi.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(LucideIcons.trash2, color: AppColors.mercanKirmizi),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Row(
          children: [
            // Icon veya image
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: item.type == 'place'
                    ? AppColors.osmanliAltini.withOpacity(0.1)
                    : AppColors.ciniMavisi.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                item.type == 'place' ? LucideIcons.mapPin : LucideIcons.navigation,
                color: item.type == 'place' ? AppColors.osmanliAltini : AppColors.ciniMavisi,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  if (item.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                  if (item.rating > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: AppColors.osmanliAltini),
                        const SizedBox(width: 4),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.favorite,
              color: AppColors.mercanKirmizi,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

}
