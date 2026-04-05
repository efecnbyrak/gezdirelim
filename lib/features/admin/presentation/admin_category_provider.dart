import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kategori modeli
class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon = 'mapPin',
    required this.createdAt,
  });
}

/// Kategori State
class CategoryState {
  final List<CategoryModel> categories;

  CategoryState({this.categories = const []});

  CategoryState copyWith({List<CategoryModel>? categories}) {
    return CategoryState(categories: categories ?? this.categories);
  }
}

/// Kategori Notifier — Single Responsibility
class AdminCategoryNotifier extends StateNotifier<CategoryState> {
  AdminCategoryNotifier() : super(CategoryState()) {
    _initDefaults();
  }

  void _initDefaults() {
    state = state.copyWith(
      categories: [
        CategoryModel(id: '1', name: 'Gezilecek', icon: 'mapPin', createdAt: DateTime.now().toIso8601String()),
        CategoryModel(id: '2', name: 'Yemek', icon: 'utensils', createdAt: DateTime.now().toIso8601String()),
        CategoryModel(id: '3', name: 'Konaklama', icon: 'hotel', createdAt: DateTime.now().toIso8601String()),
        CategoryModel(id: '4', name: 'Eğlence', icon: 'music', createdAt: DateTime.now().toIso8601String()),
        CategoryModel(id: '5', name: 'Doğa', icon: 'trees', createdAt: DateTime.now().toIso8601String()),
      ],
    );
  }

  void addCategory(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newCat = CategoryModel(
      id: id,
      name: name,
      createdAt: DateTime.now().toIso8601String(),
    );
    state = state.copyWith(
      categories: [...state.categories, newCat],
    );
  }

  void removeCategory(String id) {
    state = state.copyWith(
      categories: state.categories.where((c) => c.id != id).toList(),
    );
  }
}

final adminCategoryProvider =
    StateNotifierProvider<AdminCategoryNotifier, CategoryState>((ref) {
  return AdminCategoryNotifier();
});
