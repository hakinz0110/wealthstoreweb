import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/features/orders/domain/order_notifier.dart';
import 'package:wealth_app/features/orders/presentation/screens/order_details_screen.dart';
import 'package:wealth_app/shared/models/order.dart';


class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: orderState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : orderState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(orderState.error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.read(orderNotifierProvider.notifier).refreshOrders(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : orderState.orders.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () => ref.read(orderNotifierProvider.notifier).refreshOrders(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.medium),
                              itemCount: orderState.orders.length,
                              itemBuilder: (context, index) {
                                final order = orderState.orders[index];
                                return _buildOrderCard(order);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            _buildFilterChip('Pending', 'pending'),
            _buildFilterChip('Confirmed', 'confirmed'),
            _buildFilterChip('Shipped', 'shipped'),
            _buildFilterChip('Delivered', 'delivered'),
            _buildFilterChip('Cancelled', 'cancelled'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = value;
          });
          
          if (value == 'all') {
            ref.read(orderNotifierProvider.notifier).refreshOrders();
          } else {
            ref.read(orderNotifierProvider.notifier).filterByStatus(value);
          }
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'No orders found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            _selectedStatus == 'all'
                ? 'You haven\'t placed any orders yet'
                : 'You don\'t have any ${_selectedStatus} orders',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusBadge(order.status),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  'Placed on ${_formatDate(order.createdAt)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text('${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}'),
                const SizedBox(height: 8),
                Text(
                  'Total: ₦${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.canBeCancelled) ...[
                  TextButton(
                    onPressed: () => _showCancelDialog(order),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Cancel Order'),
                  ),
                  const SizedBox(width: 8),
                ],
                ElevatedButton(
                  onPressed: () => _navigateToDetails(order.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color color;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'shipped':
        color = Colors.indigo;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
  
  void _navigateToDetails(String orderId) {
    debugPrint('🟢 Navigating to order details: $orderId');
    context.push('/order-details/$orderId');
  }
  
  void _showCancelDialog(Order order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No, Keep Order'),
          ),
          TextButton(
            onPressed: () {
              ref.read(orderNotifierProvider.notifier).cancelOrder(order.id);
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel Order'),
          ),
        ],
      ),
    );
  }
}
