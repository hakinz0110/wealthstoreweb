import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/utils/image_url_helper.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/currency_utils.dart';
import 'package:wealth_app/features/cart/domain/cart_notifier.dart';
import 'package:wealth_app/features/wishlist/domain/wishlist_notifier.dart';

class ModernCartScreen extends ConsumerStatefulWidget {
  const ModernCartScreen({super.key});

  @override
  ConsumerState<ModernCartScreen> createState() => _ModernCartScreenState();
}

class _ModernCartScreenState extends ConsumerState<ModernCartScreen>
    with TickerProviderStateMixin {
  bool _isPricingExpanded = false;
  bool _isCheckingOut = false;
  late AnimationController _checkoutController;

  static const double freeShippingThreshold = 50000.0;

  @override
  void initState() {
    super.initState();
    _checkoutController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _checkoutController.dispose();
    super.dispose();
  }

  void _togglePricingBreakdown() {
    setState(() {
      _isPricingExpanded = !_isPricingExpanded;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _proceedToCheckout() async {
    setState(() {
      _isCheckingOut = true;
    });
    
    _checkoutController.forward();
    HapticFeedback.mediumImpact();
    
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      context.push('/checkout');
      setState(() {
        _isCheckingOut = false;
      });
      _checkoutController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: cartState.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : cartState.error != null
            ? _buildErrorState(cartState.error!)
            : _buildCartContent(cartState),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TypographyUtils.getHeadingStyle(
                context,
                HeadingLevel.h4,
                isEmphasis: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TypographyUtils.getBodyStyle(
                context,
                size: BodySize.medium,
                isSecondary: true,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(cartNotifierProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(dynamic cartState) {
    if (cartState.items.isEmpty) {
      return _buildEmptyCart();
    }
    
    final notifier = ref.read(cartNotifierProvider.notifier);
    final selectedCount = notifier.selectedCount;
    final allSelected = notifier.allSelected;
    
    return Column(
      children: [
        _buildHeader(cartState),
        // Select All row
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          color: Colors.white,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (allSelected) {
                    notifier.deselectAll();
                  } else {
                    notifier.selectAll();
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: allSelected ? AppColors.primary : Colors.transparent,
                        border: Border.all(
                          color: allSelected ? AppColors.primary : AppColors.neutral400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: allSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Select All',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '$selectedCount of ${cartState.items.length} selected',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.neutral600),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(cartNotifierProvider);
            },
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: cartState.items.length,
              itemBuilder: (context, index) {
                final item = cartState.items[index];
                return ModernCartItem(
                  item: item,
                  onSelectionChanged: (selected) {
                    notifier.toggleItemSelection(item.id ?? item.productId);
                  },
                  onQuantityChanged: (quantity) {
                    ref.read(cartNotifierProvider.notifier).updateQuantity(
                      item.id ?? item.productId, 
                      quantity,
                      variantId: item.variantId,
                    );
                  },
                  onRemovePressed: () {
                    ref.read(cartNotifierProvider.notifier).removeItem(
                      item.id ?? item.productId,
                      variantId: item.variantId,
                    );
                  },
                  onSaveForLater: () {
                    ref.read(wishlistNotifierProvider.notifier).toggleWishlist(item.productId);
                    ref.read(cartNotifierProvider.notifier).removeItem(
                      item.id ?? item.productId,
                      variantId: item.variantId,
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.name} saved for later'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'View Wishlist',
                          onPressed: () => context.go('/wishlist'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        _buildCartSummary(cartState),
      ],
    );
  }

  Widget _buildHeader(dynamic cartState) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            icon: const Icon(Icons.arrow_back_ios),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.neutral100,
              foregroundColor: AppColors.neutral700,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Your Cart',
            style: TypographyUtils.getHeadingStyle(
              context,
              HeadingLevel.h3,
              isEmphasis: true,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${cartState.itemCount} items',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 70,
                color: AppColors.primary,
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),
            
            const SizedBox(height: 32),
            
            Text(
              'Your cart is empty',
              style: TypographyUtils.getHeadingStyle(
                context,
                HeadingLevel.h3,
                isEmphasis: true,
              ),
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 12),
            
            Text(
              'Looks like you haven\'t added any items yet.\nStart shopping to fill it up!',
              style: TypographyUtils.getBodyStyle(
                context,
                size: BodySize.large,
                isSecondary: true,
              ),
              textAlign: TextAlign.center,
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 400.ms),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/products'),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Start Shopping'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            )
                .animate(delay: 600.ms)
                .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }

  double _calculateShipping(dynamic cartState) {
    if (cartState.total > freeShippingThreshold) {
      return 0.0;
    }
    
    double totalShipping = 0.0;
    for (var item in cartState.items) {
      final shippingRate = item.shippingRate ?? 0.08;
      totalShipping += item.price * item.quantity * shippingRate;
    }
    return totalShipping;
  }

  Widget _buildCartSummary(dynamic cartState) {
    final subtotal = cartState.subtotal;
    final shipping = cartState.shipping;
    final total = cartState.total;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _togglePricingBreakdown,
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.receipt_long_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Order Summary',
                          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          CurrencyUtils.formatPrice(total),
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: _isPricingExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.keyboard_arrow_down, color: AppColors.neutral600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isPricingExpanded ? null : 0,
              child: _isPricingExpanded
                  ? Container(
                      padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.neutral50.withValues(alpha: 0.5),
                      ),
                      child: Column(
                        children: [
                          const Divider(),
                          _buildSummaryRow('Subtotal', CurrencyUtils.formatPrice(subtotal)),
                          _buildSummaryRow(
                            'Shipping', 
                            shipping == 0 ? 'Free' : CurrencyUtils.formatPrice(shipping),
                            subtitle: shipping == 0 
                                ? 'Free shipping on orders over ${CurrencyUtils.formatPrice(freeShippingThreshold)}' 
                                : null,
                          ),
                          const Divider(),
                          _buildSummaryRow('Total', CurrencyUtils.formatPrice(total), isTotal: true),
                        ],
                      ),
                    )
                  : null,
            ),
            
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Builder(
                  builder: (context) {
                    final selectedCount = ref.watch(cartNotifierProvider.notifier).selectedCount;
                    final hasSelection = selectedCount > 0;
                    
                    return ElevatedButton(
                      onPressed: (_isCheckingOut || !hasSelection) ? null : _proceedToCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasSelection ? AppColors.primary : AppColors.neutral300,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: hasSelection ? 2 : 0,
                        disabledBackgroundColor: AppColors.neutral300,
                        disabledForegroundColor: AppColors.neutral500,
                      ),
                      child: _isCheckingOut
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Processing...',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock_outline, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  hasSelection 
                                      ? 'Checkout ($selectedCount ${selectedCount == 1 ? 'item' : 'items'})'
                                      : 'Select items to checkout',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: hasSelection ? Colors.white : AppColors.neutral500,
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: isTotal
                    ? AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)
                    : AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral700),
              ),
              Text(
                value,
                style: isTotal
                    ? AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      )
                    : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.local_shipping_outlined, size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      subtitle,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


class ModernCartItem extends StatefulWidget {
  final dynamic item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemovePressed;
  final VoidCallback onSaveForLater;
  final Function(bool)? onSelectionChanged;
  
  const ModernCartItem({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemovePressed,
    required this.onSaveForLater,
    this.onSelectionChanged,
  });

  @override
  State<ModernCartItem> createState() => _ModernCartItemState();
}

class _ModernCartItemState extends State<ModernCartItem> {
  void _handleRemove() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      widget.onRemovePressed();
    }
  }

  void _incrementQuantity() {
    widget.onQuantityChanged(widget.item.quantity + 1);
    HapticFeedback.lightImpact();
  }

  void _decrementQuantity() {
    if (widget.item.quantity > 1) {
      widget.onQuantityChanged(widget.item.quantity - 1);
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.item.isSelected ?? true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onSelectionChanged?.call(!isSelected);
            },
            child: Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.neutral400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child: CachedNetworkImage(
                imageUrl: ImageUrlHelper.getProductImageUrl(widget.item.imageUrl ?? ''),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.neutral100,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.neutral100,
                  child: Icon(Icons.image_not_supported, color: AppColors.neutral400),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.displayName,
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyUtils.formatPrice(widget.item.price),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildQuantityButton(
                      Icons.remove,
                      widget.item.quantity > 1 ? _decrementQuantity : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text(
                        '${widget.item.quantity}',
                        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildQuantityButton(Icons.add, _incrementQuantity),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: _handleRemove,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      CurrencyUtils.formatPrice(widget.item.price * widget.item.quantity),
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback? onPressed) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(
          color: onPressed == null 
              ? AppColors.neutral300 
              : AppColors.primary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        color: onPressed == null 
            ? AppColors.neutral50 
            : AppColors.primary.withValues(alpha: 0.1),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        color: onPressed == null ? AppColors.neutral400 : AppColors.primary,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
