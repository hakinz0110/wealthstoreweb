import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/features/categories/domain/category_notifier.dart';
import 'package:wealth_app/features/products/domain/product_notifier.dart';
import 'package:wealth_app/features/cart/domain/cart_notifier.dart';
import 'package:wealth_app/features/wishlist/domain/unified_wishlist_notifier.dart';
import 'package:wealth_app/shared/widgets/modern_product_card.dart';

import 'package:wealth_app/shared/widgets/shimmer_loading.dart';

class CategoryProductPage extends ConsumerStatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<CategoryProductPage> createState() => _CategoryProductPageState();
}

class _CategoryProductPageState extends ConsumerState<CategoryProductPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Load products for this category
    Future.microtask(() {
      ref.read(productNotifierProvider.notifier).loadProducts(categoryId: widget.categoryId);
      ref.read(unifiedWishlistNotifierProvider.notifier).refreshWishlist();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final productState = ref.read(productNotifierProvider);
      if (!productState.isLoading && productState.hasMore) {
        ref
            .read(productNotifierProvider.notifier)
            .loadMoreProducts(categoryId: widget.categoryId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);
    final wishlistState = ref.watch(unifiedWishlistNotifierProvider);

    // Use filtered products as they contain the correct filtering logic
    final products = productState.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(productNotifierProvider.notifier)
              .loadProducts(categoryId: widget.categoryId);
        },
        child: _buildProductGrid(products, productState, wishlistState),
      ),
    );
  }

  Widget _buildProductGrid(
    List<dynamic> products,
    dynamic productState,
    dynamic wishlistState,
  ) {
    if (productState.isLoading && products.isEmpty) {
      return const ProductGridSkeleton(itemCount: 6);
    }

    if (productState.error != null && products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(productState.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(productNotifierProvider.notifier).loadProducts(categoryId: widget.categoryId);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No products found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('No products available in ${widget.categoryName} category.'),
          ],
        ),
      );
    }

    // Create list of widgets including loading placeholders
    final allItems = <Widget>[];
    
    // Add product cards
    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      
      allItems.add(
        ModernProductCard(
          product: product,
          onTap: () {
            context.push('/product/${product.id}');
          },
          onAddToCart: () {
            ref.read(cartNotifierProvider.notifier)
                .addItem(product, quantity: 1);
            
            // Show snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} added to cart'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      );
    }
    
    // Add loading placeholders if needed
    if (productState.isLoading && products.isNotEmpty) {
      for (int i = 0; i < 2; i++) {
        allItems.add(
          const ShimmerLoading(
            child: ProductCardSkeleton(),
          ),
        );
      }
    }
    
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.7,
      ),
      itemCount: allItems.length,
      itemBuilder: (context, index) => allItems[index],
    );
  }
}

class ProductGridSkeleton extends StatelessWidget {
  final int itemCount;

  const ProductGridSkeleton({
    super.key,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.7,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerLoading(
        child: ProductCardSkeleton(),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
          ),
          // Content skeleton
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 80,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}