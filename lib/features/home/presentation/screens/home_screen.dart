import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/responsive/responsive_helper.dart';
import 'package:wealth_app/core/responsive/responsive_widgets.dart';
import 'package:wealth_app/features/home/domain/popular_products_notifier.dart';
import 'package:wealth_app/features/home/domain/home_category_service.dart';
import 'package:wealth_app/features/home/providers/banner_providers.dart';
import 'package:wealth_app/features/home/presentation/widgets/personalized_header.dart';
import 'package:wealth_app/features/home/presentation/widgets/prominent_search_bar.dart';
import 'package:wealth_app/features/home/presentation/widgets/modern_section_container.dart';
import 'package:wealth_app/features/home/presentation/widgets/category_slider.dart';
import 'package:wealth_app/features/home/presentation/widgets/banner_carousel.dart';
import 'package:wealth_app/features/home/presentation/widgets/popular_products_section.dart';
import 'package:wealth_app/features/home/presentation/widgets/coupons_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load fresh data when page opens
    Future.microtask(() => _refreshAllData());
  }

  Future<void> _refreshAllData() async {
    // Refresh all data sources
    await Future.wait([
      ref.read(popularProductsNotifierProvider.notifier).refresh(),
      Future.microtask(() => ref.refresh(activeBannersProvider)),
      Future.microtask(() => ref.refresh(bannerStreamProvider)),
      Future.microtask(() => ref.refresh(popularCategoriesProvider)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayoutBuilder(
        mobile: (context, constraints) => _buildMobileLayout(context),
        tablet: (context, constraints) => _buildTabletLayout(context),
        desktop: (context, constraints) => _buildDesktopLayout(context),
        fallback: (context, constraints) => _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshAllData,
      child: SingleChildScrollView(
        child: Column(
        children: [
          // Upper section with gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      const Color(0xFF6366F1),
                      const Color(0xFF8B5CF6),
                    ],
              ),
            ),
            child: Column(
              children: [
                // Header
                const PersonalizedHeader(),
                
                SizedBox(height: context.responsive<double>(mobile: 16.0, tablet: 20.0, desktop: 24.0)),
                
                // Search bar
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: ProminentSearchBar(),
                ),
                
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
                
                // Categories Section
                const CategorySlider(),
                
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
              ],
            ),
          ),
          
          // Lower section with white/dark background
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
                
                // Banner carousel
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: BannerCarousel(),
                ),
                
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
                
                // Coupons section
                ModernSectionContainer(
                  child: const CouponsSection(),
                ),
                
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
                
                // Popular products section (vertical grid)
                const PopularProductsSection(),
                
                // Bottom padding for better scrolling experience
                SizedBox(height: context.responsive<double>(mobile: 80.0, tablet: 90.0, desktop: 100.0)),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshAllData,
      child: SingleChildScrollView(
        child: Column(
        children: [
          // Upper section with gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      const Color(0xFF6366F1),
                      const Color(0xFF8B5CF6),
                    ],
              ),
            ),
            child: Column(
              children: [
                // Header
                const PersonalizedHeader(),
                
                SizedBox(height: context.responsive<double>(mobile: 16.0, tablet: 20.0, desktop: 24.0)),
                
                // Search bar
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: ProminentSearchBar(),
                ),
                
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
                
                // Categories Section
                const CategorySlider(),
                
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
              ],
            ),
          ),
          
          // Lower section with white/dark background
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
                
                // Banner carousel
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: BannerCarousel(),
                ),
                
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
                
                // Coupons section
                ModernSectionContainer(
                  child: const CouponsSection(),
                ),
                
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
                
                // Popular products section
                const PopularProductsSection(),
                
                SizedBox(height: context.responsive<double>(mobile: 80.0, tablet: 90.0, desktop: 100.0)),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshAllData,
      child: SingleChildScrollView(
        child: Column(
        children: [
          // Upper section with gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      const Color(0xFF6366F1),
                      const Color(0xFF8B5CF6),
                    ],
              ),
            ),
            child: Column(
              children: [
                // Header
                const PersonalizedHeader(),
                
                SizedBox(height: context.responsive<double>(mobile: 16.0, tablet: 20.0, desktop: 24.0)),
                
                // Search bar
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: ProminentSearchBar(),
                ),
                
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
                
                // Categories Section
                const CategorySlider(),
                
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
              ],
            ),
          ),
          
          // Lower section with white/dark background
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
                
                // Banner carousel
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: BannerCarousel(),
                ),
                
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
                
                // Coupons section
                ModernSectionContainer(
                  child: const CouponsSection(),
                ),
                
                SizedBox(height: context.responsive<double>(mobile: 20.0, tablet: 24.0, desktop: 28.0)),
                
                // Popular products section
                const PopularProductsSection(),
                
                SizedBox(height: context.responsive<double>(mobile: 80.0, tablet: 90.0, desktop: 100.0)),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}