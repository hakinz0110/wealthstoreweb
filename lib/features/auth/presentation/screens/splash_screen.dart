import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_assets.dart';
import 'package:wealth_app/core/constants/app_design_tokens.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/features/auth/domain/auth_notifier.dart';
import 'package:wealth_app/core/utils/secure_storage.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  bool _showGetStartedButton = false;
  
  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  void _initializeScreen() async {
    // Wait for animations and auth check
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Check if user is already authenticated (e.g., after OAuth redirect)
    if (mounted) {
      final authState = ref.read(authNotifierProvider);
      if (authState.isAuthenticated) {
        // User is authenticated, go directly to home
        context.go('/home');
        return;
      }
    }
    
    // Show the Get Started button after animations complete
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _showGetStartedButton = true;
      });
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;
    
    try {
      // Check authentication state
      final authState = ref.read(authNotifierProvider);
      
      if (authState.isAuthenticated) {
        // User is already authenticated, navigate to home
        context.go('/home');
      } else {
        // Check if there's a stored token
        final token = await SecureStorage.getToken();
        final userId = await SecureStorage.getUserId();
        
        if (token != null && userId != null) {
          // We have stored credentials, go to home
          context.go('/home');
        } else {
          // No stored credentials, check if first launch
          final hasSeenOnboarding = await SecureStorage.getHasSeenOnboarding();
          if (hasSeenOnboarding == 'true') {
            // Returning user, go to auth
            context.go('/auth');
          } else {
            // First time user, go to onboarding
            context.go('/onboarding');
          }
        }
      }
    } catch (e) {
      debugPrint('Error during navigation: $e');
      // Default to onboarding on error
      if (mounted) {
        context.go('/onboarding');
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceLight,
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 3000.ms,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hero logo
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppDesignTokens.radiusXl,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 35,
                                offset: const Offset(0, 18),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: AppAssets.logoUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 3,
                                  ),
                                ),
                                errorWidget: (context, url, error) {
                                  debugPrint('Error loading logo: $error');
                                  return const Icon(
                                    Icons.shopping_bag_rounded,
                                    size: 70,
                                    color: AppColors.primary,
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.3, 0.3),
                              end: const Offset(1, 1),
                              duration: 400.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(
                              duration: AppDesignTokens.animationMedium,
                              curve: AppDesignTokens.easeOut,
                            )
                            .then(delay: 300.ms)
                            .shimmer(
                              duration: 1500.ms,
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                        
                        const SizedBox(height: 32),
                        
                        // App name
                        Text(
                          'Wealth Store',
                          style: AppTextStyles.displaySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                            .animate(delay: 200.ms)
                            .fadeIn(
                              duration: AppDesignTokens.animationMedium,
                              curve: AppDesignTokens.easeOut,
                            )
                            .slideY(
                              begin: 0.3,
                              end: 0,
                              duration: AppDesignTokens.animationMedium,
                              curve: AppDesignTokens.easeOut,
                            ),
                        
                        const SizedBox(height: 12),
                        
                        // Tagline
                        Text(
                          'Shop smart, live better',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.onSurfaceLight.withValues(alpha: 0.7),
                          ),
                        )
                            .animate(delay: 400.ms)
                            .fadeIn(
                              duration: AppDesignTokens.animationMedium,
                              curve: AppDesignTokens.easeOut,
                            ),
                      ],
                    ),
                  ),
                ),
                
                // Get Started button
                if (_showGetStartedButton)
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _navigateToNextScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDesignTokens.radiusLg,
                          ),
                        ),
                        child: Text(
                          'Get Started',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .slideY(
                        begin: 0.5,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(
                        duration: 400.ms,
                        curve: AppDesignTokens.easeOut,
                      ),
                
                // Loading indicator
                if (!_showGetStartedButton)
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  )
                      .animate(delay: 600.ms)
                      .fadeIn(
                        duration: AppDesignTokens.animationFast,
                        curve: AppDesignTokens.easeOut,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
