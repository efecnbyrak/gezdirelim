import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/database_helper.dart';

/// Profil state'i
class ProfileState {
  final int? userId;
  final String name;
  final String email;
  final String bio;
  final String city;
  final String photoPath;
  final int routeCount;
  final int favoriteCount;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String language;
  final bool isLoading;

  ProfileState({
    this.userId,
    this.name = 'Gezgin',
    this.email = '',
    this.bio = '',
    this.city = '',
    this.photoPath = '',
    this.routeCount = 0,
    this.favoriteCount = 0,
    this.isDarkMode = true,
    this.notificationsEnabled = true,
    this.language = 'Türkçe',
    this.isLoading = false,
  });

  ProfileState copyWith({
    int? userId,
    String? name,
    String? email,
    String? bio,
    String? city,
    String? photoPath,
    int? routeCount,
    int? favoriteCount,
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? language,
    bool? isLoading,
  }) {
    return ProfileState(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      photoPath: photoPath ?? this.photoPath,
      routeCount: routeCount ?? this.routeCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Profil notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final DatabaseHelper _db = DatabaseHelper();

  ProfileNotifier() : super(ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final userData = await _db.getUser();
      final routeCount = await _db.getRouteCount();
      final favoriteCount = await _db.getFavoriteCount();

      if (userData != null) {
        state = state.copyWith(
          userId: userData['id'] as int,
          name: userData['name'] as String,
          email: userData['email'] as String,
          bio: userData['bio'] as String? ?? '',
          city: userData['city'] as String? ?? '',
          photoPath: userData['photo_path'] as String? ?? '',
          routeCount: routeCount,
          favoriteCount: favoriteCount,
          isLoading: false,
        );
      } else {
        // Varsayılan kullanıcı oluştur
        final id = await _db.insertUser({
          'name': 'Gezgin',
          'email': 'gezgin@gezdirelim.com',
          'bio': 'Dünyayı keşfetmeyi seviyorum',
          'city': 'İstanbul',
          'photo_path': '',
          'created_at': DateTime.now().toIso8601String(),
        });
        state = state.copyWith(
          userId: id,
          name: 'Gezgin',
          email: 'gezgin@gezdirelim.com',
          bio: 'Dünyayı keşfetmeyi seviyorum',
          city: 'İstanbul',
          routeCount: routeCount,
          favoriteCount: favoriteCount,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? bio,
    String? city,
  }) async {
    if (state.userId == null) return;
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (bio != null) updates['bio'] = bio;
    if (city != null) updates['city'] = city;

    await _db.updateUser(state.userId!, updates);
    state = state.copyWith(
      name: name ?? state.name,
      email: email ?? state.email,
      bio: bio ?? state.bio,
      city: city ?? state.city,
    );
  }

  Future<void> updatePhoto(String path) async {
    if (state.userId == null) return;
    await _db.updateUser(state.userId!, {'photo_path': path});
    state = state.copyWith(photoPath: path);
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }

  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
