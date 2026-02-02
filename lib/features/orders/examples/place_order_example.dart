import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealth_app/shared/models/order.dart';
import '../domain/place_order_service.dart';

/// Example of how to use the PlaceOrderService
class PlaceOrderExample extends ConsumerWidget {
  const PlaceOrderExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Place Order Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _placeOrderExample1(context, ref),
              child: const Text('Place Order - Example 1'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _placeOrderExample2(context, ref),
              child: const Text('Place Order - Example 2 (Simple)'),
            ),
          ],
        ),
      ),
    );
  }

  /// Example 1: Using the main placeOrder method
  Future<void> _placeOrderExample1(BuildContext context, WidgetRef ref) async {
    final placeOrderService = ref.read(placeOrderServiceProvider);

    // Sample cart items (as they would come from your cart)
    final cartItems = [
      {
        'product_id': '123',
        'name': 'iPhone 15 Pro',
        'price': 999.99,
        'quantity': 1,
      },
      {
        'product_id': '456',
        'name': 'AirPods Pro',
        'price': 249.99,
        'quantity': 2,
      },
    ];

    // Calculate total amount
    double totalAmount = 0.0;
    for (final item in cartItems) {
      totalAmount += (item['price'] as double) * (item['quantity'] as int);
    }

    // Sample shipping address
    final shippingAddress = ShippingAddress(
      fullName: 'John Doe',
      addressLine1: '123 Main Street',
      addressLine2: 'Apt 4B',
      city: 'New York',
      state: 'NY',
      postalCode: '10001',
      country: 'USA',
      phone: '+1234567890',
      email: 'john.doe@example.com',
    );

    // Place the order
    final success = await placeOrderService.placeOrder(
      cartItems: cartItems,
      totalAmount: totalAmount,
      shippingAddress: shippingAddress,
      paymentMethod: 'credit_card',
      context: context, // This enables automatic navigation and dialogs
      clearCart: true, // This will clear the cart after successful order
    );

    if (success) {
      print('Order placed successfully!');
    } else {
      print('Failed to place order');
    }
  }

  /// Example 2: Using the simplified placeOrderSimple method
  Future<void> _placeOrderExample2(BuildContext context, WidgetRef ref) async {
    final placeOrderService = ref.read(placeOrderServiceProvider);

    // Sample cart items using the simplified structure
    final cartItems = [
      CartItemSimple(
        productId: '789',
        name: 'MacBook Pro',
        price: 1999.99,
        quantity: 1,
      ),
      CartItemSimple(
        productId: '101',
        name: 'Magic Mouse',
        price: 79.99,
        quantity: 1,
      ),
    ];

    // Calculate total amount
    double totalAmount = 0.0;
    for (final item in cartItems) {
      totalAmount += item.price * item.quantity;
    }

    // Sample shipping address
    final shippingAddress = ShippingAddress(
      fullName: 'Jane Smith',
      addressLine1: '456 Oak Avenue',
      city: 'Los Angeles',
      state: 'CA',
      postalCode: '90210',
      country: 'USA',
      phone: '+1987654321',
      email: 'jane.smith@example.com',
    );

    // Place the order using the simple method
    final success = await placeOrderService.placeOrderSimple(
      cartItems: cartItems,
      totalAmount: totalAmount,
      shippingAddress: shippingAddress,
      paymentMethod: 'paypal',
      context: context,
      clearCart: true,
    );

    if (success) {
      print('Order placed successfully!');
    } else {
      print('Failed to place order');
    }
  }

  /// Example 3: Manual handling without automatic navigation/dialogs
  Future<void> _placeOrderManual(BuildContext context, WidgetRef ref) async {
    final placeOrderService = ref.read(placeOrderServiceProvider);

    final cartItems = [
      {
        'product_id': '999',
        'name': 'Sample Product',
        'price': 29.99,
        'quantity': 3,
      },
    ];

    final totalAmount = 89.97;

    final shippingAddress = ShippingAddress(
      fullName: 'Test User',
      addressLine1: '789 Test Street',
      city: 'Test City',
      state: 'TS',
      postalCode: '12345',
      country: 'USA',
    );

    // Place order without context (no automatic navigation/dialogs)
    final success = await placeOrderService.placeOrder(
      cartItems: cartItems,
      totalAmount: totalAmount,
      shippingAddress: shippingAddress,
      context: null, // No automatic handling
      clearCart: false, // Don't clear cart automatically
    );

    // Handle the result manually
    if (success) {
      // Show your custom success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate manually
      Navigator.of(context).pushNamed('/orders');
    } else {
      // Show your custom error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place order. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}