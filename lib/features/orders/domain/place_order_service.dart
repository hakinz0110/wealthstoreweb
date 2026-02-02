import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/auth_service.dart';
import 'package:wealth_app/shared/models/order.dart';
import '../data/order_repository.dart';

part 'place_order_service.g.dart';

@riverpod
PlaceOrderService placeOrderService(PlaceOrderServiceRef ref) {
  final orderRepository = ref.watch(orderRepositoryProvider);
  return PlaceOrderService(orderRepository);
}

class PlaceOrderService {
  final OrderRepository _orderRepository;

  PlaceOrderService(this._orderRepository);

  /// Places an order using cart items and handles the complete flow
  /// 
  /// Parameters:
  /// - [cartItems]: List of cart items with product_id, quantity, price, name
  /// - [totalAmount]: Calculated total amount for the order
  /// - [shippingAddress]: Shipping address for the order
  /// - [paymentMethod]: Payment method (defaults to 'credit_card')
  /// - [context]: BuildContext for navigation (optional)
  /// - [clearCart]: Whether to clear cart after successful order (defaults to true)
  /// 
  /// Returns: true if successful, false otherwise
  Future<bool> placeOrder({
    required List<Map<String, dynamic>> cartItems,
    required double totalAmount,
    required ShippingAddress shippingAddress,
    String paymentMethod = 'credit_card',
    BuildContext? context,
    bool clearCart = true,
  }) async {
    try {
      // Validate inputs
      if (cartItems.isEmpty) {
        throw Exception('Cart is empty');
      }

      if (totalAmount <= 0) {
        throw Exception('Invalid total amount');
      }

      // Get current user
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final userId = currentUser.id;
      final supabaseClient = AuthService.client;

      // Step 1: Generate order number
      final orderNumber = await _generateOrderNumber();

      // Step 2: Insert new order into 'orders' table
      final orderData = {
        'user_id': userId,
        'order_number': orderNumber,
        'total_amount': totalAmount,
        'status': 'pending',
        'payment_method': paymentMethod,
        'payment_status': 'pending',
        'shipping_address': shippingAddress.toJson(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Insert order and get the new order ID
      final orderResponse = await supabaseClient
          .from('orders')
          .insert(orderData)
          .select('id, order_number')
          .single();

      final orderId = orderResponse['id'] as String;
      final createdOrderNumber = orderResponse['order_number'] as String;

      // Step 3: Insert order items into 'order_items' table
      final orderItemsData = cartItems.map((cartItem) {
        final quantity = cartItem['quantity'] as int;
        final unitPrice = (cartItem['price'] as num).toDouble();
        
        return {
          'order_id': orderId,
          'product_id': cartItem['product_id'].toString(),
          'product_name': cartItem['name'] ?? 'Unknown Product',
          'quantity': quantity,
          'price': unitPrice,
          'image_url': cartItem['image_url'],
          'variant_id': cartItem['variant_id'],
          'variant_attributes': cartItem['variant_attributes'],
        };
      }).toList();

      await supabaseClient
          .from('order_items')
          .insert(orderItemsData);

      // Step 4: Clear cart items for the user (if requested)
      if (clearCart) {
        await _clearUserCart(userId);
      }

      // Step 5: Show success feedback and navigate (if context provided)
      if (context != null) {
        await _handleOrderSuccess(context, createdOrderNumber);
      }

      return true;
    } catch (e) {
      print('Failed to place order: $e');
      
      // Show error feedback if context provided
      if (context != null) {
        await _handleOrderError(context, e.toString());
      }
      
      return false;
    }
  }

  /// Places order with simplified cart item structure
  /// Assumes cart items have: productId, name, price, quantity
  Future<bool> placeOrderSimple({
    required List<CartItemSimple> cartItems,
    required double totalAmount,
    required ShippingAddress shippingAddress,
    String paymentMethod = 'credit_card',
    BuildContext? context,
    bool clearCart = true,
  }) async {
    // Convert simple cart items to the expected format
    final cartItemsMap = cartItems.map((item) => {
      'product_id': item.productId,
      'name': item.name,
      'price': item.price,
      'quantity': item.quantity,
      'image_url': item.imageUrl,
      'variant_id': item.variantId,
      'variant_attributes': item.variantAttributes,
    }).toList();

    return placeOrder(
      cartItems: cartItemsMap,
      totalAmount: totalAmount,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      context: context,
      clearCart: clearCart,
    );
  }

  // Private helper methods

  Future<String> _generateOrderNumber() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    final now = DateTime.now();
    return 'ORD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$random';
  }

  Future<void> _clearUserCart(String userId) async {
    try {
      final supabaseClient = AuthService.client;
      
      // Try to clear from database cart_items table
      await supabaseClient
          .from('cart_items')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      print('Warning: Failed to clear cart from database: $e');
      // Don't throw error as this is not critical
    }
  }

  Future<void> _handleOrderSuccess(BuildContext context, String orderNumber) async {
    // Show success dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Order Placed Successfully!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your order has been placed successfully.'),
              const SizedBox(height: 8),
              Text(
                'Order Number: $orderNumber',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('You will receive a confirmation email shortly.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _navigateToOrderSuccess(context, orderNumber);
              },
              child: const Text('View Order'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _navigateToHome(context);
              },
              child: const Text('Continue Shopping'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleOrderError(BuildContext context, String error) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Order Failed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sorry, we couldn\'t process your order.'),
              const SizedBox(height: 8),
              Text(
                'Error: $error',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text('Please try again or contact support.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToOrderSuccess(BuildContext context, String orderNumber) {
    // Navigate to order success screen
    // Replace with your actual route
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/order-success',
      (route) => route.isFirst,
      arguments: {'orderNumber': orderNumber},
    );
  }

  void _navigateToHome(BuildContext context) {
    // Navigate to home screen
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }
}

/// Simplified cart item structure
class CartItemSimple {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? variantId;
  final Map<String, dynamic>? variantAttributes;

  const CartItemSimple({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.variantId,
    this.variantAttributes,
  });
}