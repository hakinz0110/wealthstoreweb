import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/auth_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';

part 'favorites_repository.g.dart';

@riverpod
FavoritesRepository favoritesRepository(FavoritesRepositoryRef ref) {
  return FavoritesRepository();
}

class FavoriteProduct {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final double? productPrice;
  final String? productImageUrl;
  final String? productCategory;
  final String? productBrand;
  final String wishlistCategory;
  final int priority;
  final String? notes;
  final double? targetPrice;
  final bool priceAlertEnabled;
  final bool isAvailable;
  final bool isOnSale;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FavoriteProduct({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    this.productPrice,
    this.productImageUrl,
    this.productCategory,
    this.productBrand,
    this.wishlistCategory = 'general',
    this.priority = 1,
    this.notes,
    this.targetPrice,
    this.priceAlertEnabled = false,
    this.isAvailable = true,
    this.isOnSale = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) {
    return FavoriteProduct(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productPrice: (json['product_price'] as num?)?.toDouble(),
      productImageUrl: json['product_image_url'] as String?,
      productCategory: json['product_category'] as String?,
      productBrand: json['product_brand'] as String?,
      wishlistCategory: json['wishlist_category'] as String? ?? 'general',
      priority: json['priority'] as int? ?? 1,
      notes: json['notes'] as String?,
      targetPrice: (json['target_price'] as num?)?.toDouble(),
      priceAlertEnabled: json['price_alert_enabled'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
      isOnSale: json['is_on_sale'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'product_image_url': productImageUrl,
      'product_category': productCategory,
      'product_brand': productBrand,
      'wishlist_category': wishlistCategory,
      'priority': priority,
      'notes': notes,
      'target_price': targetPrice,
      'price_alert_enabled': priceAlertEnabled,
      'is_available': isAvailable,
      'is_on_sale': isOnSale,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FavoriteProduct copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productName,
    double? productPrice,
    String? productImageUrl,
    String? productCategory,
    String? productBrand,
    String? wishlistCategory,
    int? priority,
    String? notes,
    double? targetPrice,
    bool? priceAlertEnabled,
    bool? isAvailable,
    bool? isOnSale,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FavoriteProduct(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      productCategory: productCategory ?? this.productCategory,
      productBrand: productBrand ?? this.productBrand,
      wishlistCategory: wishlistCategory ?? this.wishlistCategory,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      targetPrice: targetPrice ?? this.targetPrice,
      priceAlertEnabled: priceAlertEnabled ?? this.priceAlertEnabled,
      isAvailable: isAvailable ?? this.isAvailable,
      isOnSale: isOnSale ?? this.isOnSale,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FavoritesRepository {
  final SupabaseClient _supabase = AuthService.client;

  String? get _currentUserId => AuthService.currentUser?.id;

  // Get all favorite products
  Future<List<FavoriteProduct>> getFavoriteProducts({
    String? category,
    int? limit,
    int? offset,
  }) async {
    try {
      if (_currentUserId == null) return [];

      var queryBuilder = _supabase
          .from('favorite_products')
          .select('*')
          .eq('user_id', _currentUserId!);

      if (category != null && category.isNotEmpty) {
        queryBuilder = queryBuilder.eq('wishlist_category', category);
      }

      var orderedQuery = queryBuilder.order('created_at', ascending: false);

      if (limit != null) {
        orderedQuery = orderedQuery.limit(limit);
      }

      if (offset != null) {
        orderedQuery = orderedQuery.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await orderedQuery;

      return (response as List<dynamic>)
          .map((item) => FavoriteProduct.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DataException('Failed to load favorite products: $e');
    }
  }

  // Check if product is in favorites
  Future<bool> isProductFavorite(String productId) async {
    try {
      if (_currentUserId == null) return false;

      final response = await _supabase
          .from('favorite_products')
          .select('id')
          .eq('user_id', _currentUserId!)
          .eq('product_id', productId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Add product to favorites
  Future<FavoriteProduct> addToFavorites({
    required String productId,
    required String productName,
    double? productPrice,
    String? productImageUrl,
    String? productCategory,
    String? productBrand,
    String wishlistCategory = 'general',
    int priority = 1,
    String? notes,
    double? targetPrice,
    bool priceAlertEnabled = false,
  }) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      final favoriteData = {
        'user_id': _currentUserId!,
        'product_id': productId,
        'product_name': productName,
        'product_price': productPrice,
        'product_image_url': productImageUrl,
        'product_category': productCategory,
        'product_brand': productBrand,
        'wishlist_category': wishlistCategory,
        'priority': priority,
        'notes': notes,
        'target_price': targetPrice,
        'price_alert_enabled': priceAlertEnabled,
        'is_available': true,
        'is_on_sale': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('favorite_products')
          .insert(favoriteData)
          .select()
          .single();

      return FavoriteProduct.fromJson(response);
    } catch (e) {
      throw DataException('Failed to add product to favorites: $e');
    }
  }

  // Remove product from favorites
  Future<void> removeFromFavorites(String productId) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      await _supabase
          .from('favorite_products')
          .delete()
          .eq('user_id', _currentUserId!)
          .eq('product_id', productId);
    } catch (e) {
      throw DataException('Failed to remove product from favorites: $e');
    }
  }

  // Update favorite product
  Future<FavoriteProduct> updateFavorite({
    required String productId,
    String? wishlistCategory,
    int? priority,
    String? notes,
    double? targetPrice,
    bool? priceAlertEnabled,
  }) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (wishlistCategory != null) updateData['wishlist_category'] = wishlistCategory;
      if (priority != null) updateData['priority'] = priority;
      if (notes != null) updateData['notes'] = notes;
      if (targetPrice != null) updateData['target_price'] = targetPrice;
      if (priceAlertEnabled != null) updateData['price_alert_enabled'] = priceAlertEnabled;

      final response = await _supabase
          .from('favorite_products')
          .update(updateData)
          .eq('user_id', _currentUserId!)
          .eq('product_id', productId)
          .select()
          .single();

      return FavoriteProduct.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update favorite product: $e');
    }
  }

  // Get favorite products by category
  Future<List<FavoriteProduct>> getFavoritesByCategory(String category) async {
    return getFavoriteProducts(category: category);
  }

  // Get favorite products with price alerts enabled
  Future<List<FavoriteProduct>> getFavoritesWithPriceAlerts() async {
    try {
      if (_currentUserId == null) return [];

      final response = await _supabase
          .from('favorite_products')
          .select('*')
          .eq('user_id', _currentUserId!)
          .eq('price_alert_enabled', true)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((item) => FavoriteProduct.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DataException('Failed to load favorites with price alerts: $e');
    }
  }

  // Get wishlist categories
  Future<List<String>> getWishlistCategories() async {
    try {
      if (_currentUserId == null) return [];

      final response = await _supabase
          .from('favorite_products')
          .select('wishlist_category')
          .eq('user_id', _currentUserId!);

      final categories = (response as List<dynamic>)
          .map((item) => item['wishlist_category'] as String)
          .toSet()
          .toList();

      return categories;
    } catch (e) {
      throw DataException('Failed to load wishlist categories: $e');
    }
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      await _supabase
          .from('favorite_products')
          .delete()
          .eq('user_id', _currentUserId!);
    } catch (e) {
      throw DataException('Failed to clear favorites: $e');
    }
  }

  // Clear favorites by category
  Future<void> clearFavoritesByCategory(String category) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      await _supabase
          .from('favorite_products')
          .delete()
          .eq('user_id', _currentUserId!)
          .eq('wishlist_category', category);
    } catch (e) {
      throw DataException('Failed to clear favorites by category: $e');
    }
  }

  // Get favorites count
  Future<int> getFavoritesCount() async {
    try {
      if (_currentUserId == null) return 0;

      final response = await _supabase
          .from('favorite_products')
          .select('id')
          .eq('user_id', _currentUserId!);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // Watch favorites changes (for real-time updates)
  Stream<List<FavoriteProduct>> watchFavorites() {
    if (_currentUserId != null) {
      return _supabase
          .from('favorite_products')
          .stream(primaryKey: ['id'])
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false)
          .map((data) => data.map((item) => FavoriteProduct.fromJson(item)).toList());
    } else {
      return Stream.value([]);
    }
  }
}