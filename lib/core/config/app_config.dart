import 'package:wealth_app/core/config/env_config.dart';

class AppConfig {
  // App Information
  static const String appName = 'Wealth Store';
  static const String appVersion = '1.0.0';
  
  // Supabase Configuration - Now loaded from .env file via EnvConfig
  static String get supabaseUrl => EnvConfig.supabaseUrl;
  static String get supabaseAnonKey => EnvConfig.supabaseAnonKey;
  
  // Environment Configuration
  static const bool isDevelopment = bool.fromEnvironment(
    'IS_DEVELOPMENT',
    defaultValue: true,
  );
  
  // Table Names
  static const String usersTable = 'users';
  static const String productsTable = 'products';
  static const String categoriesTable = 'categories';
  static const String ordersTable = 'orders';
  static const String bannersTable = 'banners';
  static const String couponsTable = 'coupons';
  
  // Storage Buckets
  static const String productImagesBucket = 'product-images';
  static const String bannerImagesBucket = 'banner-images';
  static const String booksBucket = 'books';
  static const String clothingsBucket = 'clothings';
  static const String phonesBucket = 'phones';
  static const String categoryIconsBucket = 'category-icons';
  static const String customerAvatarsBucket = 'customer-avatars';
  static const String adminAvatarsBucket = 'admin-avatars';
  static const String projectImagesBucket = 'project-images';
  static const String brandLogosBucket = 'brand-logos';
  static const String userAvatarsBucket = 'user-avatars';
  static const String mediaBucket = 'media';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // User Roles
  static const String adminRole = 'admin';
  static const String managerRole = 'manager';
  static const String customerRole = 'customer';
} 