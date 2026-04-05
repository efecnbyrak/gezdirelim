import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/features/admin/presentation/admin_category_provider.dart';
import 'package:gezdirelim/features/admin/presentation/admin_log_provider.dart';
import 'package:gezdirelim/features/admin/presentation/admin_route_provider.dart';

// Re-export separated models for backward compatibility
export 'package:gezdirelim/features/admin/presentation/admin_category_provider.dart'
    show CategoryModel, CategoryState, AdminCategoryNotifier, adminCategoryProvider;
export 'package:gezdirelim/features/admin/presentation/admin_log_provider.dart'
    show UserLog, LogState, AdminLogNotifier, adminLogProvider;
export 'package:gezdirelim/features/admin/presentation/admin_route_provider.dart'
    show DestinationModel, DestinationState, AdminRouteNotifier, adminRouteProvider;

// ==========================================
// AUTH STATE (Sadece admin kimlik doğrulama)
// ==========================================

class AdminAuthState {
  final bool isAuthenticated;

  AdminAuthState({this.isAuthenticated = false});

  AdminAuthState copyWith({bool? isAuthenticated}) {
    return AdminAuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated);
  }
}

class AdminAuthNotifier extends StateNotifier<AdminAuthState> {
  AdminAuthNotifier() : super(AdminAuthState());

  bool login(String username, String password) {
    if (username == 'phyberk' && password == 'phyberk123') {
      state = state.copyWith(isAuthenticated: true);
      return true;
    }
    return false;
  }

  void logout() {
    state = state.copyWith(isAuthenticated: false);
  }
}

final adminAuthProvider =
    StateNotifierProvider<AdminAuthNotifier, AdminAuthState>((ref) {
  return AdminAuthNotifier();
});

// ==========================================
// BACKWARD COMPAT — Legacy adminProvider
// ==========================================

/// Backward-compatible combined state for screens that still use adminProvider
class AdminState {
  final bool isAuthenticated;
  final List<CategoryModel> categories;
  final List<UserLog> logs;
  final List<DestinationModel> destinations;
  final bool isLoading;

  AdminState({
    this.isAuthenticated = false,
    this.categories = const [],
    this.logs = const [],
    this.destinations = const [],
    this.isLoading = false,
  });
}

/// Combined provider for backward compatibility
final adminProvider = Provider<AdminState>((ref) {
  final auth = ref.watch(adminAuthProvider);
  final cats = ref.watch(adminCategoryProvider);
  final logs = ref.watch(adminLogProvider);
  final routes = ref.watch(adminRouteProvider);

  return AdminState(
    isAuthenticated: auth.isAuthenticated,
    categories: cats.categories,
    logs: logs.logs,
    destinations: routes.destinations,
  );
});
