import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/features/wishlist/data/favorites_repository.dart';
import 'package:wealth_app/shared/models/product.dart';

part 'unified_wishlist_notifier.g.dart';

@riverpod
class UnifiedWishlistNotifier extends _$UnifiedWishlistNotifier {
  @override
  UnifiedWishlistState build() {
    // Load wishlist status asynchronously after build
    Future.microtask(() => _loadWishlistStatus());
    return UnifiedWishlistState.initial();
  }

  Future<void> _loadWishlistStatus() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final favorites = await ref.read(favoritesRepositoryProvider).getFavoriteProducts();
      
      // Create a map of product IDs to their wishlist status for quick lookups
      final productWishlistStatus = <int, bool>{};
      for (final favorite in favorites) {
        final productId = int.tryParse(favorite.productId);
        if (productId != null) {
          productWishlistStatus[productId] = true;
        }
      }
      
      state = state.copyWith(
        isLoading: false,
        productWishlistStatus: productWishlistStatus,
        favoriteProducts: favorites,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> isInWishlist(int productId) async {
    // First check our local cache
    if (state.productWishlistStatus.containsKey(productId)) {
      return state.productWishlistStatus[productId] ?? false;
    }
    
    // If not in cache, check with the repository
    try {
      final isWishlisted = await ref.read(favoritesRepositoryProvider)
          .isProductFavorite(productId.toString());
      
      // Update our cache
      state = state.copyWith(
        productWishlistStatus: {
          ...state.productWishlistStatus,
          productId: isWishlisted
        }
      );
      
      return isWishlisted;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleWishlist(int productId, {Product? product}) async {
    try {
      // Get current status
      final currentStatus = await isInWishlist(productId);
      final newStatus = !currentStatus;
      
      // Optimistically update UI
      state = state.copyWith(
        productWishlistStatus: {
          ...state.productWishlistStatus,
          productId: newStatus
        }
      );
      
      if (newStatus) {
        // Add to wishlist
        if (product != null) {
          await ref.read(favoritesRepositoryProvider).addToFavorites(
            productId: productId.toString(),
            productName: product.name,
            productPrice: product.price,
            productImageUrl: product.imageUrl,
            productCategory: product.categoryId.toString(),
            productBrand: product.brandId?.toString(),
          );
        } else {
          // If no product provided, we still add it but with minimal info
          await ref.read(favoritesRepositoryProvider).addToFavorites(
            productId: productId.toString(),
            productName: 'Product $productId',
          );
        }
      } else {
        // Remove from wishlist
        await ref.read(favoritesRepositoryProvider).removeFromFavorites(productId.toString());
      }
      
      // Reload the full wishlist to keep it in sync
      await _loadWishlistStatus();
      
    } catch (e) {
      // On error, revert the optimistic update
      final currentStatus = !state.productWishlistStatus[productId]!;
      state = state.copyWith(
        productWishlistStatus: {
          ...state.productWishlistStatus,
          productId: currentStatus
        },
        error: 'Failed to update wishlist: $e',
      );
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    try {
      // Optimistically update UI
      state = state.copyWith(
        productWishlistStatus: {
          ...state.productWishlistStatus,
          productId: false
        },
        favoriteProducts: state.favoriteProducts
            .where((fav) => fav.productId != productId.toString())
            .toList(),
      );
      
      // Update on server
      await ref.read(favoritesRepositoryProvider).removeFromFavorites(productId.toString());
      
    } catch (e) {
      // On error, reload the wishlist
      await _loadWishlistStatus();
      state = state.copyWith(error: 'Failed to remove from wishlist: $e');
    }
  }

  Future<void> refreshWishlist() async {
    await _loadWishlistStatus();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class UnifiedWishlistState {
  final Map<int, bool> productWishlistStatus;
  final List<FavoriteProduct> favoriteProducts;
  final bool isLoading;
  final String? error;

  const UnifiedWishlistState({
    required this.productWishlistStatus,
    required this.favoriteProducts,
    required this.isLoading,
    this.error,
  });

  factory UnifiedWishlistState.initial() {
    return const UnifiedWishlistState(
      productWishlistStatus: {},
      favoriteProducts: [],
      isLoading: false,
    );
  }

  UnifiedWishlistState copyWith({
    Map<int, bool>? productWishlistStatus,
    List<FavoriteProduct>? favoriteProducts,
    bool? isLoading,
    String? error,
  }) {
    return UnifiedWishlistState(
      productWishlistStatus: productWishlistStatus ?? this.productWishlistStatus,
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get wishlistCount => favoriteProducts.length;
  
  bool isProductWishlisted(int productId) {
    return productWishlistStatus[productId] ?? false;
  }
}