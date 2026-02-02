import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/responsive/responsive_helper.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';
import 'package:wealth_app/features/auth/domain/auth_notifier.dart';
import 'package:wealth_app/features/notifications/domain/notification_notifier.dart';

class TopActionBar extends ConsumerStatefulWidget {
  final String searchPlaceholder;
  final VoidCallback? onSearchTap;
  final Function(String)? onSearchSubmitted;
  final bool searchEnabled;

  const TopActionBar({
    super.key,
    this.searchPlaceholder = 'Search in Store',
    this.onSearchTap,
    this.onSearchSubmitted,
    this.searchEnabled = true,
  });

  @override
  ConsumerState<TopActionBar> createState() => _TopActionBarState();
}

class _TopActionBarState extends ConsumerState<TopActionBar> {
  bool _isSearchHovered = false;
  bool _isSearchPressed = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final notificationState = authState.isAuthenticated 
        ? ref.watch(notificationNotifierProvider)
        : null;
    final unreadCount = notificationState?.unreadCount ?? 0;
    
    return Row(
      children: [
        // Notification icon
        _buildNotificationIcon(context, unreadCount),
        
        SizedBox(width: context.responsive<double>(
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
        )),
        
        // Search bar (takes remaining space)
        Expanded(
          child: _buildSearchBar(context),
        ),
        
        SizedBox(width: context.responsive<double>(
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
        )),
        
        // Wishlist icon
        _buildWishlistIcon(context),
      ],
    );
  }

  Widget _buildNotificationIcon(BuildContext context, int unreadCount) {
    final iconSize = context.responsive<double>(
      mobile: 48.0,
      tablet: 52.0,
      desktop: 56.0,
    );
    
    return InkWell(
      onTap: () {
        HapticFeedbackUtils.lightImpact();
        context.push('/notifications');
      },
      borderRadius: BorderRadius.circular(iconSize / 2),
      child: Container(
        width: iconSize,
        height: iconSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Notification icon
            Center(
              child: Icon(
                Icons.notifications_outlined,
                size: context.responsive<double>(
                  mobile: 24.0,
                  tablet: 26.0,
                  desktop: 28.0,
                ),
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            // Badge for unread count
            if (unreadCount > 0)
              Positioned(
                top: context.responsive<double>(
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
                right: context.responsive<double>(
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: context.responsive<double>(
                      mobile: 16.0,
                      tablet: 18.0,
                      desktop: 20.0,
                    ),
                  ),
                  height: context.responsive<double>(
                    mobile: 16.0,
                    tablet: 18.0,
                    desktop: 20.0,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        fontSize: context.responsive<double>(
                          mobile: 10.0,
                          tablet: 11.0,
                          desktop: 12.0,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchHeight = context.responsive<double>(
      mobile: 48.0,
      tablet: 52.0,
      desktop: 56.0,
    );
    
    return MouseRegion(
      cursor: widget.searchEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: widget.searchEnabled ? (_) => setState(() => _isSearchHovered = true) : null,
      onExit: widget.searchEnabled ? (_) => setState(() => _isSearchHovered = false) : null,
      child: GestureDetector(
        onTapDown: widget.searchEnabled ? (_) => setState(() => _isSearchPressed = true) : null,
        onTapUp: widget.searchEnabled ? (_) => setState(() => _isSearchPressed = false) : null,
        onTapCancel: widget.searchEnabled ? () => setState(() => _isSearchPressed = false) : null,
        onTap: widget.searchEnabled ? () => _handleSearchTap(context) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: searchHeight,
          transform: Matrix4.identity()
            ..scale(_isSearchPressed ? 0.98 : _isSearchHovered ? 1.01 : 1.0),
          decoration: BoxDecoration(
            color: _isSearchHovered 
                ? (isDark 
                    ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.8)
                    : Theme.of(context).colorScheme.surface)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(searchHeight / 2),
            border: Border.all(
              color: _isSearchHovered 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: _isSearchHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isSearchHovered 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: _isSearchHovered ? 12 : 4,
                offset: Offset(0, _isSearchHovered ? 6 : 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Search icon
              Padding(
                padding: EdgeInsets.only(
                  left: context.responsive<double>(
                    mobile: 16.0,
                    tablet: 18.0,
                    desktop: 20.0,
                  ),
                  right: context.responsive<double>(
                    mobile: 12.0,
                    tablet: 14.0,
                    desktop: 16.0,
                  ),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..scale(_isSearchHovered ? 1.1 : 1.0),
                  child: Icon(
                    Icons.search,
                    size: context.responsive<double>(
                      mobile: _isSearchHovered ? 26.0 : 24.0,
                      tablet: _isSearchHovered ? 28.0 : 26.0,
                      desktop: _isSearchHovered ? 30.0 : 28.0,
                    ),
                    color: _isSearchHovered 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              
              // Placeholder text
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: context.responsive<double>(
                      mobile: 16.0,
                      tablet: 18.0,
                      desktop: 20.0,
                    ),
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TypographyUtils.getBodyStyle(
                      context,
                      size: context.responsive<BodySize>(
                        mobile: BodySize.medium,
                        tablet: BodySize.large,
                        desktop: BodySize.large,
                      ),
                      isSecondary: !_isSearchHovered,
                    ).copyWith(
                      color: _isSearchHovered 
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: _isSearchHovered ? FontWeight.w500 : FontWeight.normal,
                    ),
                    child: Text(widget.searchPlaceholder),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWishlistIcon(BuildContext context) {
    final iconSize = context.responsive<double>(
      mobile: 48.0,
      tablet: 52.0,
      desktop: 56.0,
    );
    
    return InkWell(
      onTap: () {
        HapticFeedbackUtils.lightImpact();
        context.push('/wishlist');
      },
      borderRadius: BorderRadius.circular(iconSize / 2),
      child: Container(
        width: iconSize,
        height: iconSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.favorite_outline,
            size: context.responsive<double>(
              mobile: 24.0,
              tablet: 26.0,
              desktop: 28.0,
            ),
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _handleSearchTap(BuildContext context) {
    HapticFeedbackUtils.lightImpact();
    
    if (widget.onSearchTap != null) {
      widget.onSearchTap!();
    } else {
      // Default behavior: navigate to search screen
      context.push('/search');
    }
  }
}