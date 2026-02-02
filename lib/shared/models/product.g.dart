// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductVariantImpl _$$ProductVariantImplFromJson(Map<String, dynamic> json) =>
    _$ProductVariantImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      attributes: (json['attributes'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      imageUrl: json['image_url'] as String?,
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      sku: json['sku'] as String?,
    );

Map<String, dynamic> _$$ProductVariantImplToJson(
        _$ProductVariantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'stock': instance.stock,
      'attributes': instance.attributes,
      'image_url': instance.imageUrl,
      'sale_price': instance.salePrice,
      'sku': instance.sku,
    };

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: const FlexibleIntConverter().fromJson(json['id']),
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      categoryId: const FlexibleIntConverter().fromJson(json['category_id']),
      brandId: const FlexibleNullableIntConverter().fromJson(json['brand_id']),
      imageUrls: (json['image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      specifications: json['specifications'] as Map<String, dynamic>?,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      productType:
          $enumDecodeNullable(_$ProductTypeEnumMap, json['product_type']) ??
              ProductType.single,
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      shippingRate: (json['shipping_rate'] as num?)?.toDouble() ?? 0.08,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': const FlexibleIntConverter().toJson(instance.id),
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'category_id': const FlexibleIntConverter().toJson(instance.categoryId),
      'brand_id': const FlexibleNullableIntConverter().toJson(instance.brandId),
      'image_urls': instance.imageUrls,
      'specifications': instance.specifications,
      'stock': instance.stock,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'is_featured': instance.isFeatured,
      'is_active': instance.isActive,
      'tags': instance.tags,
      'product_type': _$ProductTypeEnumMap[instance.productType]!,
      'variants': instance.variants,
      'shipping_rate': instance.shippingRate,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$ProductTypeEnumMap = {
  ProductType.single: 'single',
  ProductType.variable: 'variable',
};
