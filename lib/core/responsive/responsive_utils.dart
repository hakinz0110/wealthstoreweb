import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// Utility class for responsive design calculations and helpers
class ResponsiveUtils {
  /// Calculate responsive font size with min/max constraints
  static double calculateFontSize(
    BuildContext context,
    double baseFontSize, {
    double? minFontSize,
    double? maxFontSize,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375; // Base on iPhone X width
    
    double calculatedSize = baseFontSize * scaleFactor;
    
    if (minFontSize != null && calculatedSize < minFontSize) {
      calculatedSize = minFontSize;
    }
    
    if (maxFontSize != null && calculatedSize > maxFontSize) {
      calculatedSize = maxFontSize;
    }
    
    return calculatedSize;
  }

  /// Calculate responsive spacing
  static double calculateSpacing(
    BuildContext context,
    double baseSpacing,
  ) {
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: baseSpacing,
      tablet: baseSpacing * 1.2,
      desktop: baseSpacing * 1.4,
      largeDesktop: baseSpacing * 1.6,
    );
  }

  /// Get responsive breakpoint-aware column count
  static int getColumnCount(
    BuildContext context, {
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    int? largeDesktopColumns,
  }) {
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: mobileColumns ?? 1,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 3,
      largeDesktop: largeDesktopColumns ?? 4,
    );
  }

  /// Calculate item width for responsive grids
  static double calculateItemWidth(
    BuildContext context,
    int columns, {
    double spacing = 16.0,
    EdgeInsets padding = const EdgeInsets.all(16.0),
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - padding.horizontal;
    final totalSpacing = spacing * (columns - 1);
    return (availableWidth - totalSpacing) / columns;
  }

  /// Get responsive aspect ratio
  static double getAspectRatio(
    BuildContext context, {
    double? mobileRatio,
    double? tabletRatio,
    double? desktopRatio,
  }) {
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: mobileRatio ?? 1.0,
      tablet: tabletRatio ?? 1.2,
      desktop: desktopRatio ?? 1.4,
    );
  }

  /// Check if content should be scrollable based on available height
  static bool shouldScroll(
    BuildContext context,
    double contentHeight,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - 
        MediaQuery.of(context).viewPadding.vertical -
        kToolbarHeight;
    
    return contentHeight > availableHeight;
  }

  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (ResponsiveHelper.isMobile(context)) {
      return screenWidth * 0.9;
    } else if (ResponsiveHelper.isTablet(context)) {
      return screenWidth * 0.7;
    } else {
      return screenWidth * 0.5;
    }
  }

  /// Get responsive modal height
  static double getModalHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: screenHeight * 0.9,
      tablet: screenHeight * 0.8,
      desktop: screenHeight * 0.7,
    );
  }

  /// Calculate responsive card elevation
  static double getCardElevation(BuildContext context) {
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 2.0,
      tablet: 4.0,
      desktop: 6.0,
      largeDesktop: 8.0,
    );
  }

  /// Get responsive animation duration
  static Duration getAnimationDuration(BuildContext context) {
    // Faster animations on mobile for better performance
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: const Duration(milliseconds: 200),
      tablet: const Duration(milliseconds: 250),
      desktop: const Duration(milliseconds: 300),
    );
  }

  /// Calculate responsive image size
  static Size getImageSize(
    BuildContext context,
    double baseWidth,
    double baseHeight,
  ) {
    final scaleFactor = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 1.0,
      tablet: 1.2,
      desktop: 1.4,
      largeDesktop: 1.6,
    );

    return Size(
      baseWidth * scaleFactor,
      baseHeight * scaleFactor,
    );
  }

  /// Get responsive list tile height
  static double getListTileHeight(BuildContext context) {
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 56.0,
      tablet: 64.0,
      desktop: 72.0,
    );
  }

  /// Calculate responsive bottom sheet height
  static double getBottomSheetHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: screenHeight * 0.6,
      tablet: screenHeight * 0.5,
      desktop: screenHeight * 0.4,
    );
  }

  /// Get responsive snackbar width
  static double? getSnackBarWidth(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return 400.0; // Fixed width on desktop
    }
    return null; // Full width on mobile/tablet
  }

  /// Calculate responsive fab position
  static FloatingActionButtonLocation getFabLocation(BuildContext context) {
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: FloatingActionButtonLocation.endFloat,
      tablet: FloatingActionButtonLocation.endFloat,
      desktop: FloatingActionButtonLocation.endDocked,
    );
  }

  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: kToolbarHeight,
      tablet: kToolbarHeight + 8,
      desktop: kToolbarHeight + 16,
    );
  }

  /// Calculate responsive drawer width
  static double getDrawerWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: screenWidth * 0.8,
      tablet: 320.0,
      desktop: 280.0,
    );
  }

  /// Get responsive tab bar height
  static double getTabBarHeight(BuildContext context) {
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 48.0,
      tablet: 56.0,
      desktop: 64.0,
    );
  }

  /// Calculate responsive content max width
  static double getContentMaxWidth(BuildContext context) {
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: double.infinity,
      tablet: 800.0,
      desktop: 1200.0,
      largeDesktop: 1400.0,
    );
  }

  /// Get responsive scroll physics
  static ScrollPhysics getScrollPhysics(BuildContext context) {
    // Different scroll behavior for different platforms
    return ResponsiveHelper.getResponsiveValue(
      context,
      mobile: const BouncingScrollPhysics(),
      tablet: const ClampingScrollPhysics(),
      desktop: const ClampingScrollPhysics(),
    );
  }
}

