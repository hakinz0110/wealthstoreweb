// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartStateImpl _$$CartStateImplFromJson(Map<String, dynamic> json) =>
    _$CartStateImpl(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0.0,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
      appliedCoupon: json['appliedCoupon'] == null
          ? null
          : Coupon.fromJson(json['appliedCoupon'] as Map<String, dynamic>),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$CartStateImplToJson(_$CartStateImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'subtotal': instance.subtotal,
      'shipping': instance.shipping,
      'itemCount': instance.itemCount,
      'isLoading': instance.isLoading,
      'error': instance.error,
      'appliedCoupon': instance.appliedCoupon,
      'discount': instance.discount,
    };
