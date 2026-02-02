import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/services/coupon_service.dart';
import 'package:wealth_app/features/cart/domain/cart_notifier.dart';

class CouponInputWidget extends ConsumerStatefulWidget {
  const CouponInputWidget({super.key});

  @override
  ConsumerState<CouponInputWidget> createState() => _CouponInputWidgetState();
}

class _CouponInputWidgetState extends ConsumerState<CouponInputWidget> {
  final _couponController = TextEditingController();
  bool _isApplying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isApplying = true;
      _errorMessage = null;
    });

    try {
      final coupon = await ref.read(couponServiceProvider).validateCoupon(code);
      
      if (coupon == null) {
        setState(() {
          _errorMessage = 'Invalid or expired coupon code';
          _isApplying = false;
        });
        return;
      }

      final cartState = ref.read(cartNotifierProvider);
      
      // Check minimum order amount
      if (coupon.minimumOrderAmount != null && cartState.total < coupon.minimumOrderAmount!) {
        setState(() {
          _errorMessage = 'Minimum order amount is ₦${coupon.minimumOrderAmount!.toStringAsFixed(0)}';
          _isApplying = false;
        });
        return;
      }

      await ref.read(cartNotifierProvider.notifier).applyCoupon(coupon);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coupon "${coupon.code}" applied successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      setState(() {
        _isApplying = false;
        _couponController.clear();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to apply coupon';
        _isApplying = false;
      });
    }
  }

  void _removeCoupon() {
    ref.read(cartNotifierProvider.notifier).removeCoupon();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coupon removed'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final hasAppliedCoupon = cartState.appliedCoupon != null;

    if (hasAppliedCoupon) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coupon Applied: ${cartState.appliedCoupon!.code}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'You saved ₦${cartState.discount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _removeCoupon,
              icon: const Icon(Icons.close, size: 20),
              color: Colors.green,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                decoration: InputDecoration(
                  hintText: 'Enter coupon code',
                  prefixIcon: const Icon(Icons.local_offer),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: _errorMessage,
                  enabled: !_isApplying,
                ),
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _applyCoupon(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isApplying ? null : _applyCoupon,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isApplying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Apply',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
