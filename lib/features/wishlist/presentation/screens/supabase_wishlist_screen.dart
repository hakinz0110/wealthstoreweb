import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/features/wishlist/data/favorites_repository.dart';
import 'package:wealth_app/features/wishlist/domain/unified_wishlist_notifier.dart';
import 'package:wealth_app/shared/widgets/custom_button.dart';
import 'package:wealth_app/shared/widgets/error_state_widget.dart';

class SupabaseWishlistScreen extends ConsumerStatefulWidget {
  const SupabaseWishlistScreen({super.key});

  @override
  ConsumerState<SupabaseWishlistScreen> createState() => _SupabaseWishlistScreenState();
}

class _SupabaseWishlistScreenState extends ConsumerState<SupabaseWishlistScreen> {
  String _selectedCategory = 'all';
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final wishlistState = ref.watch(unifiedWishlistNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Items')),
              const PopupMenuItem(value: 'general', child: Text('General')),
              const PopupMenuItem(value: 'electronics', child: Text('Electronics')),
              const PopupMenuItem(value: 'clothing', child: Text('Clothing')),
              const PopupMenuItem(value: 'home', child: Text('Home & Garden')),
            ],
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (wishlistState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (wishlistState.error != null) {
            return ErrorStateWidget(
              error: wishlistState.error,
              onRetry: () {
                ref.read(unifiedWishlistNotifierProvider.notifier).refreshWishlist();
              },
            );
          }

          final favorites = _selectedCategory == 'all'
              ? wishlistState.favoriteProducts
              : wishlistState.favoriteProducts
                  .where((fav) => fav.wishlistCategory == _selectedCategory)
                  .toList();


          if (favorites.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(unifiedWishlistNotifierProvider.notifier).refreshWishlist();
            },
            child: _isGridView
                ? _buildGridView(favorites)
                : _buildListView(favorites),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/products');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Items'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 120,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Your wishlist is empty',
              style: AppTextStyles.headlineSmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Start adding products you love to your wishlist',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            CustomButton(
              text: 'Browse Products',
              onPressed: () {
                context.go('/products');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<FavoriteProduct> favorites) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return _buildFavoriteCard(favorite);
      },
    );
  }

  Widget _buildGridView(List<FavoriteProduct> favorites) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return _buildFavoriteGridCard(favorite);
      },
    );
  }

  Widget _buildFavoriteCard(FavoriteProduct favorite) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          context.push('/product/${favorite.productId}');
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                color: Colors.grey.shade200,
              ),
              child: favorite.productImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: Image.network(
                        favorite.productImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported);
                        },
                      ),
                    )
                  : const Icon(Icons.image_not_supported),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favorite.productName,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  if (favorite.productBrand != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      favorite.productBrand!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  if (favorite.productPrice != null) ...[
                    Text(
                      '₦${favorite.productPrice!.toStringAsFixed(2)}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  
                  if (favorite.targetPrice != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          size: 16,
                          color: favorite.priceAlertEnabled 
                              ? AppColors.primary 
                              : Colors.grey,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Alert at ₦${favorite.targetPrice!.toStringAsFixed(2)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: favorite.priceAlertEnabled 
                                ? AppColors.primary 
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                  

                ],
              ),
            ),
            
            // Actions
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: () {
                _showDeleteDialog(favorite);
              },
              tooltip: 'Remove from wishlist',
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildFavoriteGridCard(FavoriteProduct favorite) {
    return Card(
      child: InkWell(
        onTap: () {
          context.push('/product/${favorite.productId}');
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusSm),
                ),
                color: Colors.grey.shade200,
              ),
              child: favorite.productImageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppSpacing.radiusSm),
                      ),
                      child: Image.network(
                        favorite.productImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported);
                        },
                      ),
                    )
                  : const Icon(Icons.image_not_supported),
            ),
          ),
          
          // Product Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favorite.productName,
                    style: AppTextStyles.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(),
                  
                  if (favorite.productPrice != null) ...[
                    Text(
                      '₦${favorite.productPrice!.toStringAsFixed(2)}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        iconSize: 20,
                        onPressed: () {
                          _showDeleteDialog(favorite);
                        },
                        tooltip: 'Remove from wishlist',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showDeleteDialog(FavoriteProduct favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Wishlist'),
        content: Text('Are you sure you want to remove "${favorite.productName}" from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(favoritesRepositoryProvider)
                    .removeFromFavorites(favorite.productId);
                
                if (mounted) {
                  Navigator.of(context).pop();
                  
                  // Refresh the wishlist data
                  await ref.read(unifiedWishlistNotifierProvider.notifier).refreshWishlist();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item removed from wishlist'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  debugPrint('❌ Error removing wishlist item: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unable to remove item'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _EditFavoriteDialog extends ConsumerStatefulWidget {
  final FavoriteProduct favorite;

  const _EditFavoriteDialog({required this.favorite});

  @override
  ConsumerState<_EditFavoriteDialog> createState() => _EditFavoriteDialogState();
}

class _EditFavoriteDialogState extends ConsumerState<_EditFavoriteDialog> {
  late String _category;
  late int _priority;
  late String _notes;
  late double? _targetPrice;
  late bool _priceAlertEnabled;
  
  final _notesController = TextEditingController();
  final _targetPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _category = widget.favorite.wishlistCategory;
    _priority = widget.favorite.priority;
    _notes = widget.favorite.notes ?? '';
    _targetPrice = widget.favorite.targetPrice;
    _priceAlertEnabled = widget.favorite.priceAlertEnabled;
    
    _notesController.text = _notes;
    _targetPriceController.text = _targetPrice?.toString() ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    _targetPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Wishlist Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('General')),
                DropdownMenuItem(value: 'electronics', child: Text('Electronics')),
                DropdownMenuItem(value: 'clothing', child: Text('Clothing')),
                DropdownMenuItem(value: 'home', child: Text('Home & Garden')),
              ],
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Priority Slider
            Text('Priority: $_priority'),
            Slider(
              value: _priority.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (value) {
                setState(() {
                  _priority = value.round();
                });
              },
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            TextField(
              controller: _targetPriceController,
              decoration: const InputDecoration(
                labelText: 'Target Price',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            SwitchListTile(
              title: const Text('Price Alert'),
              subtitle: const Text('Get notified when price drops'),
              value: _priceAlertEnabled,
              onChanged: (value) {
                setState(() {
                  _priceAlertEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            try {
              await ref.read(favoritesRepositoryProvider).updateFavorite(
                productId: widget.favorite.productId,
                wishlistCategory: _category,
                priority: _priority,
                notes: _notesController.text.trim().isEmpty 
                    ? null 
                    : _notesController.text.trim(),
                targetPrice: _targetPriceController.text.trim().isEmpty 
                    ? null 
                    : double.tryParse(_targetPriceController.text.trim()),
                priceAlertEnabled: _priceAlertEnabled,
              );
              
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wishlist item updated'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                debugPrint('❌ Error updating wishlist item: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unable to update item'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}