import 'dart:async';

/// Web ve test ortamı uyumlu In-Memory Database Helper
/// sqflite web desteklemediği için şimdilik verileri hafızada tutuyoruz.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // In-memory data storage
  final List<Map<String, dynamic>> _users = [];
  final List<Map<String, dynamic>> _routes = [];
  final List<Map<String, dynamic>> _stops = [];
  final List<Map<String, dynamic>> _favorites = [];

  int _userIdCounter = 1;
  int _routeIdCounter = 1;
  int _stopIdCounter = 1;
  int _favoriteIdCounter = 1;

  // Initialize fake database
  Future<void> get database async {
    // Simulate async init if needed
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // --- Users ---
  Future<int> insertUser(Map<String, dynamic> user) async {
    final newUser = Map<String, dynamic>.from(user);
    if (!newUser.containsKey('id')) {
      newUser['id'] = _userIdCounter++;
    }
    _users.add(newUser);
    return newUser['id'] as int;
  }

  Future<Map<String, dynamic>?> getUser() async {
    if (_users.isNotEmpty) {
      return _users.first;
    }
    return null;
  }

  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    final index = _users.indexWhere((u) => u['id'] == id);
    if (index != -1) {
      final updatedUser = Map<String, dynamic>.from(_users[index]);
      user.forEach((key, value) {
        updatedUser[key] = value;
      });
      _users[index] = updatedUser;
      return 1; // 1 row updated
    }
    return 0;
  }

  // --- Routes ---
  Future<int> insertRoute(Map<String, dynamic> route) async {
    final newRoute = Map<String, dynamic>.from(route);
    if (!newRoute.containsKey('id')) {
      newRoute['id'] = _routeIdCounter++;
    }
    _routes.add(newRoute);
    return newRoute['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getRoutes() async {
    return List<Map<String, dynamic>>.from(_routes);
  }

  Future<int> deleteRoute(int id) async {
    _routes.removeWhere((r) => r['id'] == id);
    _stops.removeWhere((s) => s['route_id'] == id); // Cascade delete stops
    return 1;
  }

  Future<int> getRouteCount() async {
    return _routes.length;
  }

  // --- Stops ---
  Future<int> insertStop(Map<String, dynamic> stop) async {
    final newStop = Map<String, dynamic>.from(stop);
    if (!newStop.containsKey('id')) {
      newStop['id'] = _stopIdCounter++;
    }
    _stops.add(newStop);
    return newStop['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getStopsForRoute(int routeId) async {
    return _stops.where((s) => s['route_id'] == routeId).toList();
  }

  Future<int> deleteStop(int id) async {
    int count = 0;
    _stops.removeWhere((s) {
      if (s['id'] == id) {
        count++;
        return true;
      }
      return false;
    });
    return count;
  }

  // --- Favorites ---
  Future<int> insertFavorite(Map<String, dynamic> favorite) async {
    final newFav = Map<String, dynamic>.from(favorite);
    if (!newFav.containsKey('id')) {
      newFav['id'] = _favoriteIdCounter++;
    }
    _favorites.add(newFav);
    return newFav['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getFavoritesByType(String type) async {
    return _favorites.where((f) => f['type'] == type).toList();
  }

  Future<int> deleteFavorite(int id) async {
    int count = 0;
    _favorites.removeWhere((f) {
      if (f['id'] == id) {
        count++;
        return true;
      }
      return false;
    });
    return count;
  }

  Future<int> getFavoriteCount() async {
    return _favorites.length;
  }
}
