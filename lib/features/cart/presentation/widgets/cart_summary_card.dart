import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CartSummaryCard extends StatelessWidget {
  final double subtotal;
  final double discount;
  final String? appliedCoupon;
  final VoidCallback onCheckout;

  const CartSummaryCard({
    super.key,
    required this.subtotal,
    required this.discount,
    this.appliedCoupon,
    required this.onCheckout,
  });

  double get total => subtotal - discount;
  double get tax => total * 0.08; // 8% tax
  double get shipping => total > 50 ? 0 : 5.99; // Free shipping over $50
  double get finalTotal => total + tax + shipping;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Subtotal
            _buildSummaryRow('Subtotal', subtotal),
            
            // Discount (if applied)
            if (discount > 0) ...[
              _buildSummaryRow(
                'Discount${appliedCoupon != null ? ' ($appliedCoupon)' : ''}',
                -discount,
                color: Colors.green,
              ),
            ],
            
            // Tax
            _buildSummaryRow('Tax (8%)', tax),
            
            // Shipping
            _buildSummaryRow(
              'Shipping',
              shipping,
              subtitle: shipping == 0 ? 'Free shipping!' : null,
            ),
            
            const Divider(height: 24),
            
            // Total
            _buildSummaryRow(
              'Total',
              finalTotal,
              isTotal: true,
            ),
            
            const SizedBox(height: 20),
            
            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_checkout),
                    const SizedBox(width: 8),
                    Text(
                      'Proceed to Checkout • ₦${finalTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Security Badge
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.security,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  'Secure checkout with SSL encryption',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    Color? color,
    String? subtitle,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
              ),
              Text(
                '₦${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                  color: color ?? (isTotal ? AppColors.primary : null),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(),
              ],
            ),
          ],
        ],
      ),
    );
  }
}