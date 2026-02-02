import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/core/services/category_service.dart';
import 'package:wealth_app/shared/models/category.dart';

part 'category_repository.g.dart';

@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  final categoryService = ref.watch(categoryServiceProvider);
  return CategoryRepository(categoryService);
}

class CategoryRepository {
  final CategoryService _categoryService;

  CategoryRepository(this._categoryService);

  /// Get all active categories
  Future<List<Category>> getActiveCategories() async {
    try {
      return await _categoryService.getActiveCategories();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Get categories with product count
  Future<List<Map<String, dynamic>>> getCategoriesWithProductCount() async {
    try {
      final categories = await _categoryService.getCategoriesWithProductCount();
      return categories.map((category) => category.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories with product count: $e');
    }
  }

  /// Get category by ID
  Future<Category?> getCategory(int id) async {
    try {
      return await _categoryService.getCategoryById(id.toString());
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }

  /// Search categories
  Future<List<Category>> searchCategories(String query) async {
    try {
      return await _categoryService.searchCategories(query);
    } catch (e) {
      throw Exception('Failed to search categories: $e');
    }
  }
}