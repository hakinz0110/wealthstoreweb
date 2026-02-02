import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/auth_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';

part 'cart_repository.g.dart';

class CartItem {
  final String? id; // Supabase ID
  final String productId; // Changed to String for consistency
  final String name;
  final double price;
  final String? imageUrl;
  int quantity;
  final String? userId; // For Supabase storage
  final double? shippingRate; // Shipping rate (default 0.08 = 8%)
  final String? variantId; // Variant ID for variable products
  final Map<String, dynamic>? variantAttributes; // e.g., {"size": "M", "color": "Red"}
  bool isSelected; // For selective checkout

  CartItem({
    this.id,
    required this.productId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
    this.userId,
    this.shippingRate,
    this.variantId,
    this.variantAttributes,
    this.isSelected = true, // Default to selected
  });

  double get total => price * quantity;
  double get shipping => price * quantity * (shippingRate ?? 0.08);
  
  // Display name with variant info
  String get displayName {
    if (variantAttributes == null || variantAttributes!.isEmpty) {
      return name;
    }
    
    final attrs = variantAttributes!.entries
        .map((e) => '${e.value}')
        .join(', ');
    return '$name ($attrs)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'product_name': name,
      'price': price,
      'image_url': imageUrl,
      'quantity': quantity,
      'shipping_rate': shippingRate ?? 0.08,
      'variant_id': variantId,
      'variant_attributes': variantAttributes != null ? jsonEncode(variantAttributes) : null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? variantAttrs;
    if (json['variant_attributes'] != null) {
      if (json['variant_attributes'] is String) {
        variantAttrs = jsonDecode(json['variant_attributes']);
      } else {
        variantAttrs = json['variant_attributes'] as Map<String, dynamic>?;
      }
    }
    
    return CartItem(
      id: json['id']?.toString(),
      productId: json['product_id']?.toString() ?? json['productId']?.toString() ?? '',
      name: json['product_name']?.toString() ?? json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      userId: json['user_id']?.toString(),
      shippingRate: (json['shipping_rate'] as num?)?.toDouble() ?? 0.08,
      variantId: json['variant_id']?.toString(),
      variantAttributes: variantAttrs,
    );
  }

