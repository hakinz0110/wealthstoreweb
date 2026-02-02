import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OrderCard extends StatelessWidget {
  final dynamic order; // Order model
  final VoidCallback onTap;
  final VoidCallback onTrack;
  final VoidCallback onReorder;
  final VoidCallback? onCancel;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onTrack,
    required this.onReorder,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Placed on ${_formatDate(order.orderDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Order items preview
              if (order.items.isNotEmpty) ...[
                Row(
                  children: [
                    // First item image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: order.items.first.imageUrl != null
                            ? Image.network(
                                order.items.first.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.shopping_bag,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Items info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.items.first.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.items.length > 1
                                ? '+${order.items.length - 1} more items'
                                : 'Qty: ${order.items.first.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Total amount
                    Text(
                      '₦${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
              ],
              
              // Progress indicator for shipped orders
              if (order.status.toLowerCase() == 'shipped' && order.trackingInfo != null)
                _buildShippingProgress(order.trackingInfo),
              
              // Delivery info
              if (order.estimatedDelivery != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Estimated delivery: ${_formatDate(order.estimatedDelivery!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Action buttons
              Row(
                children: [
                  // Track button
                  if (order.status.toLowerCase() != 'delivered' && 
                      order.status.toLowerCase() != 'cancelled')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onTrack,
                        icon: const Icon(Icons.track_changes, size: 16),
                        label: const Text('Track'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  
                  if (order.status.toLowerCase() != 'delivered' && 
                      order.status.toLowerCase() != 'cancelled')
                    const SizedBox(width: 8),
                  
                  // Reorder button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReorder,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Reorder'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  
                  // Cancel button (only for pending orders)
                  if (onCancel != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.schedule;
        break;
      case 'processing':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        icon = Icons.settings;
        break;
      case 'shipped':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        icon = Icons.local_shipping;
        break;
      case 'delivered':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingProgress(trackingInfo) {
    final progress = _getShippingProgress(trackingInfo.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trackingInfo.status,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? Colors.green : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  double _getShippingProgress(String status) {
    switch (status.toLowerCase()) {
      case 'picked up':
        return 0.25;
      case 'in transit':
        return 0.5;
      case 'out for delivery':
        return 0.75;
      case 'delivered':
        return 1.0;
      default:
        return 0.0;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}