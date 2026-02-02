import 'package:flutter/material.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/responsive/responsive_helper.dart';

class ModernSectionContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool showBorder;
  final bool showShadow;
  final bool showGradient;

  const ModernSectionContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
    this.showBorder = true,
    this.showShadow = true,
    this.showGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin ?? EdgeInsets.symmetric(
        horizontal: context.responsive<double>(
          mobile: AppSpacing.md,
          tablet: AppSpacing.lg,
          desktop: AppSpacing.xl,
        ),
        vertical: context.responsive<double>(
          mobile: 2.0,
          tablet: 3.0,
          desktop: 4.0,
        ),
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? (showGradient ? null : _getBackgroundColor(context, isDark)),
        gradient: showGradient ? _getGradient(context, isDark) : null,
        borderRadius: BorderRadius.circular(
          borderRadius ?? context.responsive<double>(
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ),
        ),
        border: showBorder ? Border.all(
          color: borderColor ?? _getBorderColor(context, isDark),
          width: context.responsive<double>(
            mobile: 1.0,
            tablet: 1.2,
            desktop: 1.5,
          ),
        ) : null,
        boxShadow: showShadow ? (boxShadow ?? _getBoxShadow(context, isDark)) : null,
      ),
      child: Container(
        padding: padding ?? EdgeInsets.all(
          context.responsive<double>(
            mobile: AppSpacing.md,
            tablet: AppSpacing.lg,
            desktop: AppSpacing.xl,
          ),
        ),
        child: child,
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context, bool isDark) {
    if (isDark) {
      return Theme.of(context).colorScheme.surface.withValues(alpha: 0.8);
    } else {
      return Theme.of(context).colorScheme.surface.withValues(alpha: 0.95);
    }
  }

  Color _getBorderColor(BuildContext context, bool isDark) {
    if (isDark) {
      return Theme.of(context).colorScheme.outline.withOpacity(0.3);
    } else {
      return Theme.of(context).colorScheme.outline.withOpacity(0.2);
    }
  }

  LinearGradient _getGradient(BuildContext context, bool isDark) {
    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.surface,
          Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        ],
      );
    }
  }

  List<BoxShadow> _getBoxShadow(BuildContext context, bool isDark) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.04),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];
    }
  }
}

/// Specialized container for the top action bar
class TopActionBarContainer extends StatelessWidget {
  final Widget child;

  const TopActionBarContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.responsive<double>(
          mobile: AppSpacing.sm,
          tablet: AppSpacing.md,
          desktop: AppSpacing.lg,
        ),
        vertical: context.responsive<double>(
          mobile: 2.0,
          tablet: 3.0,
          desktop: 4.0,
        ),
      ),
      decoration: BoxDecoration(
        color: isDark 
            ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.9)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          context.responsive<double>(
            mobile: 20.0,
            tablet: 24.0,
            desktop: 28.0,
          ),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.2)
                : Theme.of(context).colorScheme.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsive<double>(
            mobile: AppSpacing.sm,
            tablet: AppSpacing.md,
            desktop: AppSpacing.lg,
          ),
          vertical: context.responsive<double>(
            mobile: AppSpacing.sm,
            tablet: AppSpacing.md,
            desktop: AppSpacing.lg,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Specialized container for the header section
class HeaderSectionContainer extends StatelessWidget {
  final Widget child;

  const HeaderSectionContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ModernSectionContainer(
      showGradient: true,
      borderRadius: context.responsive<double>(
        mobile: 20.0,
        tablet: 24.0,
        desktop: 28.0,
      ),
      child: child,
    );
  }
}