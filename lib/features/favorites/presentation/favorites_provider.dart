import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/database_helper.dart';

/// Favori modeli
class FavoriteItem {
  final int? id;
  final String type; // 'place' veya 'route'
  final String title;
  final String subtitle;
  final String imagePath;
  final double rating;
  final String createdAt;

  FavoriteItem({
    this.id,
    required this.type,
    required this.title,
    this.subtitle = '',
    this.imagePath = '',
    this.rating = 0,
    required this.createdAt,
  });
}

/// Favoriler state'i
class FavoritesState {
  final List<FavoriteItem> places;     // Gezdiğim Yerler
  final List<FavoriteItem> routes;     // Rotalarım
  final bool isLoading;
  final int selectedTab;              // 0 = Yerler, 1 = Rotalar

  FavoritesState({
    this.places = const [],
    this.routes = const [],
    this.isLoading = false,
    this.selectedTab = 0,
  });

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
  final DatabaseHelper _db = DatabaseHelper();

  FavoritesNotifier() : super(FavoritesState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true);
    try {
      final placesMaps = await _db.getFavoritesByType('place');
      final routesMaps = await _db.getFavoritesByType('route');

      state = state.copyWith(
        places: placesMaps.map((m) => FavoriteItem(
          id: m['id'] as int,
          type: m['type'] as String,
          title: m['title'] as String,
          subtitle: m['subtitle'] as String? ?? '',
          imagePath: m['image_path'] as String? ?? '',
          rating: (m['rating'] as num?)?.toDouble() ?? 0,
          createdAt: m['created_at'] as String,
        )).toList(),
        routes: routesMaps.map((m) => FavoriteItem(
          id: m['id'] as int,
          type: m['type'] as String,
          title: m['title'] as String,
          subtitle: m['subtitle'] as String? ?? '',
          imagePath: m['image_path'] as String? ?? '',
          rating: (m['rating'] as num?)?.toDouble() ?? 0,
          createdAt: m['created_at'] as String,
        )).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectTab(int tab) {
    state = state.copyWith(selectedTab: tab);
  }

  Future<void> addFavorite({
    required String type,
    required String title,
    String subtitle = '',
    String imagePath = '',
    double rating = 0,
  }) async {
    await _db.insertFavorite({
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'image_path': imagePath,
      'rating': rating,
      'created_at': DateTime.now().toIso8601String(),
    });
    await loadFavorites();
  }

  Future<void> removeFavorite(int id) async {
    await _db.deleteFavorite(id);
    await loadFavorites();
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier();
});
