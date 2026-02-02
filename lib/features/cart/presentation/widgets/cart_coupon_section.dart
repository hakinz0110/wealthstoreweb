import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CartCouponSection extends StatefulWidget {
  final String? appliedCoupon;
  final double discount;
  final Function(String coupon, double discount) onCouponApplied;
  final VoidCallback onCouponRemoved;

  const CartCouponSection({
    super.key,
    this.appliedCoupon,
    required this.discount,
    required this.onCouponApplied,
    required this.onCouponRemoved,
  });

  @override
  State<CartCouponSection> createState() => _CartCouponSectionState();
}

class _CartCouponSectionState extends State<CartCouponSection> {
  final TextEditingController _couponController = TextEditingController();
  bool _isApplying = false;

  // Mock coupon data - in a real app, this would come from an API
  final Map<String, double> _availableCoupons = {
    'SAVE10': 10.0,
    'WELCOME20': 20.0,
    'SUMMER15': 15.0,
    'NEWUSER25': 25.0,
  };

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_offer,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Promo Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          if (widget.appliedCoupon != null) ...[
            // Applied Coupon Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coupon Applied: ${widget.appliedCoupon}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                        Text(
                          'You saved ₦${widget.discount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      widget.onCouponRemoved();
                      _couponController.clear();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.green[600],
                      size: 20,
                    ),
                    tooltip: 'Remove coupon',
                  ),
                ],
              ),
            ),
          ] else ...[
            // Coupon Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isApplying ? null : _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isApplying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Apply'),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Available Coupons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableCoupons.keys.map((coupon) {
                return GestureDetector(
                  onTap: () {
                    _couponController.text = coupon;
                    _applyCoupon();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer,
                          size: 12,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          coupon,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _applyCoupon() async {
    final couponCode = _couponController.text.trim().toUpperCase();
    
    if (couponCode.isEmpty) {
      _showMessage('Please enter a coupon code', isError: true);
      return;
    }

    setState(() {
      _isApplying = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isApplying = false;
    });

    if (_availableCoupons.containsKey(couponCode)) {
      final discount = _availableCoupons[couponCode]!;
      widget.onCouponApplied(couponCode, discount);
      _showMessage('Coupon applied successfully!');
    } else {
      _showMessage('Invalid coupon code', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}