// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coupon _$CouponFromJson(Map<String, dynamic> json) => Coupon(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String,
      discountValue: (json['discount_value'] as num).toDouble(),
      minimumOrderAmount: (json['minimum_order_amount'] as num?)?.toDouble(),
      maximumDiscountAmount:
          (json['maximum_discount_amount'] as num?)?.toDouble(),
      usageLimit: (json['usage_limit'] as num?)?.toInt(),
      usageCount: (json['usage_count'] as num).toInt(),
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
      isFirstTimeUserOnly: json['is_first_time_user_only'] as bool,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CouponToJson(Coupon instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'discount_type': instance.discountType,
      'discount_value': instance.discountValue,
      'minimum_order_amount': instance.minimumOrderAmount,
      'maximum_discount_amount': instance.maximumDiscountAmount,
      'usage_limit': instance.usageLimit,
      'usage_count': instance.usageCount,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'status': instance.status,
      'is_first_time_user_only': instance.isFirstTimeUserOnly,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
    };
