import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wealth_app/core/config/app_config.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_assets.dart';
import 'package:wealth_app/core/responsive/responsive_helper.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/shared/widgets/shimmer_loading.dart';

class HeaderNavigation extends StatelessWidget {
  const HeaderNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
                ]
              : [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                ],
        ),
        borderRadius: BorderRadius.circular(
          context.responsive<double>(
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive<double>(
          mobile: AppSpacing.md,
          tablet: AppSpacing.lg,
          desktop: AppSpacing.xl,
        ),
        vertical: context.responsive<double>(
          mobile: AppSpacing.sm,
          tablet: AppSpacing.md,
          desktop: AppSpacing.lg,
        ),
      ),
      child: Row(
        children: [
          // App Logo
          _buildAppLogo(context),
          
          SizedBox(width: context.responsive<double>(
            mobile: 12.0,
            tablet: 16.0,
            desktop: 20.0,
          )),
          
          // App Name
          _buildAppName(context),
          
          // Spacer to push any future navigation items to the right
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildAppLogo(BuildContext context) {
    final logoSize = context.responsive<double>(
      mobile: 40.0,
      tablet: 48.0,
      desktop: 56.0,
    );
    
    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: _getLogoUrl(),
          fit: BoxFit.cover,
          placeholder: (context, url) => ShimmerLoading(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.store,
              size: logoSize * 0.6,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppName(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'WEALTH STORE',
          style: TypographyUtils.getHeadingStyle(
            context,
            context.responsive<HeadingLevel>(
              mobile: HeadingLevel.h4,
              tablet: HeadingLevel.h3,
              desktop: HeadingLevel.h2,
            ),
            isEmphasis: true,
          ).copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: context.responsive<double>(
              mobile: 1.2,
              tablet: 1.5,
              desktop: 2.0,
            ),
          ),
        ),
        
        // Optional tagline for larger screens
        if (context.responsive<bool>(
          mobile: false,
          tablet: true,
          desktop: true,
        )) ...[
          SizedBox(height: context.responsive<double>(
            mobile: 2.0,
            tablet: 3.0,
            desktop: 4.0,
          )),
          Text(
            'Your Premium Shopping Destination',
            style: TypographyUtils.getBodyStyle(
              context,
              size: BodySize.small,
              isSecondary: true,
            ).copyWith(
              fontStyle: FontStyle.italic,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }

  String _getLogoUrl() {
    return AppAssets.logoUrl;
  }
}

/// Compact version of header navigation for smaller spaces
class CompactHeaderNavigation extends StatelessWidget {
  const CompactHeaderNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive<double>(
          mobile: AppSpacing.sm,
          tablet: AppSpacing.md,
          desktop: AppSpacing.lg,
        ),
        vertical: context.responsive<double>(
          mobile: AppSpacing.xs,
          tablet: AppSpacing.sm,
          desktop: AppSpacing.md,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact App Logo
          _buildCompactLogo(context),
          
          SizedBox(width: context.responsive<double>(
            mobile: 8.0,
            tablet: 10.0,
            desktop: 12.0,
          )),
          
          // Compact App Name
          Text(
            'WEALTH STORE',
            style: TypographyUtils.getHeadingStyle(
              context,
              HeadingLevel.h5,
              isEmphasis: true,
            ).copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLogo(BuildContext context) {
    final logoSize = context.responsive<double>(
      mobile: 32.0,
      tablet: 36.0,
      desktop: 40.0,
    );
    
    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: _getLogoUrl(),
          fit: BoxFit.cover,
          placeholder: (context, url) => ShimmerLoading(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.store,
              size: logoSize * 0.6,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  String _getLogoUrl() {
    return AppAssets.logoUrl;
  }
}