  // For backward compatibility with local storage
  Map<String, dynamic> toLocalJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'shippingRate': shippingRate ?? 0.08,
      'variantId': variantId,
      'variantAttributes': variantAttributes,
    };
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    String? imageUrl,
    int? quantity,
    String? userId,
    double? shippingRate,
    String? variantId,
    Map<String, dynamic>? variantAttributes,
    bool? isSelected,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      userId: userId ?? this.userId,
      shippingRate: shippingRate ?? this.shippingRate,
      variantId: variantId ?? this.variantId,
      variantAttributes: variantAttributes ?? this.variantAttributes,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class CartRepository {
  static const String _cartKey = 'cart_items';
  final SupabaseClient _supabase = AuthService.client;

  // Get current user ID
  String? get _currentUserId => AuthService.currentUser?.id;

  // Get all cart items (from Supabase if authenticated, otherwise local)
  Future<List<CartItem>> getCartItems() async {
    try {
      if (_currentUserId != null) {
        return await _getCartItemsFromSupabase();
      } else {
        return await _getCartItemsFromLocal();
      }
    } catch (e) {
      print('Error getting cart items: $e');
      // Fallback to local storage if Supabase fails
      return await _getCartItemsFromLocal();
    }
  }

  // Get cart items from Supabase
  Future<List<CartItem>> _getCartItemsFromSupabase() async {
    try {
      final response = await _supabase
          .from('cart_items')
          .select('*')
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DataException('Failed to load cart items from database: $e');
    }
  }

  // Get cart items from local storage (fallback)
  Future<List<CartItem>> _getCartItemsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson == null) {
        return [];
      }

      final cartList = jsonDecode(cartJson) as List;
      return cartList.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      throw DataException('Failed to load cart items from local storage: $e');
    }
  }

  // Add item to cart
  Future<void> addToCart(CartItem item) async {
    try {
      if (_currentUserId != null) {
        await _addToCartSupabase(item);
      } else {
        await _addToCartLocal(item);
      }
    } catch (e) {
      throw DataException('Failed to add item to cart: $e');
    }
  }

  // Add item to Supabase cart
  Future<void> _addToCartSupabase(CartItem item) async {
    try {
      // Check if item already exists in cart (must match both product_id AND variant_id)
      var query = _supabase
          .from('cart_items')
          .select('*')
          .eq('user_id', _currentUserId!)
          .eq('product_id', item.productId);
      
      // For variant products, also match variant_id
      // For non-variant products, match where variant_id is null
      if (item.variantId != null && item.variantId!.isNotEmpty) {
        query = query.eq('variant_id', item.variantId!);
      } else {
        query = query.isFilter('variant_id', null);
      }

      final existingItems = await query;

      if (existingItems.isNotEmpty) {
        // Update existing item quantity (same product + same variant)
        final existingItem = CartItem.fromJson(existingItems.first);
        final newQuantity = existingItem.quantity + item.quantity;
        
        await _supabase
            .from('cart_items')
            .update({
              'quantity': newQuantity,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingItem.id!);
      } else {
        // Insert new item (different variant = new cart line)
        final cartData = item.copyWith(userId: _currentUserId).toJson();
        cartData.remove('id'); // Let Supabase generate the ID
        
        await _supabase.from('cart_items').insert(cartData);
      }
    } catch (e) {
      throw DataException('Failed to add item to cart in database: $e');
    }
  }

  // Add item to local cart (fallback)
  Future<void> _addToCartLocal(CartItem item) async {
    try {
      final items = await _getCartItemsFromLocal();
      // Match both product_id AND variant_id for proper variant handling
      final existingItemIndex = items.indexWhere((i) => 
        i.productId == item.productId && i.variantId == item.variantId
      );

      if (existingItemIndex >= 0) {
        // Update existing item quantity (same product + same variant)
        items[existingItemIndex].quantity += item.quantity;
      } else {
        // Add new item (different variant = new cart line)
        items.add(item);
      }

      // Save updated cart
      await _saveCartLocal(items);
    } catch (e) {
      throw DataException('Failed to add item to local cart: $e');
    }
  }

  // Update cart item (cartItemId can be Supabase ID or productId for local)
  Future<void> updateCartItem(String cartItemId, int quantity, {String? variantId}) async {
    try {
      if (_currentUserId != null) {
        await _updateCartItemSupabase(cartItemId, quantity);
      } else {
        await _updateCartItemLocal(cartItemId, quantity, variantId: variantId);
      }
    } catch (e) {
      throw DataException('Failed to update cart item: $e');
    }
  }

  // Update cart item in Supabase (uses cart item ID directly)
  Future<void> _updateCartItemSupabase(String cartItemId, int quantity) async {
    try {
      if (quantity <= 0) {
        // Remove item if quantity is zero or negative
        await _supabase
            .from('cart_items')
            .delete()
            .eq('id', cartItemId);
      } else {
        // Update quantity
        await _supabase
            .from('cart_items')
            .update({
              'quantity': quantity,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', cartItemId);
      }
    } catch (e) {
      throw DataException('Failed to update cart item in database: $e');
    }
  }

  // Update cart item locally (matches product_id + variant_id)
  Future<void> _updateCartItemLocal(String productId, int quantity, {String? variantId}) async {
    try {
      final items = await _getCartItemsFromLocal();
      final index = items.indexWhere((item) => 
        item.productId == productId && item.variantId == variantId
      );

      if (index >= 0) {
        if (quantity <= 0) {
          // Remove item if quantity is zero or negative
          items.removeAt(index);
        } else {
          // Update quantity
          items[index].quantity = quantity;
        }

        await _saveCartLocal(items);
      }
    } catch (e) {
      throw DataException('Failed to update local cart item: $e');
    }
  }

  // Remove item from cart (cartItemId can be Supabase ID or productId for local)
  Future<void> removeFromCart(String cartItemId, {String? variantId}) async {
    try {
      if (_currentUserId != null) {
        // For Supabase, use the cart item ID directly
        await _supabase
            .from('cart_items')
            .delete()
            .eq('id', cartItemId);
      } else {
        // For local, match product_id + variant_id
        final items = await _getCartItemsFromLocal();
        items.removeWhere((item) => 
          item.productId == cartItemId && item.variantId == variantId
        );
        await _saveCartLocal(items);
      }
    } catch (e) {
      throw DataException('Failed to remove item from cart: $e');
    }
  }

  // Clear the entire cart
  Future<void> clearCart() async {
    try {
      if (_currentUserId != null) {
        await _supabase
            .from('cart_items')
            .delete()
            .eq('user_id', _currentUserId!);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_cartKey);
      }
    } catch (e) {
      throw DataException('Failed to clear cart: $e');
    }
  }

  // Get cart total
  Future<double> getCartTotal() async {
    try {
      final items = await getCartItems();
      double total = 0.0;
      for (final item in items) {
        total += item.total;
      }
      return total;
    } catch (e) {
      throw DataException('Failed to calculate cart total: $e');
    }
  }

  // Get number of items in cart
  Future<int> getItemCount() async {
    try {
      final items = await getCartItems();
      int count = 0;
      for (final item in items) {
        count += item.quantity;
      }
      return count;
    } catch (e) {
      throw DataException('Failed to get item count: $e');
    }
  }

  // Sync local cart to Supabase when user logs in
  Future<void> syncLocalCartToSupabase() async {
    try {
      if (_currentUserId == null) return;

      final localItems = await _getCartItemsFromLocal();
      if (localItems.isEmpty) return;

      // Get existing cart items from Supabase
      final supabaseItems = await _getCartItemsFromSupabase();
      
      for (final localItem in localItems) {
        // Match both product_id AND variant_id
        final existingItem = supabaseItems.firstWhere(
          (item) => item.productId == localItem.productId && 
                    item.variantId == localItem.variantId,
          orElse: () => CartItem(productId: '', name: '', price: 0),
        );

        if (existingItem.productId.isNotEmpty) {
          // Update existing item with combined quantity
          final newQuantity = existingItem.quantity + localItem.quantity;
          await _supabase
              .from('cart_items')
              .update({
                'quantity': newQuantity,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', existingItem.id!);
        } else {
          // Insert new item (different variant = new cart line)
          final cartData = localItem.copyWith(userId: _currentUserId).toJson();
          cartData.remove('id');
          await _supabase.from('cart_items').insert(cartData);
        }
      }

      // Clear local cart after sync
      await _clearLocalCart();
    } catch (e) {
      print('Failed to sync local cart to Supabase: $e');
    }
  }

  // Helper method to save cart to SharedPreferences
  Future<void> _saveCartLocal(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = jsonEncode(items.map((e) => e.toLocalJson()).toList());
    await prefs.setString(_cartKey, itemsJson);
  }

  // Helper method to clear local cart
  Future<void> _clearLocalCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  // Watch cart changes (for real-time updates)
  Stream<List<CartItem>> watchCartItems() {
    if (_currentUserId != null) {
      return _supabase
          .from('cart_items')
          .stream(primaryKey: ['id'])
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false)
          .map((data) => data.map((item) => CartItem.fromJson(item)).toList());
    } else {
      // For non-authenticated users, return a stream that emits current local cart
      return Stream.fromFuture(getCartItems());
    }
  }
}

@riverpod
CartRepository cartRepository(CartRepositoryRef ref) {
  return CartRepository();
} 