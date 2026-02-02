import 'package:json_annotation/json_annotation.dart';

part 'coupon.g.dart';

@JsonSerializable()
class Coupon {
  final String id;
  final String code;
  final String name;
  final String? description;
  @JsonKey(name: 'discount_type')
  final String discountType;
  @JsonKey(name: 'discount_value')
  final double discountValue;
  @JsonKey(name: 'minimum_order_amount')
  final double? minimumOrderAmount;
  @JsonKey(name: 'maximum_discount_amount')
  final double? maximumDiscountAmount;
  @JsonKey(name: 'usage_limit')
  final int? usageLimit;
  @JsonKey(name: 'usage_count')
  final int usageCount;
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  final String status;
  @JsonKey(name: 'is_first_time_user_only')
  final bool isFirstTimeUserOnly;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Coupon({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minimumOrderAmount,
    this.maximumDiscountAmount,
    this.usageLimit,
    required this.usageCount,
    this.startDate,
    this.endDate,
    required this.status,
    required this.isFirstTimeUserOnly,
    required this.isActive,
    required this.createdAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);
  Map<String, dynamic> toJson() => _$CouponToJson(this);

  String get formattedDiscount {
    if (discountType == 'percentage') {
      return '${discountValue.toInt()}% OFF';
    } else {
      return '₦${discountValue.toStringAsFixed(0)} OFF';
    }
  }

  String get formattedMinimumOrder {
    if (minimumOrderAmount != null) {
      return 'Min. order ₦${minimumOrderAmount!.toStringAsFixed(0)}';
    }
    return 'No minimum';
  }
}
