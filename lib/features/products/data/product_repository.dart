import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/core/exceptions/app_exceptions.dart';
import 'package:wealth_app/shared/models/product.dart';

part 'product_repository.g.dart';

class ProductRepository {
  final SupabaseClient _client;

  ProductRepository(this._client);

  /// Normalize product JSON to handle admin app schema differences
  Map<String, dynamic> _normalizeProductJson(Map<String, dynamic> json) {
    final productJson = Map<String, dynamic>.from(json);
    
    // Remove nested categories data
    productJson.remove('categories');
    
    // Handle product_type: map 'simple' to 'single' for consistency
    if (productJson['product_type'] != null) {
      final type = productJson['product_type'].toString().toLowerCase();
      if (type == 'simple') {
        productJson['product_type'] = 'single';
      }
    }
    
    // Handle variant_matrix -> variants mapping (admin uses variant_matrix)
    // Check variant_matrix FIRST, even if variants exists but is empty
    if (productJson['variant_matrix'] != null) {
      final variantMatrix = productJson['variant_matrix'] as List?;
      if (variantMatrix != null && variantMatrix.isNotEmpty) {
        // Normalize each variant to handle 'image' vs 'image_url'
        final normalizedVariants = variantMatrix.map((v) {
          if (v is Map<String, dynamic>) {
            final variant = Map<String, dynamic>.from(v);
            // Map 'image' field to 'image_url' if needed
            if (variant['image'] != null && variant['image_url'] == null) {
              variant['image_url'] = variant['image'];
            }
            return variant;
          }
          return v;
        }).toList();
        productJson['variants'] = normalizedVariants;
      }
    }
    
    return productJson;
  }

  Future<List<Product>> getProducts({
    int limit = 20,
    int offset = 0,
    int? categoryId,
  }) async {
    try {
      debugPrint('🔍 ProductRepository: Fetching products...');
      debugPrint('   - Limit: $limit, Offset: $offset, CategoryId: $categoryId');
      
      var query = _client
          .from('products')
          .select('*, categories(*)')
          .eq('is_active', true); // Only fetch active products
      
      // Apply category filter if provided
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      
      debugPrint('   - Query built, executing...');
      
      final response = await query
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);
      
      debugPrint('   - Response received: ${response.length} items');
      
      if (response.isEmpty) {
        debugPrint('   ⚠️ No products found in database');
        return [];
      }
      
      debugPrint('   - Parsing products...');
      final products = response.map((json) {
        try {
          final productJson = _normalizeProductJson(json);
          debugPrint('   - Parsing product: ${productJson['name']} (ID: ${productJson['id']})');
          return Product.fromJson(productJson);
        } catch (parseError) {
          debugPrint('   ❌ Error parsing product: $parseError');
          debugPrint('   - Product JSON: $json');
          rethrow;
        }
      }).toList();
      
      debugPrint('   ✅ Successfully loaded ${products.length} products');
      return products;
    } catch (e, stackTrace) {
      debugPrint('   ❌ Error in getProducts: $e');
      debugPrint('   Stack trace: $stackTrace');
      throw DatabaseException('Failed to load products: $e');
    }
  }

  Future<Product?> getProduct(int id) async {
    try {
      final response = await _client
          .from('products')
          .select('*, categories(*)')
          .eq('id', id)
          .eq('is_active', true)  // Only active products
          .maybeSingle();  // Use maybeSingle to handle deleted products gracefully
      
      // Product not found or deleted
      if (response == null) {
        return null;
      }
      
      // Check for soft delete
      final isDeleted = response['is_deleted'] as bool? ?? false;
      if (isDeleted) {
        return null;
      }
      
      final productJson = _normalizeProductJson(response);
      return Product.fromJson(productJson);
    } catch (e) {
      throw DatabaseException('Failed to load product: $e');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _client
          .from('products')
          .select('*, categories(*)')
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .limit(20);
      
      return response.map((json) {
        final productJson = _normalizeProductJson(json);
        return Product.fromJson(productJson);
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to search products: $e');
    }
  }

  /// Get random products across all categories for popular products section
  Future<List<Product>> getRandomProducts({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      debugPrint('🔍 ProductRepository: Fetching random products...');
      debugPrint('   - Limit: $limit, Offset: $offset');
      
      // Fetch products with random ordering
      // Note: Using a random seed based on offset for consistent pagination
      final response = await _client
          .from('products')
          .select('*, categories(*)')
          .eq('is_active', true)
          .range(offset, offset + limit - 1);
      
      debugPrint('   - Response received: ${response.length} items');
      
      if (response.isEmpty) {
        debugPrint('   ⚠️ No products found in database');
        return [];
      }
      
      final products = response.map((json) {
        try {
          final productJson = _normalizeProductJson(json);
          return Product.fromJson(productJson);
        } catch (parseError) {
          debugPrint('   ❌ Error parsing product: $parseError');
          debugPrint('   - Product JSON: $json');
          rethrow;
        }
      }).toList();
      
      // Shuffle the products for randomization
      products.shuffle();
      
      debugPrint('   ✅ Successfully loaded ${products.length} random products');
      return products;
    } catch (e, stackTrace) {
      debugPrint('   ❌ Error in getRandomProducts: $e');
      debugPrint('   Stack trace: $stackTrace');
      throw DatabaseException('Failed to load random products: $e');
    }
  }

  // For future admin functionality
  Future<Product> createProduct(Product product) async {
    try {
      final response = await _client
          .from('products')
          .insert(product.toJson())
          .select()
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to create product: $e');
    }
  }

  // For future admin functionality
  Future<Product> updateProduct(Product product) async {
    try {
      final response = await _client
          .from('products')
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to update product: $e');
    }
  }

  // Soft delete product (recommended for production)
  Future<void> softDeleteProduct(int id) async {
    try {
      await _client
          .from('products')
          .update({'is_deleted': true, 'is_active': false})
          .eq('id', id);
    } catch (e) {
      throw DatabaseException('Failed to delete product: $e');
    }
  }

  // Hard delete product (use with caution - will trigger cleanup)
  Future<void> deleteProduct(int id) async {
    try {
      await _client
          .from('products')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw DatabaseException('Failed to delete product: $e');
    }
  }

  // Restore soft-deleted product
  Future<void> restoreProduct(int id) async {
    try {
      await _client
          .from('products')
          .update({'is_deleted': false, 'is_active': true})
          .eq('id', id);
    } catch (e) {
      throw DatabaseException('Failed to restore product: $e');
    }
  }
}

@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  return ProductRepository(ref.watch(supabaseProvider));
} 