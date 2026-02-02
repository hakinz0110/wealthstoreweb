import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/features/categories/data/category_repository.dart';
import 'package:wealth_app/features/categories/domain/category_state.dart';
import 'package:wealth_app/shared/models/category.dart';

part 'category_notifier.g.dart';

@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  @override
  CategoryState build() {
    return CategoryState.initial();
  }

  /// Load all active categories
  Future<void> loadCategories() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(categoryRepositoryProvider);
      final categories = await repository.getActiveCategories();
      
      state = state.copyWith(
        isLoading: false,
        categories: categories,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Search categories
  Future<void> searchCategories(String query) async {
    if (query.isEmpty) {
      await loadCategories();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(categoryRepositoryProvider);
      final categories = await repository.searchCategories(query);
      
      state = state.copyWith(
        isLoading: false,
        categories: categories,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get category by ID
  Future<Category?> getCategoryById(int id) async {
    try {
      final repository = ref.read(categoryRepositoryProvider);
      return await repository.getCategory(id);
    } catch (e) {
      return null;
    }
  }

  /// Refresh categories
  Future<void> refresh() async {
    await loadCategories();
  }
}