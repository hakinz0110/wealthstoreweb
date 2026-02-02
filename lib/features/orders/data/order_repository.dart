import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/order_service.dart';
import 'package:wealth_app/core/services/auth_service.dart';
import 'package:wealth_app/shared/models/order.dart';

part 'order_repository.g.dart';

@riverpod
OrderRepository orderRepository(OrderRepositoryRef ref) {
  final orderService = ref.watch(orderServiceProvider);
  return OrderRepository(orderService);
}

class OrderRepository {
  final OrderService _orderService;

  OrderRepository(this._orderService);

  // Get orders for the current user
  Future<List<Order>> getUserOrders({
    int? limit,
    int? offset,
    String? status,
    required String userId,
  }) async {
    return _orderService.getOrdersByUserId(
      userId,
      limit: limit,
      offset: offset,
      status: status,
    );
  }

  // Get a single order by ID
  Future<Order?> getOrderById(String id) async {
    return _orderService.getOrderById(id);
  }

  // Create a new order
  Future<Order> createOrder({
    required String customerId,
    required double total,
    required List<OrderItem> items,
    required ShippingAddress shippingAddress,
    String paymentMethod = 'credit_card',
    String? paymentReference,
  }) async {
    // Generate a unique order number using timestamp
    final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    
    // Create the order object - if payment reference provided, order is already paid
    final order = Order(
      id: '', // Will be assigned by the database
      userId: customerId,
      orderNumber: orderNumber,
      status: paymentReference != null ? 'processing' : 'pending',
      totalAmount: total,
      orderItems: items,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      paymentStatus: paymentReference != null ? 'paid' : 'pending',
      transactionId: paymentReference,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Create the order in the database
    return _orderService.createOrder(order);
  }

  // Cancel an order
  Future<Order> cancelOrder(String id) async {
    return _orderService.cancelOrder(id);
  }

  // Get real-time updates for user orders
  Stream<List<Order>> watchUserOrders(String userId) {
    return _orderService.watchOrders(userId: userId);
  }

  // Place order from cart items
  Future<bool> placeOrder({
    required List<Map<String, dynamic>> cartItems,
    required double totalAmount,
    required ShippingAddress shippingAddress,
    String paymentMethod = 'credit_card',
  }) async {
    try {
      // Get current user
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final userId = currentUser.id;
      final supabaseClient = AuthService.client;

      // Generate unique order number
      final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      
      // Step 1: Insert new order into 'orders' table - matching your DB structure
      final orderData = {
        'customer_id': userId, // UUID
        'total': totalAmount, // Your DB uses 'total' not 'total_amount'
        'subtotal': totalAmount,
        'tax_amount': 0.00,
        'shipping_amount': 0.00,
        'discount_amount': 0.00,
        'status': 'pending',
        'payment_method': paymentMethod,
        'payment_status': 'pending',
        'shipping_address': shippingAddress.toJson(),
        'order_number': orderNumber,
      };

      // Insert order and get the new order ID
      final orderResponse = await supabaseClient
          .from('orders')
          .insert(orderData)
          .select('id')
          .single();

      final orderId = orderResponse['id'] as String;

      // Step 2: Insert order items into 'order_items' table - matching your DB structure
      final orderItemsData = cartItems.map((cartItem) {
        return {
          'order_id': orderId,
          'product_id': (cartItem['product_id'] as num).toInt(),
          'product_name': cartItem['name'] ?? 'Product',
          'quantity': cartItem['quantity'] as int,
          'price': (cartItem['price'] as num).toDouble(),
          'image_url': cartItem['image_url'],
          'variant_id': cartItem['variant_id'],
          'variant_attributes': cartItem['variant_attributes'],
        };
      }).toList();

      await supabaseClient
          .from('order_items')
          .insert(orderItemsData);

      // Step 3: Clear cart items for the user (optional)
      await supabaseClient
          .from('cart_items')
          .delete()
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Failed to place order: $e');
      return false;
    }
  }
}