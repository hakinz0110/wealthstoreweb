import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wealth_app/shared/models/banner.dart' as app_banner;

/// Helper class for handling banner navigation
class BannerNavigationHelper {
  /// Navigate based on banner - for now just show banner info
  static void navigateFromBanner(BuildContext context, app_banner.Banner banner) {
    // For now, just show the banner title since we don't have linkUrl in the database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Banner: ${banner.title}')),
    );
  }
}