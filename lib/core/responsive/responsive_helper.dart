import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Enhanced responsive helper with comprehensive screen size support
class ResponsiveHelper {
  // Target screen sizes for testing
  static const Size webDesktop = Size(1920, 1080);
  static const Size mobile = Size(402, 874);
  static const Size desktop = Size(1440, 1024);
  static const Size tablet = Size(1024, 1366);

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  /// Check if current screen is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1440;
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop(context) && largeDesktop != null) {
      return largeDesktop;
    } else if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getResponsiveValue(
        context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
        largeDesktop: 48.0,
      ),
      vertical: getResponsiveValue(
        context,
        mobile: 8.0,
        tablet: 12.0,
        desktop: 16.0,
        largeDesktop: 20.0,
      ),
    );
  }

  /// Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getResponsiveValue(
        context,
        mobile: 8.0,
        tablet: 16.0,
        desktop: 24.0,
        largeDesktop: 32.0,
      ),
      vertical: getResponsiveValue(
        context,
        mobile: 4.0,
        tablet: 8.0,
        desktop: 12.0,
        largeDesktop: 16.0,
      ),
    );
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    return getResponsiveValue(
      context,
      mobile: baseFontSize,
      tablet: baseFontSize * 1.1,
      desktop: baseFontSize * 1.2,
      largeDesktop: baseFontSize * 1.3,
    );
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(
    BuildContext context,
    double baseIconSize,
  ) {
    return getResponsiveValue(
      context,
      mobile: baseIconSize,
      tablet: baseIconSize * 1.2,
      desktop: baseIconSize * 1.4,
      largeDesktop: baseIconSize * 1.6,
    );
  }

  /// Get responsive grid columns
  static int getResponsiveGridColumns(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
      largeDesktop: 5,
    );
  }

  /// Get responsive card width
  static double getResponsiveCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return getResponsiveValue(
      context,
      mobile: (screenWidth - 48) / 2, // 2 columns with padding
      tablet: (screenWidth - 72) / 3, // 3 columns with padding
      desktop: (screenWidth - 96) / 4, // 4 columns with padding
      largeDesktop: (screenWidth - 120) / 5, // 5 columns with padding
    );
  }

  /// Get responsive max width for content
  static double getResponsiveMaxWidth(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: double.infinity,
      tablet: 800.0,
      desktop: 1200.0,
      largeDesktop: 1400.0,
    );
  }

  /// Get responsive aspect ratio
  static double getResponsiveAspectRatio(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 0.8, // Taller cards on mobile
      tablet: 0.9,
      desktop: 1.0, // Square on desktop
      largeDesktop: 1.1, // Slightly wider on large screens
    );
  }

  /// Check if screen is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if screen is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).viewPadding;
  }

  /// Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return getKeyboardHeight(context) > 0;
  }

  /// Get responsive touch target size
  static double getResponsiveTouchTarget(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 44.0, // iOS minimum
      tablet: 48.0, // Material Design minimum
      desktop: 56.0, // Larger for desktop
      largeDesktop: 64.0,
    );
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
      largeDesktop: 20.0,
    );
  }

  /// Get responsive elevation
  static double getResponsiveElevation(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 2.0,
      tablet: 4.0,
      desktop: 6.0,
      largeDesktop: 8.0,
    );
  }
}

/// Extension for easier access to responsive values
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get isLargeDesktop => ResponsiveHelper.isLargeDesktop(this);
  bool get isLandscape => ResponsiveHelper.isLandscape(this);
  bool get isPortrait => ResponsiveHelper.isPortrait(this);
  bool get isKeyboardVisible => ResponsiveHelper.isKeyboardVisible(this);

  EdgeInsets get responsivePadding => ResponsiveHelper.getResponsivePadding(this);
  EdgeInsets get responsiveMargin => ResponsiveHelper.getResponsiveMargin(this);
  EdgeInsets get safeAreaPadding => ResponsiveHelper.getSafeAreaPadding(this);
  double get keyboardHeight => ResponsiveHelper.getKeyboardHeight(this);
  double get responsiveTouchTarget => ResponsiveHelper.getResponsiveTouchTarget(this);
  double get responsiveBorderRadius => ResponsiveHelper.getResponsiveBorderRadius(this);
  double get responsiveElevation => ResponsiveHelper.getResponsiveElevation(this);
  int get responsiveGridColumns => ResponsiveHelper.getResponsiveGridColumns(this);
  double get responsiveMaxWidth => ResponsiveHelper.getResponsiveMaxWidth(this);
  double get responsiveAspectRatio => ResponsiveHelper.getResponsiveAspectRatio(this);

  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) =>
      ResponsiveHelper.getResponsiveValue(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
        largeDesktop: largeDesktop,
      );

  double responsiveFontSize(double baseFontSize) =>
      ResponsiveHelper.getResponsiveFontSize(this, baseFontSize);

  double responsiveIconSize(double baseIconSize) =>
      ResponsiveHelper.getResponsiveIconSize(this, baseIconSize);
}