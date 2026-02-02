import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/core/exceptions/app_exceptions.dart';
import 'package:wealth_app/core/services/product_image_service.dart';
import 'package:wealth_app/features/products/data/product_repository.dart';
import 'package:wealth_app/features/products/domain/product_filter_state.dart';
import 'package:wealth_app/features/products/domain/product_state.dart';
import 'package:wealth_app/shared/models/product.dart';

part 'product_notifier.g.dart';

@riverpod
class ProductNotifier extends _$ProductNotifier {
  static const int pageSize = 20;

  @override
  ProductState build() {
    // Load products right away
    Future.microtask(() => loadProducts());
    return ProductState.initial();
  }

  Future<void> loadProducts({int? categoryId}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);
    try {
      // Load products with category filter applied at database level
      final products = await ref.read(productRepositoryProvider).getProducts(
        limit: pageSize,
        offset: 0,
        categoryId: categoryId, // Apply category filter at database level
      );
      
      // Update price range based on actual products
      if (products.isNotEmpty) {
        double min = products[0].price;
        double max = products[0].price;
        
        for (final product in products) {
          if (product.price < min) min = product.price;
          if (product.price > max) max = product.price;
        }
        
        // Update filter state with new price range
        final updatedFilterState = state.filterState.copyWith(
          currentMinPrice: min,
          currentMaxPrice: max,
        );
        
        state = state.copyWith(
          products: products,
          isLoading: false,
          error: null,
          currentPage: 0,
          hasMore: products.length >= pageSize,
          minPrice: min,
          maxPrice: max,
          filterState: updatedFilterState,
          filteredProducts: applyFilters(products, updatedFilterState),
        );

      } else {
        state = state.copyWith(
          products: [],
          isLoading: false, 
          error: 'No products found in database. Please add some products to your Supabase products table.',
          currentPage: 0,
          hasMore: false,
          filteredProducts: [],
        );
      }
    } on DatabaseException catch (e) {
      debugPrint('❌ Database error loading products: ${e.message}');
      state = ProductState.error('Unable to connect to server');
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      state = ProductState.error('Unable to load products');
    }
  }

  Future<void> loadMoreProducts({int? categoryId}) async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    try {
      final nextPage = state.currentPage + 1;
      final offset = nextPage * pageSize;
      
      final moreProducts = await ref.read(productRepositoryProvider).getProducts(
        limit: pageSize,
        offset: offset,
        categoryId: categoryId,
      );
      
      // If we got fewer products than the page size, we've reached the end
      final hasMore = moreProducts.length >= pageSize;
      final allProducts = [...state.products, ...moreProducts];
      
      state = state.copyWith(
        products: allProducts,
        currentPage: nextPage,
        hasMore: hasMore,
        isLoading: false,
        filteredProducts: applyFilters(allProducts, state.filterState),
      );
    } catch (e) {
      debugPrint('❌ Error loading more products: $e');
      state = state.copyWith(
        isLoading: false,
        error: "Unable to load more products",
      );
    }
  }

  Future<void> getProduct(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final product = await ref.read(productRepositoryProvider).getProduct(id);
      state = state.copyWith(
        selectedProduct: product,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('❌ Error loading product details: $e');
      state = state.copyWith(
        isLoading: false,
        error: "Unable to load product details",
      );
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) {
      // Reset filters and load all products
      updateFilters(state.filterState.copyWith(
        searchQuery: null,
        categoryId: null,
        categoryName: null,
      ));
      await loadProducts();
      return state.products;
    }

    state = state.copyWith(isLoading: true);
    try {
      final products = await ref.read(productRepositoryProvider).searchProducts(query);
      
      // Update filter state
      final newFilterState = state.filterState.copyWith(searchQuery: query);
      
      state = state.copyWith(
        products: products,
        isLoading: false,
        filterState: newFilterState,
        filteredProducts: applyFilters(products, newFilterState),
      );
      
      return products;
    } catch (e) {
      debugPrint('❌ Error searching products: $e');
      state = state.copyWith(
        isLoading: false,
        error: "Unable to search products",
      );
      return [];
    }
  }

  void updateFilters(ProductFilterState filterState) {
    state = state.copyWith(
      filterState: filterState,
      filteredProducts: applyFilters(state.products, filterState),
    );
  }

  // Apply filters to the product list
  List<Product> applyFilters(List<Product> products, ProductFilterState filters) {
    List<Product> filtered = List.from(products);
    
    // Apply category filter
    if (filters.categoryId != null) {
      filtered = filtered.where((p) => p.categoryId == filters.categoryId).toList();
    }
    
    // Apply price filter
    filtered = filtered.where((p) => 
      p.price >= filters.currentMinPrice && p.price <= filters.currentMaxPrice
    ).toList();
    
    // Apply search filter
    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      final query = filters.searchQuery!.toLowerCase();
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(query) || 
        p.description.toLowerCase().contains(query)
      ).toList();
    }
    
    // Apply sort
    switch (filters.sortOption) {
      case ProductSortOption.priceAsc:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceDesc:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.nameAsc:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProductSortOption.nameDesc:
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case ProductSortOption.newest:
        filtered.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(2000);
          final bDate = b.createdAt ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });
        break;
      case ProductSortOption.popular:
        // Implement when you have rating or view count data
        break;
    }
    
    return filtered;
  }

  // Set category filter
  void setCategory(int? categoryId, String? categoryName) {
    final newFilterState = state.filterState.copyWith(
      categoryId: categoryId,
      categoryName: categoryName ?? (categoryId == null ? 'All Products' : null),
    );
    
    // Update filter state and reload products from database with category filter
    state = state.copyWith(filterState: newFilterState);
    loadProducts(categoryId: categoryId);
  }
  
  // Set price range
  void setPriceRange(double min, double max) {
    updateFilters(state.filterState.copyWith(
      currentMinPrice: min,
      currentMaxPrice: max,
    ));
  }
  
  // Set sort option
  void setSortOption(ProductSortOption sortOption) {
    updateFilters(state.filterState.copyWith(sortOption: sortOption));
  }
} 