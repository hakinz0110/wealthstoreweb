import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';
import 'package:wealth_app/features/wishlist/domain/unified_wishlist_notifier.dart';
import 'package:wealth_app/shared/models/product.dart';

class WishlistIconButton extends ConsumerStatefulWidget {
  final int productId;
  final Product? product;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showBackground;
  final VoidCallback? onToggle;

  const WishlistIconButton({
    super.key,
    required this.productId,
    this.product,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
    this.showBackground = true,
    this.onToggle,
  });

  @override
  ConsumerState<WishlistIconButton> createState() => _WishlistIconButtonState();
}

class _WishlistIconButtonState extends ConsumerState<WishlistIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    HapticFeedbackUtils.lightImpact();
    
    // Trigger animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    // Toggle wishlist
    await ref.read(unifiedWishlistNotifierProvider.notifier)
        .toggleWishlist(widget.productId, product: widget.product);
    
    // Call optional callback
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistState = ref.watch(unifiedWishlistNotifierProvider);
    final isWishlisted = wishlistState.isProductWishlisted(widget.productId);
    
    final activeColor = widget.activeColor ?? AppColors.error;
    final inactiveColor = widget.inactiveColor ?? Colors.grey[600]!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.9 : _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: widget.size + (widget.showBackground ? 20 : 0),
                height: widget.size + (widget.showBackground ? 20 : 0),
                decoration: widget.showBackground ? BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ) : null,
                child: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  size: widget.size,
                  color: isWishlisted ? activeColor : inactiveColor,
                ),
              )
                .animate(target: isWishlisted ? 1 : 0)
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.3, 1.3),
                  duration: 200.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.3, 1.3),
                  end: const Offset(1.0, 1.0),
                  duration: 200.ms,
                  curve: Curves.elasticOut,
                ),
            ),
          );
        },
      ),
    );
  }
}

/// A simplified wishlist toggle button for use in product cards
class SimpleWishlistButton extends ConsumerWidget {
  final int productId;
  final Product? product;
  final double size;
  final VoidCallback? onToggle;

  const SimpleWishlistButton({
    super.key,
    required this.productId,
    this.product,
    this.size = 20.0,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(unifiedWishlistNotifierProvider);
    final isWishlisted = wishlistState.isProductWishlisted(productId);

    return GestureDetector(
      onTap: () async {
        HapticFeedbackUtils.lightImpact();
        await ref.read(unifiedWishlistNotifierProvider.notifier)
            .toggleWishlist(productId, product: product);
        onToggle?.call();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: Icon(
          isWishlisted ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isWishlisted),
          size: size,
          color: isWishlisted ? AppColors.error : Colors.grey[600],
        ),
      ),
    );
  }
}

/// A wishlist button with count badge for navigation
class WishlistButtonWithBadge extends ConsumerWidget {
  final VoidCallback onTap;
  final double size;

  const WishlistButtonWithBadge({
    super.key,
    required this.onTap,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(unifiedWishlistNotifierProvider);
    final count = wishlistState.wishlistCount;

    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.favorite_border,
            size: size,
          ),
          onPressed: onTap,
        ),
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}