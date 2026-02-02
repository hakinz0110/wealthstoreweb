import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/config/app_config.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';
import 'package:wealth_app/core/responsive/responsive_helper.dart';
import 'package:wealth_app/core/responsive/responsive_widgets.dart';
import 'package:wealth_app/features/home/providers/banner_providers.dart';
import 'package:wealth_app/features/home/utils/banner_navigation_helper.dart';
import 'package:wealth_app/shared/models/banner.dart' as app_banner;
import 'package:wealth_app/shared/widgets/shimmer_loading.dart';


class BannerCarousel extends ConsumerStatefulWidget {
  const BannerCarousel({super.key});

  @override
  ConsumerState<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  int _bannerCount = 0;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll(int bannerCount) {
    _bannerCount = bannerCount;
    _autoScrollTimer?.cancel();
    
    if (bannerCount <= 1) return; // Don't auto-scroll if only 1 or no banners
    
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients && mounted) {
        final nextPage = (_currentPage + 1) % _bannerCount;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the real-time stream for banners if available
    final bannersAsync = ref.watch(bannerStreamProvider);

    return bannersAsync.when(
      data: (banners) {
        if (banners.isEmpty) {
          return const SizedBox.shrink(); // Hide if no banners
        }
        
        // Start auto-scroll when banners are loaded
        if (_bannerCount != banners.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startAutoScroll(banners.length);
          });
        }
        
        return _buildBannerCarousel(context, banners);
      },
      loading: () => _buildLoadingState(context),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load banners'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.refresh(activeBannersProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel(BuildContext context, List<app_banner.Banner> banners) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner carousel with responsive height
        SizedBox(
          height: context.responsive<double>(mobile: 180.0, tablet: 220.0, desktop: 280.0),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: banners.length,
            itemBuilder: (context, index) {
              return BannerCard(banner: banners[index]);
            },
          ),
        ),
        
        // Page indicators (only show if more than 1 banner)
        if (banners.length > 1) ...[
          SizedBox(height: context.responsive<double>(mobile: 12.0, tablet: 16.0, desktop: 20.0)),
          _buildPageIndicators(context, banners.length),
        ],
      ],
    );
  }

  Widget _buildPageIndicators(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentPage;
        return GestureDetector(
          onTap: () {
            HapticFeedbackUtils.lightImpact();
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer for section title
          ShimmerLoading(
            child: Container(
              width: 100,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Shimmer for banner
          ShimmerLoading(
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BannerCard extends StatelessWidget {
  final app_banner.Banner banner;

  const BannerCard({
    super.key,
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleBannerTap(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: _getFullImageUrl(banner.imagePath),
            fit: BoxFit.cover,
            placeholder: (context, url) => ShimmerLoading(
              child: Container(color: Colors.grey.shade200),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleBannerTap(BuildContext context) {
    HapticFeedbackUtils.lightImpact();
    
    // Use the navigation helper to handle banner clicks
    BannerNavigationHelper.navigateFromBanner(context, banner);
  }

  /// Get the image URL - if it's already a full URL, return as is
  String _getFullImageUrl(String imagePath) {
    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    
    // Otherwise, construct the full URL
    return '${AppConfig.supabaseUrl}/storage/v1/object/public/banner-images/$imagePath';
  }
}