import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation helper class for easy navigation to enhanced screens
class NavigationHelper {
  
  /// Navigate to Enhanced Profile Screen (full screen)
  static void goToEnhancedProfile(BuildContext context) {
    context.push('/profile-enhanced');
  }
  
  /// Navigate to Enhanced Edit Profile Screen (full screen)
  static void goToEnhancedEditProfile(BuildContext context) {
    context.push('/profile-edit-enhanced');
  }
  
  /// Navigate to Enhanced Wishlist Screen (full screen)
  static void goToEnhancedWishlist(BuildContext context) {
    context.push('/wishlist');
  }
  
  /// Navigate to Profile tab with Enhanced Profile Screen
  static void goToProfileTab(BuildContext context) {
    context.go('/profile');
  }
  
  /// Navigate to Edit Profile from Profile tab
  static void goToEditProfileFromTab(BuildContext context) {
    context.push('/profile/edit-enhanced');
  }
  
  /// Navigate to Address Management
  static void goToAddresses(BuildContext context) {
    context.push('/profile/addresses');
  }
  
  /// Navigate to Add New Address
  static void goToAddAddress(BuildContext context) {
    context.push('/profile/addresses/add');
  }
  
  /// Navigate to Edit Address
  static void goToEditAddress(BuildContext context, int addressId) {
    context.push('/profile/addresses/edit/$addressId');
  }
  
  /// Navigate to Settings
  static void goToSettings(BuildContext context) {
    context.push('/profile/settings');
  }
  
  /// Navigate to Notification Preferences
  static void goToNotificationPreferences(BuildContext context) {
    context.push('/profile/notifications');
  }
  
  /// Navigate to Privacy Settings
  static void goToPrivacySettings(BuildContext context) {
    context.push('/profile/privacy');
  }
  
  /// Navigate to Price Alerts
  static void goToPriceAlerts(BuildContext context) {
    context.push('/profile/price-alerts');
  }
  
  /// Navigate to Orders from Profile
  static void goToOrdersFromProfile(BuildContext context) {
    context.push('/profile/orders');
  }
  
  /// Navigate to Orders (full screen)
  static void goToOrders(BuildContext context) {
    context.push('/orders');
  }
  
  /// Navigate to Order Details
  static void goToOrderDetails(BuildContext context, String orderId) {
    context.push('/orders/$orderId');
  }
  

  /// Navigate to Product Details
  static void goToProductDetails(BuildContext context, int productId) {
    context.push('/product/$productId');
  }
  
  /// Navigate to Category Products
  static void goToCategoryProducts(BuildContext context, int categoryId, String categoryName) {
    final encodedName = Uri.encodeComponent(categoryName);
    context.push('/category/$categoryId/$encodedName');
  }
  
  /// Navigate to Search
  static void goToSearch(BuildContext context) {
    context.push('/search');
  }
  
  /// Navigate to Notifications
  static void goToNotifications(BuildContext context) {
    context.push('/notifications');
  }
  
  /// Navigate to Checkout
  static void goToCheckout(BuildContext context) {
    context.push('/checkout');
  }
  
  /// Navigate to Home tab
  static void goToHome(BuildContext context) {
    context.go('/home');
  }
  
  /// Navigate to Products tab
  static void goToProducts(BuildContext context) {
    context.go('/products');
  }
  
  /// Navigate to Cart tab
  static void goToCart(BuildContext context) {
    context.push('/cart-view');
  }
  
  /// Navigate to Auth Screen
  static void goToAuth(BuildContext context) {
    context.go('/auth');
  }
  
  /// Navigate back
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }
  
  /// Replace current route (useful for auth flows)
  static void replaceWith(BuildContext context, String path) {
    context.pushReplacement(path);
  }
  
  /// Clear stack and go to path (useful for logout)
  static void clearAndGoTo(BuildContext context, String path) {
    context.go(path);
  }
}

/// Extension on BuildContext for easier navigation
extension NavigationExtension on BuildContext {
  
  /// Navigate to Enhanced Profile Screen
  void goToEnhancedProfile() => NavigationHelper.goToEnhancedProfile(this);
  
  /// Navigate to Enhanced Edit Profile Screen
  void goToEnhancedEditProfile() => NavigationHelper.goToEnhancedEditProfile(this);
  
  /// Navigate to Enhanced Wishlist Screen
  void goToEnhancedWishlist() => NavigationHelper.goToEnhancedWishlist(this);
  
  /// Navigate to Profile tab
  void goToProfileTab() => NavigationHelper.goToProfileTab(this);
  
  /// Navigate to Edit Profile from tab
  void goToEditProfileFromTab() => NavigationHelper.goToEditProfileFromTab(this);
  
  /// Navigate to Addresses
  void goToAddresses() => NavigationHelper.goToAddresses(this);
  
  /// Navigate to Add Address
  void goToAddAddress() => NavigationHelper.goToAddAddress(this);
  
  /// Navigate to Edit Address
  void goToEditAddress(int addressId) => NavigationHelper.goToEditAddress(this, addressId);
  
  /// Navigate to Settings
  void goToAppSettings() => NavigationHelper.goToSettings(this);
  

  /// Navigate to Product Details
  void goToProductDetails(int productId) => NavigationHelper.goToProductDetails(this, productId);
  
  /// Navigate to Category Products
  void goToCategoryProducts(int categoryId, String categoryName) => 
      NavigationHelper.goToCategoryProducts(this, categoryId, categoryName);
  
  /// Navigate back safely
  void goBackSafely() => NavigationHelper.goBack(this);
}