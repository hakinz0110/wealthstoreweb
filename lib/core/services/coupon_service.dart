import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/shared/models/coupon.dart';

part 'coupon_service.g.dart';

@riverpod
CouponService couponService(CouponServiceRef ref) {
  return CouponService();
}

class CouponService {
  SupabaseClient get _client => Supabase.instance.client;

  /// Get all active coupons
  Future<List<Coupon>> getActiveCoupons() async {
    try {
      final response = await _client
          .from('coupons')
          .select('*')
          .eq('is_active', true)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return response.map<Coupon>((json) => Coupon.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch active coupons: $e');
    }
  }

  /// Validate and apply a coupon code
  Future<Coupon?> validateCoupon(String code) async {
    try {
      final response = await _client
          .from('coupons')
          .select('*')
          .eq('code', code.toUpperCase())
          .eq('is_active', true)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final coupon = Coupon.fromJson(response);

      // Check if coupon is expired
      if (coupon.endDate != null && DateTime.now().isAfter(coupon.endDate!)) {
        return null;
      }

      // Check if coupon has reached usage limit
      if (coupon.usageLimit != null && coupon.usageCount >= coupon.usageLimit!) {
        return null;
      }

      return coupon;
    } catch (e) {
      throw Exception('Failed to validate coupon: $e');
    }
  }

  /// Calculate discount amount for a given order total
  double calculateDiscount(Coupon coupon, double orderTotal) {
    // Check minimum order amount
    if (coupon.minimumOrderAmount != null && orderTotal < coupon.minimumOrderAmount!) {
      return 0.0;
    }

    double discount = 0.0;

    if (coupon.discountType == 'percentage') {
      discount = orderTotal * (coupon.discountValue / 100);
      
      // Apply maximum discount cap if exists
      if (coupon.maximumDiscountAmount != null && discount > coupon.maximumDiscountAmount!) {
        discount = coupon.maximumDiscountAmount!;
      }
    } else {
      // Fixed discount
      discount = coupon.discountValue;
    }

    // Ensure discount doesn't exceed order total
    return discount > orderTotal ? orderTotal : discount;
  }
}
