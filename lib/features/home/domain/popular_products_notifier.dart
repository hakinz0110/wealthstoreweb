import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/features/products/data/product_repository.dart';
import 'package:wealth_app/shared/models/product.dart';

part 'popular_products_notifier.g.dart';

class PopularProductsState {
  final List<Product> products;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const PopularProductsState({
    this.products = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });

  PopularProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return PopularProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
    );
  }
}

@riverpod
class PopularProductsNotifier extends _$PopularProductsNotifier {
  static const int pageSize = 10;

  @override
  PopularProductsState build() {
    // Auto-load on initialization
    Future.microtask(() => loadProducts());
    return const PopularProductsState();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (state.isLoading) return;

    // If refreshing, reset to first page
    if (refresh) {
      state = const PopularProductsState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final products = await ref.read(productRepositoryProvider).getRandomProducts(
        limit: pageSize,
        offset: 0,
      );

      state = PopularProductsState(
        products: products,
        isLoading: false,
        hasMore: products.length >= pageSize,
        currentPage: 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load products: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final offset = nextPage * pageSize;

      final moreProducts = await ref.read(productRepositoryProvider).getRandomProducts(
        limit: pageSize,
        offset: offset,
      );

      final hasMore = moreProducts.length >= pageSize;
      final allProducts = [...state.products, ...moreProducts];

      state = state.copyWith(
        products: allProducts,
        currentPage: nextPage,
        hasMore: hasMore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load more products',
      );
    }
  }

  Future<void> refresh() async {
    await loadProducts(refresh: true);
  }
}