/// Extension for easier access to responsive utilities
extension ResponsiveUtilsExtension on BuildContext {
  double calculateFontSize(double baseFontSize, {double? minFontSize, double? maxFontSize}) =>
      ResponsiveUtils.calculateFontSize(this, baseFontSize, minFontSize: minFontSize, maxFontSize: maxFontSize);

  double calculateSpacing(double baseSpacing) =>
      ResponsiveUtils.calculateSpacing(this, baseSpacing);

  int getColumnCount({int? mobileColumns, int? tabletColumns, int? desktopColumns, int? largeDesktopColumns}) =>
      ResponsiveUtils.getColumnCount(this, 
          mobileColumns: mobileColumns, 
          tabletColumns: tabletColumns, 
          desktopColumns: desktopColumns, 
          largeDesktopColumns: largeDesktopColumns);

  double calculateItemWidth(int columns, {double spacing = 16.0, EdgeInsets padding = const EdgeInsets.all(16.0)}) =>
      ResponsiveUtils.calculateItemWidth(this, columns, spacing: spacing, padding: padding);

  double getAspectRatio({double? mobileRatio, double? tabletRatio, double? desktopRatio}) =>
      ResponsiveUtils.getAspectRatio(this, mobileRatio: mobileRatio, tabletRatio: tabletRatio, desktopRatio: desktopRatio);

  bool shouldScroll(double contentHeight) =>
      ResponsiveUtils.shouldScroll(this, contentHeight);

  double get dialogWidth => ResponsiveUtils.getDialogWidth(this);
  double get modalHeight => ResponsiveUtils.getModalHeight(this);
  double get cardElevation => ResponsiveUtils.getCardElevation(this);
  Duration get animationDuration => ResponsiveUtils.getAnimationDuration(this);
  double get listTileHeight => ResponsiveUtils.getListTileHeight(this);
  double get bottomSheetHeight => ResponsiveUtils.getBottomSheetHeight(this);
  double? get snackBarWidth => ResponsiveUtils.getSnackBarWidth(this);
  FloatingActionButtonLocation get fabLocation => ResponsiveUtils.getFabLocation(this);
  double get appBarHeight => ResponsiveUtils.getAppBarHeight(this);
  double get drawerWidth => ResponsiveUtils.getDrawerWidth(this);
  double get tabBarHeight => ResponsiveUtils.getTabBarHeight(this);
  double get contentMaxWidth => ResponsiveUtils.getContentMaxWidth(this);
  ScrollPhysics get scrollPhysics => ResponsiveUtils.getScrollPhysics(this);

  Size getImageSize(double baseWidth, double baseHeight) =>
      ResponsiveUtils.getImageSize(this, baseWidth, baseHeight);
}