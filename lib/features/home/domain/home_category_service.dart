import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/core/services/category_service.dart';
import 'package:wealth_app/features/home/domain/home_category_model.dart';
import 'package:wealth_app/shared/models/category.dart';

part 'home_category_service.g.dart';

class HomeCategoryService {
  final CategoryService _categoryService;

  HomeCategoryService(this._categoryService);

  /// Get categories for home screen display
  /// Returns all active categories from database
  Future<List<Category>> getPopularCategories() async {
    try {
      // Get active categories with product counts from database
      final categories = await _categoryService.getCategoriesWithProductCount();
      
      // Only include active categories (show all, even those without products)
      final filteredCategories = categories
          .where((category) => category.isActive)
          .toList();
      
      return filteredCategories;
    } catch (e) {
      // On error, return empty list
      return [];
    }
  }

  /// Get category by ID for navigation
  Future<Category?> getCategoryById(int id) async {
    try {
      return await _categoryService.getCategoryById(id.toString());
    } catch (e) {
      return null;
    }
  }

  /// Check if a category name matches any available categories
  bool isPopularCategory(String categoryName) {
    // This method is kept for backward compatibility but is no longer used
    // since we now use dynamic categories from the database
    return false;
  }
}

@riverpod
HomeCategoryService homeCategoryService(HomeCategoryServiceRef ref) {
  return HomeCategoryService(ref.watch(categoryServiceProvider));
}

@riverpod
Future<List<HomeCategory>> popularCategories(PopularCategoriesRef ref) async {
  final service = ref.watch(homeCategoryServiceProvider);
  final categories = await service.getPopularCategories();
  
  // Convert Category to HomeCategory
  return categories.map((category) => HomeCategory.fromCategory(category)).toList();
}