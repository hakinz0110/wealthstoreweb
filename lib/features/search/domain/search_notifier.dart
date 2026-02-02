import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealth_app/features/search/domain/search_state.dart';
import '../data/search_repository.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchRepository _repository;

  SearchNotifier(this._repository) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      query: query.trim(),
      error: null,
    );

    try {
      // Save to search history
      await _repository.saveSearchQuery(query.trim());

      // Perform search
      final results = await _repository.search(query.trim());

      state = state.copyWith(
        isLoading: false,
        products: results.products,
        categories: results.categories,
        brands: results.brands,
        totalResults: results.totalCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> applyFilters(SearchFilters filters) async {
    if (state.query.isEmpty) return;

    state = state.copyWith(isLoading: true);

    try {
      final results = await _repository.searchWithFilters(state.query, filters);

      state = state.copyWith(
        isLoading: false,
        products: results.products,
        categories: results.categories,
        brands: results.brands,
        totalResults: results.totalCount,
        appliedFilters: filters,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSearch() {
    state = const SearchState();
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.length < 2) return [];
    
    try {
      return await _repository.getSearchSuggestions(query);
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getRecentSearches() async {
    try {
      return await _repository.getRecentSearches();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      await _repository.clearSearchHistory();
    } catch (e) {
      // Handle error silently
    }
  }
}

final searchNotifierProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(searchRepositoryProvider));
});