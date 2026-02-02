// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchStateImpl _$$SearchStateImplFromJson(Map<String, dynamic> json) =>
    _$SearchStateImpl(
      query: json['query'] as String? ?? '',
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      brands: (json['brands'] as List<dynamic>?)
              ?.map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalResults: (json['totalResults'] as num?)?.toInt() ?? 0,
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
      appliedFilters: json['appliedFilters'] == null
          ? null
          : SearchFilters.fromJson(
              json['appliedFilters'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SearchStateImplToJson(_$SearchStateImpl instance) =>
    <String, dynamic>{
      'query': instance.query,
      'products': instance.products,
      'categories': instance.categories,
      'brands': instance.brands,
      'totalResults': instance.totalResults,
      'isLoading': instance.isLoading,
      'error': instance.error,
      'appliedFilters': instance.appliedFilters,
    };

_$SearchResultImpl _$$SearchResultImplFromJson(Map<String, dynamic> json) =>
    _$SearchResultImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['imageUrl'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$SearchResultImplToJson(_$SearchResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': instance.type,
      'subtitle': instance.subtitle,
      'imageUrl': instance.imageUrl,
      'price': instance.price,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'metadata': instance.metadata,
    };

_$SearchFiltersImpl _$$SearchFiltersImplFromJson(Map<String, dynamic> json) =>
    _$SearchFiltersImpl(
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      brands: (json['brands'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      minRating: (json['minRating'] as num?)?.toDouble(),
      sortBy: json['sortBy'] as String? ?? 'relevance',
      inStock: json['inStock'] as bool? ?? false,
      onSale: json['onSale'] as bool? ?? false,
    );

Map<String, dynamic> _$$SearchFiltersImplToJson(_$SearchFiltersImpl instance) =>
    <String, dynamic>{
      'categories': instance.categories,
      'brands': instance.brands,
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'minRating': instance.minRating,
      'sortBy': instance.sortBy,
      'inStock': instance.inStock,
      'onSale': instance.onSale,
    };

_$SearchResultsImpl _$$SearchResultsImplFromJson(Map<String, dynamic> json) =>
    _$SearchResultsImpl(
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      brands: (json['brands'] as List<dynamic>?)
              ?.map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SearchResultsImplToJson(_$SearchResultsImpl instance) =>
    <String, dynamic>{
      'products': instance.products,
      'categories': instance.categories,
      'brands': instance.brands,
      'totalCount': instance.totalCount,
    };
