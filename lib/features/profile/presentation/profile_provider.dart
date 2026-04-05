import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Profil state'i
class ProfileState {
  final String? userId;
  final String name;
  final String email;
  final String bio;
  final String city;
  final String district;
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
    this.district = '',
    this.photoPath = '',
    this.routeCount = 0,
    this.favoriteCount = 0,
    this.isDarkMode = true,
    this.notificationsEnabled = true,
    this.language = 'Türkçe',
    this.isLoading = false,
  });

  ProfileState copyWith({
    String? userId,
    String? name,
    String? email,
    String? bio,
    String? city,
    String? district,
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
      district: district ?? this.district,
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
  final SupabaseService _supabase = SupabaseService.instance;
  static const String _themeKey = 'is_dark_mode';
  static const String _langKey = 'app_language';

  ProfileNotifier() : super(ProfileState()) {
    _initPrefsAndLoad();
  }

  Future<void> _initAppPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? true;
    final lang = prefs.getString(_langKey) ?? 'Türkçe';
    state = state.copyWith(isDarkMode: isDark, language: lang);
  }

  Future<void> _initPrefsAndLoad() async {
    await _initAppPrefs();
    await loadProfile();
  }

  Future<void> loadProfile() async {
    final user = _supabase.currentUser;
    if (user == null) {
      debugPrint('[ProfileNotifier] loadProfile: No authenticated user');
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final userData = await _supabase.getProfile(user.id);

      if (userData != null) {
        state = state.copyWith(
          userId: user.id,
          name: userData['name'] as String? ??
              user.userMetadata?['display_name'] as String? ??
              'Gezgin',
          email: user.email ?? '',
          bio: userData['bio'] as String? ?? '',
          city: userData['city'] as String? ?? '',
          district: userData['district'] as String? ?? '',
          photoPath: userData['photo_path'] as String? ?? '',
          // Sync theme/lang if they exist in Supabase (Single Source of Truth)
          isDarkMode: userData['is_dark_mode'] as bool? ?? state.isDarkMode,
          language: userData['language'] as String? ?? state.language,
          isLoading: false,
        );
        // Persist to local for next start
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_themeKey, state.isDarkMode);
        await prefs.setString(_langKey, state.language);
      } else {
        state = state.copyWith(
          userId: user.id,
          name: user.userMetadata?['display_name'] as String? ?? 'Gezgin',
          email: user.email ?? '',
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('[ProfileNotifier] loadProfile error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? bio,
    String? city,
    String? district,
  }) async {
    if (state.userId == null) {
      debugPrint('[ProfileNotifier] updateProfile: userId is null');
      throw Exception('Kullanıcı doğrulanmamış');
    }

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (bio != null) updates['bio'] = bio;
    if (city != null) updates['city'] = city;
    if (district != null) updates['district'] = district;

    try {
      await _supabase.updateProfile(state.userId!, updates);
      state = state.copyWith(
        name: name ?? state.name,
        bio: bio ?? state.bio,
        city: city ?? state.city,
        district: district ?? state.district,
      );
    } catch (e) {
      debugPrint('[ProfileNotifier] updateProfile error: $e');
      rethrow;
    }
  }

  Future<void> updatePhoto(String path) async {
    if (state.userId == null) {
      debugPrint('[ProfileNotifier] updatePhoto: userId is null');
      throw Exception('Kullanıcı doğrulanmamış');
    }

    try {
      await _supabase.updateProfile(state.userId!, {'photo_path': path});
      state = state.copyWith(photoPath: path);
    } catch (e) {
      debugPrint('[ProfileNotifier] updatePhoto error: $e');
      rethrow;
    }
  }

  Future<void> toggleDarkMode() async {
    final newValue = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newValue);

    // Persist locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newValue);

    // Persist to Supabase if logged in
    if (state.userId != null) {
      try {
        await _supabase.updateProfile(state.userId!, {'is_dark_mode': newValue});
      } catch (e) {
        debugPrint('Supabase theme sync fail: $e');
      }
    }
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }

  Future<void> setLanguage(String lang) async {
    state = state.copyWith(language: lang);

    // Persist locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang);

    // Persist to Supabase if logged in
    if (state.userId != null) {
      try {
        await _supabase.updateProfile(state.userId!, {'language': lang});
      } catch (e) {
        debugPrint('Supabase language sync fail: $e');
      }
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
