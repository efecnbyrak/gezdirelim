import 'package:supabase_flutter/supabase_flutter.dart';


class SupabaseService {
  SupabaseService._();
  static final SupabaseClient client = Supabase.instance.client;

  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;

  static SupabaseService get instance => _instance;

  // Use client directly for more concise code
  SupabaseClient get _supabase => client;

  // Auth Methods
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password, {Map<String, dynamic>? data}) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  // Database Methods - Profiles
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    await _supabase.from('profiles').update(updates).eq('id', userId);
  }

  // Database Methods - Favorites
  Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    final response = await _supabase
        .from('favorites')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addFavorite(String userId, Map<String, dynamic> destinationData) async {
    await _supabase.from('favorites').insert({
      'user_id': userId,
      ...destinationData,
    });
  }

  Future<void> removeFavorite(String userId, String destinationId) async {
    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('destination_id', destinationId);
  }
}
