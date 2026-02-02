import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/features/products/data/product_repository.dart';
import 'package:wealth_app/features/cart/domain/cart_notifier.dart';
import 'package:wealth_app/shared/models/product.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  final PageController _pageController = PageController();
  Product? _product;
  bool _isLoading = true;
  String? _error;
  
  // Variant selection state
  ProductVariant? _selectedVariant;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final repository = ref.read(productRepositoryProvider);
      final product = await repository.getProduct(widget.productId);

      // Handle deleted/unavailable product
      if (product == null) {
        setState(() {
          _product = null;
          _isLoading = false;
          _error = 'product_unavailable'; // Special flag for unavailable products
        });
        return;
      }

      setState(() {
        _product = product;
        _isLoading = false;
        // Auto-select first variant if variable product
        if (product.productType == ProductType.variable && product.variants.isNotEmpty) {
          _selectedVariant = product.variants.first;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildProductUnavailableView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Product No Longer Available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'This product has been removed or is no longer available. It will be automatically removed from your wishlist and cart.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.go('/home');
                  },
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Browse Products'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Invalidate product provider to refresh list when returning
            ref.invalidate(productRepositoryProvider);
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error == 'product_unavailable'
              ? _buildProductUnavailableView()
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error: $_error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadProduct,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _product == null
                      ? const Center(child: Text('Product not found'))
                      : _buildProductDetails(_product!),
      bottomNavigationBar: _product != null ? _buildBottomBar(_product!) : null,
    );
  }

  Widget _buildProductDetails(Product product) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Carousel
          _buildImageCarousel(product),

          const SizedBox(height: AppSpacing.lg),

          // Product Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Price
                Text(
                  '₦${_getCurrentPrice(product).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Stock Status
                _buildStockStatus(product),

                const SizedBox(height: AppSpacing.xl),

                // Variant Selection (for variable products ONLY)
                if (product.productType == ProductType.variable) ...[
                  _buildVariantSelection(product),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Quantity Selector (for single products OR after variant selection)
                if (_canShowQuantitySelector(product)) ...[
                  _buildQuantitySelector(),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(Product product) {
    final images = _getAllVariantImages(product);

    return Column(
      children: [
        // Main Image
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
              // Auto-select variant when swiping to its image
              if (product.productType == ProductType.variable) {
                _selectVariantByImage(product, images[index]);
              }
            },
            itemBuilder: (context, index) {
              return Container(
                width: double.infinity,
                color: Colors.grey[50],
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('Image not available', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Thumbnail Indicators
        if (images.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentImageIndex;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    // Auto-select variant when clicking thumbnail
                    if (product.productType == ProductType.variable) {
                      _selectVariantByImage(product, images[index]);
                    }
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported, size: 24, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // Get all images: variant images first, then product images
  List<String> _getAllVariantImages(Product product) {
    final Set<String> allImages = {};
    
    // Add variant images first (each variant's unique image)
    if (product.productType == ProductType.variable) {
      for (final variant in product.variants) {
        if (variant.displayImage.isNotEmpty) {
          allImages.add(variant.displayImage);
        }
      }
    }
    
    // Add product images (excluding duplicates)
    final productImages = product.imageUrls ?? [];
    for (final img in productImages) {
      if (img.isNotEmpty) {
        allImages.add(img);
      }
    }
    
    return allImages.isNotEmpty 
        ? allImages.toList() 
        : ['https://via.placeholder.com/400x400?text=No+Image'];
  }

  // Auto-select variant when clicking/swiping to an image
  void _selectVariantByImage(Product product, String imageUrl) {
    for (final variant in product.variants) {
      if (variant.displayImage == imageUrl) {
        setState(() {
          _selectedVariant = variant;
          _quantity = 1;
        });
        break;
      }
    }
  }

  // Scroll to variant's image when variant is selected
  void _scrollToVariantImage(Product product, ProductVariant variant) {
    if (variant.displayImage.isEmpty) return;
    
    final images = _getAllVariantImages(product);
    final index = images.indexOf(variant.displayImage);
    
    if (index >= 0 && index != _currentImageIndex) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildStockStatus(Product product) {
    final stock = _getAvailableStock(product);
    final inStock = stock > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: inStock ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: inStock ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            inStock ? Icons.check_circle : Icons.cancel,
            color: inStock ? Colors.green[700] : Colors.red[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            inStock ? 'In Stock ($stock available)' : 'Out of Stock',
            style: TextStyle(
              color: inStock ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantSelection(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Variant',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...product.variants.map((variant) {
          final isSelected = _selectedVariant?.id == variant.id;
          final attributesText = variant.attributes.entries
              .map((e) => '${e.key}: ${e.value}')
              .join(' • ');

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedVariant = variant;
                _quantity = 1; // Reset quantity when variant changes
              });
              // Scroll to variant's image
              _scrollToVariantImage(product, variant);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Variant Image (if available)
                  if (variant.displayImage.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: variant.displayImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: Icon(Icons.image, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],

                  // Variant Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variant.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        if (attributesText.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            attributesText,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '₦${variant.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.primary : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              variant.stock > 0 ? '${variant.stock} in stock' : 'Out of stock',
                              style: TextStyle(
                                fontSize: 14,
                                color: variant.stock > 0 ? Colors.green[700] : Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Selection Indicator
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 28,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            IconButton(
              onPressed: _quantity > 1
                  ? () {
                      setState(() {
                        _quantity--;
                      });
                    }
                  : null,
              icon: const Icon(Icons.remove_circle),
              color: AppColors.primary,
              iconSize: 36,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _quantity.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _quantity++;
                });
              },
              icon: const Icon(Icons.add_circle),
              color: AppColors.primary,
              iconSize: 36,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(Product product) {
    final canAddToCart = _canAddToCart(product);
    final isVariableProduct = product.productType == ProductType.variable;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Add to Cart Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canAddToCart
                    ? () async {
                        if (isVariableProduct && _selectedVariant == null) {
                          _showMessage('Please select a variant', isError: true);
                          return;
                        }
                        await _addToCart(product);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAddToCart ? Colors.grey[800] : Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                ),
                icon: const Icon(Icons.shopping_cart_outlined, size: 22),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Buy Now Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canAddToCart
                    ? () async {
                        if (isVariableProduct && _selectedVariant == null) {
                          _showMessage('Please select a variant', isError: true);
                          return;
                        }
                        
                        try {
                          // Get the currently selected image for single products
                          final images = _getAllVariantImages(product);
                          final selectedImage = images.isNotEmpty && _currentImageIndex < images.length
                              ? images[_currentImageIndex]
                              : null;
                          
                          await ref.read(cartNotifierProvider.notifier).addItem(
                                product,
                                quantity: _quantity,
                                variant: _selectedVariant,
                                selectedImageUrl: selectedImage,
                              );
                          
                          if (mounted) {
                            // Navigate to cart immediately without showing snackbar
                            context.push('/cart-view');
                          }
                        } catch (e) {
                          if (mounted) {
                            _showMessage('Failed to add to cart: $e', isError: true);
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAddToCart ? AppColors.primary : Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                ),
                icon: const Icon(Icons.shopping_bag, size: 22),
                label: const Text(
                  'Buy Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods - use _getAllVariantImages instead for carousel

  int _getAvailableStock(Product product) {
    if (product.productType == ProductType.variable) {
      return _selectedVariant?.stock ?? 0;
    }
    return product.stock;
  }

  double _getCurrentPrice(Product product) {
    if (product.productType == ProductType.variable && _selectedVariant != null) {
      return _selectedVariant!.price;
    }
    return product.price;
  }

  bool _canShowQuantitySelector(Product product) {
    if (product.productType == ProductType.single) {
      return product.stock > 0;
    }
    // For variable products, show only after variant selection
    return _selectedVariant != null && _selectedVariant!.stock > 0;
  }

  bool _canAddToCart(Product product) {
    if (product.productType == ProductType.single) {
      return product.stock > 0;
    }
    return _selectedVariant != null && _selectedVariant!.stock > 0;
  }

  Future<void> _addToCart(Product product) async {
    try {
      // Get the currently selected image for single products
      final images = _getAllVariantImages(product);
      final selectedImage = images.isNotEmpty && _currentImageIndex < images.length
          ? images[_currentImageIndex]
          : null;
      
      await ref.read(cartNotifierProvider.notifier).addItem(
            product,
            quantity: _quantity,
            variant: _selectedVariant,
            selectedImageUrl: selectedImage,
          );
      
      if (mounted) {
        final variantInfo = _selectedVariant != null
            ? ' (${_selectedVariant!.name})'
            : '';
        _showMessage('${product.name}$variantInfo added to cart');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to add to cart: $e', isError: true);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
