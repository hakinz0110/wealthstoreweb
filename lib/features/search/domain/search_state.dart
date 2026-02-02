import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.freezed.dart';
part 'search_state.g.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    @Default('') String query,
    @Default([]) List<SearchResult> products,
    @Default([]) List<SearchResult> categories,
    @Default([]) List<SearchResult> brands,
    @Default(0) int totalResults,
    @Default(false) bool isLoading,
    String? error,
    SearchFilters? appliedFilters,
  }) = _SearchState;

  const SearchState._();

  bool get hasResults => totalResults > 0;
  
  List<SearchResult> get allResults => [
    ...products,
    ...categories,
    ...brands,
  ];

  factory SearchState.fromJson(Map<String, dynamic> json) => _$SearchStateFromJson(json);
}

@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult({
    required String id,
    required String title,
    required String type, // 'product', 'category', 'brand'
    String? subtitle,
    String? imageUrl,
    double? price,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? metadata,
  }) = _SearchResult;

  factory SearchResult.fromJson(Map<String, dynamic> json) => _$SearchResultFromJson(json);
}

@freezed
class SearchFilters with _$SearchFilters {
  const factory SearchFilters({
    @Default([]) List<String> categories,
    @Default([]) List<String> brands,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    @Default('relevance') String sortBy, // 'relevance', 'price_low', 'price_high', 'rating', 'newest'
    @Default(false) bool inStock,
    @Default(false) bool onSale,
  }) = _SearchFilters;

  factory SearchFilters.fromJson(Map<String, dynamic> json) => _$SearchFiltersFromJson(json);
}

@freezed
class SearchResults with _$SearchResults {
  const factory SearchResults({
    @Default([]) List<SearchResult> products,
    @Default([]) List<SearchResult> categories,
    @Default([]) List<SearchResult> brands,
    @Default(0) int totalCount,
  }) = _SearchResults;

  factory SearchResults.fromJson(Map<String, dynamic> json) => _$SearchResultsFromJson(json);
}

enum SearchResultType {
  all,
  products,
  categories,
  brands,
}