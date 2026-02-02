import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/utils/image_url_helper.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';
import 'package:wealth_app/core/utils/currency_utils.dart';
import 'package:wealth_app/core/responsive/responsive_helper.dart';
import 'package:wealth_app/core/responsive/responsive_widgets.dart';
import 'package:wealth_app/shared/widgets/optimized_cached_image.dart';
import 'package:wealth_app/core/utils/accessibility_utils.dart';
import 'package:wealth_app/shared/models/product.dart';
import 'package:wealth_app/shared/widgets/wishlist_icon_button.dart';
import 'package:wealth_app/features/wishlist/domain/unified_wishlist_notifier.dart';

class ModernProductCard extends ConsumerStatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final bool showQuickActions;

  const ModernProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddToCart,
    this.showQuickActions = true,
  });

  @override
  ConsumerState<ModernProductCard> createState() => _ModernProductCardState();
}

class _ModernProductCardState extends ConsumerState<ModernProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150), // Reduced duration for better performance
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (_isHovered == isHovered) return; // Prevent unnecessary rebuilds
    
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _hoverController.forward();
      HapticFeedbackUtils.lightImpact();
    } else {
      _hoverController.reverse();
    }
  }



  String _getImageUrl(String imageUrl) {
    return ImageUrlHelper.getProductImageUrl(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Create comprehensive semantic label for screen readers
    final semanticLabel = AccessibilityUtils.createSemanticLabel(
      primaryText: widget.product.name,
      secondaryText: AccessibilityUtils.createPriceSemanticLabel(widget.product.price),
      statusText: widget.product.rating > 0 
          ? AccessibilityUtils.createRatingSemanticLabel(widget.product.rating, widget.product.reviewCount)
          : null,
      actionHint: 'Double tap to view product details',
    );
    
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: true,
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _hoverController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_hoverController.value * 0.02),
                child: Container(
                  // Ensure minimum touch target size for accessibility
                  constraints: BoxConstraints(
                    minWidth: context.responsiveTouchTarget,
                    minHeight: context.responsiveTouchTarget,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
                        blurRadius: _isHovered ? 12 : 8,
                        offset: Offset(0, _isHovered ? 6 : 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image with improved aspect ratio
                      Expanded(
                        flex: 8, // Increased for larger image display
                        child: _buildProductImage(isDark),
                      ),
                      
                      // Product details with better spacing
                      Expanded(
                        flex: 2,
                        child: _buildProductDetails(isDark),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(bool isDark) {
    return Stack(
      clipBehavior: Clip.none, // Allow buttons to overflow
      children: [
        // Main product image with improved sizing and aspect ratio
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.responsiveBorderRadius),
            topRight: Radius.circular(context.responsiveBorderRadius),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[50]!,
                  Colors.grey[100]!,
                ],
              ),
            ),
            child: AspectRatio(
              aspectRatio: 1.0, // Square aspect ratio for consistent display
              child: OptimizedCachedImage(
                imageUrl: _getImageUrl(widget.product.displayImageUrl),
                fit: BoxFit.cover, // Fill the entire space
                placeholder: _buildShimmerPlaceholder(),
                errorWidget: _buildErrorPlaceholder(),
              ),
            ),
          ),
        ),
        
        // Enhanced wishlist heart icon with hover and click effects
        Positioned(
          top: context.responsive<double>(mobile: 8.0, tablet: 12.0, desktop: 16.0),
          right: context.responsive<double>(mobile: 8.0, tablet: 12.0, desktop: 16.0),
          child: WishlistIconButton(
            productId: widget.product.id,
            product: widget.product,
            size: 18.0,
            showBackground: true,
          ),
        ),
        
        // Add to cart button positioned at bottom right of image (Chrome style)
        if (widget.onAddToCart != null && widget.product.stock > 0)
          Positioned(
            bottom: context.responsive<double>(mobile: 8.0, tablet: 12.0, desktop: 16.0),
            right: context.responsive<double>(mobile: 8.0, tablet: 12.0, desktop: 16.0),
            child: _buildCartButton(),
          ),

      ],
    );
  }

  Widget _buildProductDetails(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(context.responsive<double>(mobile: 8.0, tablet: 12.0, desktop: 16.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product name with enhanced typography
          Flexible(
            child: ResponsiveText(
              widget.product.name,
              style: TypographyUtils.getProductTitleStyle(
                context,
                size: ProductTitleSize.medium,
                isEmphasis: true,
              ),
              maxLines: 2,
              minFontSize: 12,
              maxFontSize: 18,
            ),
          ),
          
          SizedBox(height: context.responsive<double>(mobile: 4.0, tablet: 6.0, desktop: 8.0)),
          
          // Price with enhanced emphasis treatment
          ResponsiveText(
            CurrencyUtils.formatPrice(widget.product.price),
            style: TypographyUtils.getPriceStyle(
              context,
              size: PriceSize.medium,
            ),
            maxLines: 1,
            minFontSize: 12,
            maxFontSize: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildCartButton() {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        bool isPressed = false;
        
        return Semantics(
          label: 'Add to cart',
          hint: 'Double tap to add ${widget.product.name} to cart',
          button: true,
          enabled: true,
          onTap: widget.onAddToCart,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: GestureDetector(
              onTapDown: (_) => setState(() => isPressed = true),
              onTapUp: (_) => setState(() => isPressed = false),
              onTapCancel: () => setState(() => isPressed = false),
              onTap: () {
                HapticFeedbackUtils.addItem();
                widget.onAddToCart?.call();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                width: context.responsive<double>(mobile: 44.0, tablet: 48.0, desktop: 52.0),
                height: context.responsive<double>(mobile: 44.0, tablet: 48.0, desktop: 52.0),
                transform: Matrix4.identity()
                  ..scale(isPressed ? 0.9 : isHovered ? 1.05 : 1.0),
                decoration: BoxDecoration(
                  color: isPressed 
                      ? AppColors.primary.withValues(alpha: 0.8)
                      : isHovered 
                          ? AppColors.primary.withValues(alpha: 0.9)
                          : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: isHovered ? 0.4 : 0.3),
                      blurRadius: isHovered ? 12 : 8,
                      offset: Offset(0, isHovered ? 4 : 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: context.responsive<double>(mobile: 20.0, tablet: 22.0, desktop: 24.0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  Widget _buildQuickActions() {
    debugPrint('🛒 Quick Actions - onAddToCart: ${widget.onAddToCart != null}, stock: ${widget.product.stock}, product: ${widget.product.name}');
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onAddToCart != null && widget.product.stock > 0)
          _buildQuickActionButton(
            icon: Icons.add_shopping_cart,
            onTap: widget.onAddToCart!,
            tooltip: 'Add to Cart',
          ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isActionHovered = false;
        bool isActionPressed = false;
        
        return Semantics(
          label: tooltip,
          hint: 'Double tap to $tooltip for ${widget.product.name}',
          button: true,
          enabled: true,
          onTap: onTap,
          child: Tooltip(
            message: tooltip,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => isActionHovered = true),
              onExit: (_) => setState(() => isActionHovered = false),
              child: GestureDetector(
                onTapDown: (_) => setState(() => isActionPressed = true),
                onTapUp: (_) => setState(() => isActionPressed = false),
                onTapCancel: () => setState(() => isActionPressed = false),
                onTap: () {
                  HapticFeedbackUtils.addItem();
                  onTap();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(left: 8),
                  transform: Matrix4.identity()
                    ..scale(isActionPressed ? 0.9 : isActionHovered ? 1.05 : 1.0),
                  decoration: BoxDecoration(
                    color: isActionPressed 
                        ? AppColors.primary.withValues(alpha: 0.8)
                        : isActionHovered 
                            ? AppColors.primary.withValues(alpha: 0.9)
                            : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: isActionHovered ? 0.4 : 0.3),
                        blurRadius: isActionHovered ? 12 : 8,
                        offset: Offset(0, isActionHovered ? 4 : 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: TypographyUtils.getLabelStyle(
              context,
              size: LabelSize.small,
              isSecondary: true,
            ),
          ),
        ],
      ),
    );
  }
}