import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/database_helper.dart';

/// Rota modeli
class RouteModel {
  final int? id;
  final String name;
  final String description;
  final String createdAt;
  final List<StopModel> stops;

  RouteModel({
    this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    this.stops = const [],
  });

  RouteModel copyWith({
    int? id,
    String? name,
    String? description,
    String? createdAt,
    List<StopModel>? stops,
  }) {
    return RouteModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      stops: stops ?? this.stops,
    );
  }
}

/// Durak modeli
class StopModel {
  final int? id;
  final int routeId;
  final String title;
  final String category;
  final double latitude;
  final double longitude;
  final int order;

  StopModel({
    this.id,
    required this.routeId,
    required this.title,
    this.category = '',
    this.latitude = 0,
    this.longitude = 0,
    this.order = 0,
  });
}

/// Rota yönetimi state'i
class RouteManagementState {
  final List<RouteModel> routes;
  final int? selectedRouteId;
  final bool isLoading;

  RouteManagementState({
    this.routes = const [],
    this.selectedRouteId,
    this.isLoading = false,
  });

  RouteManagementState copyWith({
    List<RouteModel>? routes,
    int? selectedRouteId,
    bool? isLoading,
    bool clearSelection = false,
  }) {
    return RouteManagementState(
      routes: routes ?? this.routes,
      selectedRouteId: clearSelection ? null : (selectedRouteId ?? this.selectedRouteId),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  RouteModel? get selectedRoute {
    if (selectedRouteId == null) return null;
    try {
      return routes.firstWhere((r) => r.id == selectedRouteId);
    } catch (_) {
      return null;
    }
  }
}

/// Rota yönetimi notifier
class RouteManagementNotifier extends StateNotifier<RouteManagementState> {
  final DatabaseHelper _db = DatabaseHelper();

  RouteManagementNotifier() : super(RouteManagementState()) {
    loadRoutes();
  }

  /// Tüm rotaları ve duraklarını yükle
  Future<void> loadRoutes() async {
    state = state.copyWith(isLoading: true);
    try {
      final routeMaps = await _db.getRoutes();
      final routes = <RouteModel>[];

      for (final routeMap in routeMaps) {
        final stopMaps = await _db.getStopsForRoute(routeMap['id'] as int);
        final stops = stopMaps.map((s) => StopModel(
          id: s['id'] as int,
          routeId: s['route_id'] as int,
          title: s['title'] as String,
          category: s['category'] as String? ?? '',
          latitude: (s['latitude'] as num?)?.toDouble() ?? 0,
          longitude: (s['longitude'] as num?)?.toDouble() ?? 0,
          order: s['stop_order'] as int? ?? 0,
        )).toList();

        routes.add(RouteModel(
          id: routeMap['id'] as int,
          name: routeMap['name'] as String,
          description: routeMap['description'] as String? ?? '',
          createdAt: routeMap['created_at'] as String,
          stops: stops,
        ));
      }

      state = state.copyWith(
        routes: routes,
        isLoading: false,
        selectedRouteId: routes.isNotEmpty
            ? (state.selectedRouteId ?? routes.first.id)
            : null,
        clearSelection: routes.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Rota seç
  void selectRoute(int routeId) {
    state = state.copyWith(selectedRouteId: routeId);
  }

  /// Yeni rota ekle
  Future<void> addRoute(String name, {String description = ''}) async {
    final id = await _db.insertRoute({
      'name': name,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    });
    await loadRoutes();
    state = state.copyWith(selectedRouteId: id);
  }

  /// Rota sil (tüm duraklar dahil)
  Future<void> deleteRoute(int routeId) async {
    await _db.deleteRoute(routeId);
    await loadRoutes();
  }

  /// Rotaya durak ekle
  Future<void> addStop(int routeId, String title, {String category = 'Durak', double lat = 0, double lng = 0}) async {
    final stops = await _db.getStopsForRoute(routeId);
    await _db.insertStop({
      'route_id': routeId,
      'title': title,
      'category': category,
      'latitude': lat,
      'longitude': lng,
      'stop_order': stops.length,
    });
    await loadRoutes();
  }

  /// Durak sil
  Future<void> deleteStop(int stopId) async {
    await _db.deleteStop(stopId);
    await loadRoutes();
  }

  /// Durak konumunu güncelle (Map Editor için)
  Future<void> updateStopPosition(int stopId, double lat, double lng) async {
    await _db.updateStop(stopId, {
      'latitude': lat,
      'longitude': lng,
    });
    await loadRoutes();
  }
}

/// Provider
final routeManagementProvider = StateNotifierProvider<RouteManagementNotifier, RouteManagementState>((ref) {
  return RouteManagementNotifier();
});
