import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/supabase_service.dart';

/// Favori modeli
class FavoriteItem {
  final String? id; // UUID from Supabase (nullable for optimistic items)
  final String destinationId; // Unique ID of the place/route
  final String type; // 'place' veya 'route'
  final String title;
  final String subtitle;
  final String imagePath;
  final double rating;
  final String createdAt;

  FavoriteItem({
    this.id,
    required this.destinationId,
    required this.type,
    required this.title,
    this.subtitle = '',
    this.imagePath = '',
    this.rating = 0,
    required this.createdAt,
  });

  FavoriteItem copyWith({String? id}) {
    return FavoriteItem(
      id: id ?? this.id,
      destinationId: destinationId,
      type: type,
      title: title,
      subtitle: subtitle,
      imagePath: imagePath,
      rating: rating,
      createdAt: createdAt,
    );
  }
}

/// Favoriler state'i
class FavoritesState {
  final List<FavoriteItem> places; // Gezdiğim Yerler
  final List<FavoriteItem> routes; // Rotalarım
  final bool isLoading;
  final int selectedTab; // 0 = Yerler, 1 = Rotalar

  FavoritesState({
    this.places = const [],
    this.routes = const [],
    this.isLoading = false,
    this.selectedTab = 0,
  });

  bool isFavorite(String destinationId) {
    return places.any((f) => f.destinationId == destinationId) ||
        routes.any((f) => f.destinationId == destinationId);
  }

  FavoritesState copyWith({
    List<FavoriteItem>? places,
    List<FavoriteItem>? routes,
    bool? isLoading,
    int? selectedTab,
  }) {
    return FavoritesState(
      places: places ?? this.places,
      routes: routes ?? this.routes,
      isLoading: isLoading ?? this.isLoading,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

/// Favoriler notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final SupabaseService _supabase = SupabaseService.instance;

  FavoritesNotifier() : super(FavoritesState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final user = _supabase.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final favorites = await _supabase.getFavorites(user.id);

      final places = favorites
          .where((f) => f['type'] == 'place')
          .map((m) => FavoriteItem(
                id: m['id'].toString(),
                destinationId: m['destination_id']?.toString() ??
                    m['title'].toString(), // Fallback to title
                type: m['type'] as String,
                title: m['title'] as String,
                subtitle: m['subtitle'] as String? ?? '',
                imagePath: m['image_path'] as String? ?? '',
                rating: (m['rating'] as num?)?.toDouble() ?? 0,
                createdAt: m['created_at'] as String,
              ))
          .toList();

      final routes = favorites
          .where((f) => f['type'] == 'route')
          .map((m) => FavoriteItem(
                id: m['id'].toString(),
                destinationId: m['destination_id']?.toString() ??
                    m['title'].toString(), // Fallback to title
                type: m['type'] as String,
                title: m['title'] as String,
                subtitle: m['subtitle'] as String? ?? '',
                imagePath: m['image_path'] as String? ?? '',
                rating: (m['rating'] as num?)?.toDouble() ?? 0,
                createdAt: m['created_at'] as String,
              ))
          .toList();

      state = state.copyWith(
        places: places,
        routes: routes,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[FavoritesNotifier] loadFavorites error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void selectTab(int tab) {
    state = state.copyWith(selectedTab: tab);
  }

  /// Toggle favorite status (Add if not exists, remove if exists)
  /// IMPLEMENTS OPTIMISTIC UI
  Future<void> toggleFavorite({
    required String destinationId,
    required String type,
    required String title,
    String subtitle = '',
    String imagePath = '',
    double rating = 0,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) return;

    final isFav = state.isFavorite(destinationId);
    final previousState = state;

    if (isFav) {
      // --- REMOVE (Optimistic) ---
      _removeLocally(destinationId);
      try {
        await _supabase.removeFavorite(user.id, destinationId);
      } catch (e) {
        debugPrint('Remove favorite fail, rolling back: $e');
        state = previousState; // Rollback
      }
    } else {
      // --- ADD (Optimistic) ---
      final newItem = FavoriteItem(
        destinationId: destinationId,
        type: type,
        title: title,
        subtitle: subtitle,
        imagePath: imagePath,
        rating: rating,
        createdAt: DateTime.now().toIso8601String(),
      );
      _addLocally(newItem);

      try {
        await _supabase.addFavorite(user.id, {
          'destination_id': destinationId,
          'type': type,
          'title': title,
          'subtitle': subtitle,
          'image_path': imagePath,
          'rating': rating,
          'created_at': newItem.createdAt,
        });
        // Actually we might need the real ID from Supabase, so reload silent
        await loadFavorites();
      } catch (e) {
        debugPrint('Add favorite fail, rolling back: $e');
        state = previousState; // Rollback
      }
    }
  }

  void _addLocally(FavoriteItem item) {
    if (item.type == 'place') {
      state = state.copyWith(places: [...state.places, item]);
    } else {
      state = state.copyWith(routes: [...state.routes, item]);
    }
  }

  void _removeLocally(String destinationId) {
    state = state.copyWith(
      places:
          state.places.where((f) => f.destinationId != destinationId).toList(),
      routes:
          state.routes.where((f) => f.destinationId != destinationId).toList(),
    );
  }

  // Legacy methods for compatibility (if any)
  Future<void> addFavorite(Map<String, dynamic> data) async {
    await toggleFavorite(
      destinationId: data['destination_id'] ?? data['title'],
      type: data['type'],
      title: data['title'],
      subtitle: data['subtitle'] ?? '',
      imagePath: data['image_path'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<void> removeFavorite(String destinationId) async {
    final user = _supabase.currentUser;
    if (user == null) return;
    _removeLocally(destinationId);
    await _supabase.removeFavorite(user.id, destinationId);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier();
});
