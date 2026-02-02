import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/features/cart/data/cart_repository.dart';
import 'package:wealth_app/features/cart/domain/cart_state.dart';
import 'package:wealth_app/shared/models/product.dart';
import 'package:wealth_app/shared/models/coupon.dart';
import 'package:wealth_app/core/services/coupon_service.dart';

part 'cart_notifier.g.dart';

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  CartState build() {
    _loadCart();
    return CartState.initial();
  }

  Future<void> _loadCart() async {
    state = CartState.loading();
    try {
      final items = await ref.read(cartRepositoryProvider).getCartItems();
      state = CartState.loaded(items);
    } catch (e) {
      state = CartState.error("Failed to load cart");
    }
  }

  Future<void> addItem(
    Product product, {
    int quantity = 1,
    ProductVariant? variant,
    String? selectedImageUrl, // For single products with multiple images
  }) async {
    try {
      // Priority: variant image > selected image > product default image
      final imageUrl = variant?.imageUrl ?? selectedImageUrl ?? product.imageUrl;
      
      final cartItem = CartItem(
        productId: product.id.toString(),
        name: product.name,
        price: variant?.price ?? product.price,
        imageUrl: imageUrl,
        quantity: quantity,
        shippingRate: product.shippingRate,
        variantId: variant?.id,
        variantAttributes: variant?.attributes,
      );
      
      await ref.read(cartRepositoryProvider).addToCart(cartItem);
      await _loadCart();
    } on DataException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(error: "Failed to add item to cart");
    }
  }
  
  // Direct method for adding CartItem objects
  Future<void> addToCart(CartItem cartItem) async {
    try {
      await ref.read(cartRepositoryProvider).addToCart(cartItem);
      await _loadCart();
    } on DataException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(error: "Failed to add item to cart");
    }
  }

  Future<void> removeItem(String cartItemId, {String? variantId}) async {
    try {
      await ref.read(cartRepositoryProvider).removeFromCart(cartItemId, variantId: variantId);
      await _loadCart();
    } catch (e) {
      state = state.copyWith(error: "Failed to remove item from cart");
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity, {String? variantId}) async {
    try {
      await ref.read(cartRepositoryProvider).updateCartItem(cartItemId, quantity, variantId: variantId);
      await _loadCart();
    } catch (e) {
      state = state.copyWith(error: "Failed to update cart");
    }
  }

  // Sync local cart to Supabase when user logs in
  Future<void> syncLocalCartToSupabase() async {
    try {
      await ref.read(cartRepositoryProvider).syncLocalCartToSupabase();
      await _loadCart();
    } catch (e) {
      print('Failed to sync cart: $e');
    }
  }

  // Watch cart changes for real-time updates
  Stream<List<CartItem>> watchCartItems() {
    return ref.read(cartRepositoryProvider).watchCartItems();
  }

  Future<void> clearCart() async {
    try {
      await ref.read(cartRepositoryProvider).clearCart();
      state = CartState.initial();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      state = state.copyWith(error: "Failed to clear cart");
    }
  }

  // Apply coupon to cart
  Future<void> applyCoupon(Coupon coupon) async {
    try {
      final couponService = ref.read(couponServiceProvider);
      final discount = couponService.calculateDiscount(coupon, state.total);
      
      state = state.copyWith(
        appliedCoupon: coupon,
        discount: discount,
      );
    } catch (e) {
      state = state.copyWith(error: "Failed to apply coupon");
    }
  }

  // Remove applied coupon
  void removeCoupon() {
    state = state.copyWith(
      appliedCoupon: null,
      discount: 0.0,
    );
  }

  // Toggle selection of a single item
  void toggleItemSelection(String cartItemId) {
    final updatedItems = state.items.map((item) {
      if ((item.id ?? item.productId) == cartItemId) {
        return item.copyWith(isSelected: !item.isSelected);
      }
      return item;
    }).toList();
    
    state = CartState.loaded(
      updatedItems,
      appliedCoupon: state.appliedCoupon,
      discount: state.discount,
    );
  }

  // Select all items
  void selectAll() {
    final updatedItems = state.items.map((item) {
      return item.copyWith(isSelected: true);
    }).toList();
    
    state = CartState.loaded(
      updatedItems,
      appliedCoupon: state.appliedCoupon,
      discount: state.discount,
    );
  }

  // Deselect all items
  void deselectAll() {
    final updatedItems = state.items.map((item) {
      return item.copyWith(isSelected: false);
    }).toList();
    
    state = CartState.loaded(
      updatedItems,
      appliedCoupon: state.appliedCoupon,
      discount: state.discount,
    );
  }

  // Check if all items are selected
  bool get allSelected => state.items.isNotEmpty && state.items.every((item) => item.isSelected);

  // Get selected items count
  int get selectedCount => state.items.where((item) => item.isSelected).length;

  // Get selected items for checkout
  List<CartItem> get selectedItems => state.items.where((item) => item.isSelected).toList();
}
