import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

// Custom converter to handle both String and int for IDs
class FlexibleIntConverter implements JsonConverter<int, dynamic> {
  const FlexibleIntConverter();

  @override
  int fromJson(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  @override
  dynamic toJson(int value) => value;
}

// Custom converter for nullable int
class FlexibleNullableIntConverter implements JsonConverter<int?, dynamic> {
  const FlexibleNullableIntConverter();

  @override
  int? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  @override
  dynamic toJson(int? value) => value;
}

enum ProductType {
  single,
  variable,
}

@freezed
class ProductVariant with _$ProductVariant {
  const factory ProductVariant({
    required String id,
    required String name,
    required double price,
    @Default(0) int stock,
    @Default({}) Map<String, String> attributes,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'sale_price') double? salePrice,
    String? sku,
  }) = _ProductVariant;

  const ProductVariant._();

  String get displayImage => imageUrl ?? '';

  factory ProductVariant.fromJson(Map<String, dynamic> json) => _$ProductVariantFromJson(json);
}

@freezed
class Product with _$Product {
  const factory Product({
    @FlexibleIntConverter() required int id,
    required String name,
    required String description,
    required double price,
    @JsonKey(name: 'category_id') @FlexibleIntConverter() required int categoryId,
    @JsonKey(name: 'brand_id') @FlexibleNullableIntConverter() int? brandId,
    @JsonKey(name: 'image_urls') List<String>? imageUrls,
    Map<String, dynamic>? specifications,
    @Default(0) int stock,
    @Default(0.0) double rating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @Default([]) List<String> tags,
    @JsonKey(name: 'product_type') @Default(ProductType.single) ProductType productType,
    @Default([]) List<ProductVariant> variants,
    @JsonKey(name: 'shipping_rate') @Default(0.08) double shippingRate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Product;
  
  const Product._();
  
  // Computed property for backward compatibility
  String get imageUrl => imageUrls?.isNotEmpty == true ? imageUrls!.first : '';
  
  /// Gets the display image for the product
  /// For variable products, returns the first variant's image if available
  /// For single products, returns the first image from imageUrls
  String get displayImageUrl {
    // For variable products, try to get first variant image
    if (productType == ProductType.variable && variants.isNotEmpty) {
      for (final variant in variants) {
        if (variant.imageUrl != null && variant.imageUrl!.isNotEmpty) {
          return variant.imageUrl!;
        }
      }
    }
    // Fallback to regular imageUrls
    return imageUrls?.isNotEmpty == true ? imageUrls!.first : '';
  }

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
} 