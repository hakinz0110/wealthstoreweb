import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../domain/search_state.dart';
import '../../../core/services/supabase_service.dart';

class SearchRepository {
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 10;

  Future<SearchResults> search(String query) async {
    try {
      // Search products
      final productsResponse = await SupabaseService.client
          .from('products')
          .select('id, name, price, image_url, rating, review_count')
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .eq('is_active', true)
          .limit(20);

      final products = productsResponse.map((item) => SearchResult(
        id: item['id'].toString(),
        title: item['name'],
        type: 'product',
        imageUrl: item['image_url'],
        price: item['price']?.toDouble(),
        rating: item['rating']?.toDouble(),
        reviewCount: item['review_count'],
      )).toList();

      // Search categories
      final categoriesResponse = await SupabaseService.client
          .from('categories')
          .select('id, name, description, icon_url')
          .ilike('name', '%$query%')
          .eq('is_active', true)
          .limit(10);

      final categories = categoriesResponse.map((item) => SearchResult(
        id: item['id'].toString(),
        title: item['name'],
        type: 'category',
        subtitle: item['description'],
        imageUrl: item['icon_url'],
      )).toList();

      // Search brands (if you have a brands table)
      final brands = <SearchResult>[]; // Implement if needed

      return SearchResults(
        products: products,
        categories: categories,
        brands: brands,
        totalCount: products.length + categories.length + brands.length,
      );
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  Future<SearchResults> searchWithFilters(String query, SearchFilters filters) async {
    try {
      // Build query with filters
      var productsQuery = SupabaseService.client
          .from('products')
          .select('id, name, price, image_url, rating, review_count, category_id')
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .eq('is_active', true);

      // Apply filters
      if (filters.categories.isNotEmpty) {
        productsQuery = productsQuery.in_('category_id', filters.categories);
      }

      if (filters.minPrice != null) {
        productsQuery = productsQuery.gte('price', filters.minPrice!);
      }

      if (filters.maxPrice != null) {
        productsQuery = productsQuery.lte('price', filters.maxPrice!);
      }

      if (filters.minRating != null) {
        productsQuery = productsQuery.gte('rating', filters.minRating!);
      }

      if (filters.inStock) {
        productsQuery = productsQuery.gt('stock', 0);
      }

      // Apply sorting
      switch (filters.sortBy) {
        case 'price_low':
          productsQuery = productsQuery.order('price', ascending: true);
          break;
        case 'price_high':
          productsQuery = productsQuery.order('price', ascending: false);
          break;
        case 'rating':
          productsQuery = productsQuery.order('rating', ascending: false);
          break;
        case 'newest':
          productsQuery = productsQuery.order('created_at', ascending: false);
          break;
        default:
          // Relevance - keep default order
          break;
      }

      final productsResponse = await productsQuery.limit(50);

      final products = productsResponse.map((item) => SearchResult(
        id: item['id'].toString(),
        title: item['name'],
        type: 'product',
        imageUrl: item['image_url'],
        price: item['price']?.toDouble(),
        rating: item['rating']?.toDouble(),
        reviewCount: item['review_count'],
      )).toList();

      // Categories and brands search (simplified for filtered search)
      final categories = <SearchResult>[];
      final brands = <SearchResult>[];

      return SearchResults(
        products: products,
        categories: categories,
        brands: brands,
        totalCount: products.length,
      );
    } catch (e) {
      throw Exception('Filtered search failed: $e');
    }
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      // Get suggestions from recent searches and popular products
      final recentSearches = await getRecentSearches();
      final suggestions = recentSearches
          .where((search) => search.toLowerCase().contains(query.toLowerCase()))
          .take(5)
          .toList();

      // Add popular product names as suggestions
      final productsResponse = await SupabaseService.client
          .from('products')
          .select('name')
          .ilike('name', '%$query%')
          .eq('is_active', true)
          .limit(5);

      final productSuggestions = productsResponse
          .map((item) => item['name'] as String)
          .toList();

      suggestions.addAll(productSuggestions);

      return suggestions.take(10).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveSearchQuery(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_searchHistoryKey);
      
      List<String> history = [];
      if (historyJson != null) {
        history = List<String>.from(jsonDecode(historyJson));
      }

      // Remove if already exists
      history.remove(query);
      
      // Add to beginning
      history.insert(0, query);
      
      // Keep only recent items
      if (history.length > _maxHistoryItems) {
        history = history.take(_maxHistoryItems).toList();
      }

      await prefs.setString(_searchHistoryKey, jsonEncode(history));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_searchHistoryKey);
      
      if (historyJson != null) {
        return List<String>.from(jsonDecode(historyJson));
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_searchHistoryKey);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> removeSearchFromHistory(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_searchHistoryKey);
      
      if (historyJson != null) {
        List<String> history = List<String>.from(jsonDecode(historyJson));
        history.remove(query);
        await prefs.setString(_searchHistoryKey, jsonEncode(history));
      }
    } catch (e) {
      // Handle error silently
    }
  }
}

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository();
});