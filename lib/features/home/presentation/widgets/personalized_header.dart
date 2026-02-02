import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/responsive/responsive_helper.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';
import 'package:wealth_app/features/auth/domain/auth_notifier.dart';
import 'package:wealth_app/core/theme/app_theme_provider.dart';

class PersonalizedHeader extends ConsumerWidget {
  const PersonalizedHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Get user name, fallback to "User" if not available
    final userName = authState.customer?.fullName ?? 
                    authState.user?.email?.split('@').first ?? 
                    'User';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
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
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsive<double>(
              mobile: AppSpacing.md,
              tablet: AppSpacing.lg,
              desktop: AppSpacing.xl,
            ),
            vertical: context.responsive<double>(
              mobile: AppSpacing.lg,
              tablet: AppSpacing.xl,
              desktop: AppSpacing.xl * 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Greeting and Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good day for shopping',
                      style: TypographyUtils.getBodyStyle(
                        context,
                        size: context.responsive<BodySize>(
                          mobile: BodySize.small,
                          tablet: BodySize.medium,
                          desktop: BodySize.large,
                        ),
                      ).copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: context.responsive<double>(
                      mobile: 4.0,
                      tablet: 6.0,
                      desktop: 8.0,
                    )),
                    Text(
                      userName,
                      style: TypographyUtils.getHeadingStyle(
                        context,
                        context.responsive<HeadingLevel>(
                          mobile: HeadingLevel.h3,
                          tablet: HeadingLevel.h2,
                          desktop: HeadingLevel.h1,
                        ),
                        isEmphasis: true,
                      ).copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Action icons
              Row(
                children: [
                  _buildThemeToggle(context, ref),
                  SizedBox(width: context.responsive<double>(
                    mobile: 8.0,
                    tablet: 12.0,
                    desktop: 16.0,
                  )),
                  _buildIconButton(
                    context,
                    icon: Icons.notifications_outlined,
                    onTap: () {
                      HapticFeedbackUtils.lightImpact();
                      context.push('/notifications');
                    },
                  ),
                  SizedBox(width: context.responsive<double>(
                    mobile: 8.0,
                    tablet: 12.0,
                    desktop: 16.0,
                  )),
                  _buildIconButton(
                    context,
                    icon: Icons.favorite_outline,
                    onTap: () {
                      HapticFeedbackUtils.lightImpact();
                      context.push('/wishlist');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(appThemeProvider);
    final isDarkMode = currentTheme == ThemeMode.dark;
    
    return InkWell(
      onTap: () {
        HapticFeedbackUtils.lightImpact();
        // Toggle between light and dark mode
        ref.read(appThemeProvider.notifier).setThemeMode(
          isDarkMode ? ThemeMode.light : ThemeMode.dark,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: context.responsive<double>(
          mobile: 40.0,
          tablet: 44.0,
          desktop: 48.0,
        ),
        height: context.responsive<double>(
          mobile: 40.0,
          tablet: 44.0,
          desktop: 48.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          color: Colors.white,
          size: context.responsive<double>(
            mobile: 22.0,
            tablet: 24.0,
            desktop: 26.0,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: context.responsive<double>(
          mobile: 40.0,
          tablet: 44.0,
          desktop: 48.0,
        ),
        height: context.responsive<double>(
          mobile: 40.0,
          tablet: 44.0,
          desktop: 48.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: context.responsive<double>(
            mobile: 22.0,
            tablet: 24.0,
            desktop: 26.0,
          ),
        ),
      ),
    );
  }
}
