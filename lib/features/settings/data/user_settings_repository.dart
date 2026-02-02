import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/auth_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';

part 'user_settings_repository.g.dart';

@riverpod
UserSettingsRepository userSettingsRepository(UserSettingsRepositoryRef ref) {
  return UserSettingsRepository();
}

class UserSettings {
  final String id;
  final String userId;
  final String themeMode;
  final String primaryColor;
  final String fontSize;
  final String? defaultDeliveryAddressId;
  final String preferredPaymentMethod;
  final bool autoApplyCoupons;
  final bool savePaymentMethods;
  final bool showOnlineStatus;
  final bool allowLocationTracking;
  final bool sharePurchaseHistory;
  final bool autoLogin;
  final bool biometricLogin;
  final int sessionTimeoutMinutes;
  final bool showPriceAlerts;
  final bool showStockAlerts;
  final bool showDealNotifications;
  final bool autoAddToWishlist;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSettings({
    required this.id,
    required this.userId,
    this.themeMode = 'system',
    this.primaryColor = '#2196F3',
    this.fontSize = 'medium',
    this.defaultDeliveryAddressId,
    this.preferredPaymentMethod = 'credit_card',
    this.autoApplyCoupons = true,
    this.savePaymentMethods = false,
    this.showOnlineStatus = true,
    this.allowLocationTracking = false,
    this.sharePurchaseHistory = false,
    this.autoLogin = true,
    this.biometricLogin = false,
    this.sessionTimeoutMinutes = 30,
    this.showPriceAlerts = true,
    this.showStockAlerts = true,
    this.showDealNotifications = true,
    this.autoAddToWishlist = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      themeMode: json['theme_mode'] as String? ?? 'system',
      primaryColor: json['primary_color'] as String? ?? '#2196F3',
      fontSize: json['font_size'] as String? ?? 'medium',
      defaultDeliveryAddressId: json['default_delivery_address_id'] as String?,
      preferredPaymentMethod: json['preferred_payment_method'] as String? ?? 'credit_card',
      autoApplyCoupons: json['auto_apply_coupons'] as bool? ?? true,
      savePaymentMethods: json['save_payment_methods'] as bool? ?? false,
      showOnlineStatus: json['show_online_status'] as bool? ?? true,
      allowLocationTracking: json['allow_location_tracking'] as bool? ?? false,
      sharePurchaseHistory: json['share_purchase_history'] as bool? ?? false,
      autoLogin: json['auto_login'] as bool? ?? true,
      biometricLogin: json['biometric_login'] as bool? ?? false,
      sessionTimeoutMinutes: json['session_timeout_minutes'] as int? ?? 30,
      showPriceAlerts: json['show_price_alerts'] as bool? ?? true,
      showStockAlerts: json['show_stock_alerts'] as bool? ?? true,
      showDealNotifications: json['show_deal_notifications'] as bool? ?? true,
      autoAddToWishlist: json['auto_add_to_wishlist'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'theme_mode': themeMode,
      'primary_color': primaryColor,
      'font_size': fontSize,
      'default_delivery_address_id': defaultDeliveryAddressId,
      'preferred_payment_method': preferredPaymentMethod,
      'auto_apply_coupons': autoApplyCoupons,
      'save_payment_methods': savePaymentMethods,
      'show_online_status': showOnlineStatus,
      'allow_location_tracking': allowLocationTracking,
      'share_purchase_history': sharePurchaseHistory,
      'auto_login': autoLogin,
      'biometric_login': biometricLogin,
      'session_timeout_minutes': sessionTimeoutMinutes,
      'show_price_alerts': showPriceAlerts,
      'show_stock_alerts': showStockAlerts,
      'show_deal_notifications': showDealNotifications,
      'auto_add_to_wishlist': autoAddToWishlist,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserSettings copyWith({
    String? id,
    String? userId,
    String? themeMode,
    String? primaryColor,
    String? fontSize,
    String? defaultDeliveryAddressId,
    String? preferredPaymentMethod,
    bool? autoApplyCoupons,
    bool? savePaymentMethods,
    bool? showOnlineStatus,
    bool? allowLocationTracking,
    bool? sharePurchaseHistory,
    bool? autoLogin,
    bool? biometricLogin,
    int? sessionTimeoutMinutes,
    bool? showPriceAlerts,
    bool? showStockAlerts,
    bool? showDealNotifications,
    bool? autoAddToWishlist,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      fontSize: fontSize ?? this.fontSize,
      defaultDeliveryAddressId: defaultDeliveryAddressId ?? this.defaultDeliveryAddressId,
      preferredPaymentMethod: preferredPaymentMethod ?? this.preferredPaymentMethod,
      autoApplyCoupons: autoApplyCoupons ?? this.autoApplyCoupons,
      savePaymentMethods: savePaymentMethods ?? this.savePaymentMethods,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      allowLocationTracking: allowLocationTracking ?? this.allowLocationTracking,
      sharePurchaseHistory: sharePurchaseHistory ?? this.sharePurchaseHistory,
      autoLogin: autoLogin ?? this.autoLogin,
      biometricLogin: biometricLogin ?? this.biometricLogin,
      sessionTimeoutMinutes: sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      showPriceAlerts: showPriceAlerts ?? this.showPriceAlerts,
      showStockAlerts: showStockAlerts ?? this.showStockAlerts,
      showDealNotifications: showDealNotifications ?? this.showDealNotifications,
      autoAddToWishlist: autoAddToWishlist ?? this.autoAddToWishlist,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserSettingsRepository {
  final SupabaseClient _supabase = AuthService.client;

  String? get _currentUserId => AuthService.currentUser?.id;

  // Get current user settings
  Future<UserSettings?> getUserSettings() async {
    try {
      if (_currentUserId == null) return null;

      final response = await _supabase
          .from('user_settings')
          .select('*')
          .eq('user_id', _currentUserId!)
          .maybeSingle();

      if (response == null) return null;

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DataException('Failed to load user settings: $e');
    }
  }

  // Create or update user settings
  Future<UserSettings> upsertUserSettings(UserSettings settings) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      final settingsData = settings.toJson();
      settingsData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('user_settings')
          .upsert(settingsData)
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DataException('Failed to save user settings: $e');
    }
  }

  // Update theme settings
  Future<UserSettings> updateThemeSettings({
    String? themeMode,
    String? primaryColor,
    String? fontSize,
  }) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (themeMode != null) updateData['theme_mode'] = themeMode;
      if (primaryColor != null) updateData['primary_color'] = primaryColor;
      if (fontSize != null) updateData['font_size'] = fontSize;

      final response = await _supabase
          .from('user_settings')
          .update(updateData)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update theme settings: $e');
    }
  }

  // Update shopping preferences
  Future<UserSettings> updateShoppingPreferences({
    String? defaultDeliveryAddressId,
    String? preferredPaymentMethod,
    bool? autoApplyCoupons,
    bool? savePaymentMethods,
    bool? autoAddToWishlist,
  }) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (defaultDeliveryAddressId != null) updateData['default_delivery_address_id'] = defaultDeliveryAddressId;
      if (preferredPaymentMethod != null) updateData['preferred_payment_method'] = preferredPaymentMethod;
      if (autoApplyCoupons != null) updateData['auto_apply_coupons'] = autoApplyCoupons;
      if (savePaymentMethods != null) updateData['save_payment_methods'] = savePaymentMethods;
      if (autoAddToWishlist != null) updateData['auto_add_to_wishlist'] = autoAddToWishlist;

      final response = await _supabase
          .from('user_settings')
          .update(updateData)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update shopping preferences: $e');
    }
  }

  // Update privacy settings
  Future<UserSettings> updatePrivacySettings({
    bool? showOnlineStatus,
    bool? allowLocationTracking,
    bool? sharePurchaseHistory,
  }) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (showOnlineStatus != null) updateData['show_online_status'] = showOnlineStatus;
      if (allowLocationTracking != null) updateData['allow_location_tracking'] = allowLocationTracking;
      if (sharePurchaseHistory != null) updateData['share_purchase_history'] = sharePurchaseHistory;

      final response = await _supabase
          .from('user_settings')
          .update(updateData)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update privacy settings: $e');
    }
  }

  // Update notification settings
  Future<UserSettings> updateNotificationSettings({
    bool? showPriceAlerts,
    bool? showStockAlerts,
    bool? showDealNotifications,
  }) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (showPriceAlerts != null) updateData['show_price_alerts'] = showPriceAlerts;
      if (showStockAlerts != null) updateData['show_stock_alerts'] = showStockAlerts;
      if (showDealNotifications != null) updateData['show_deal_notifications'] = showDealNotifications;

      final response = await _supabase
          .from('user_settings')
          .update(updateData)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update notification settings: $e');
    }
  }

  // Update security settings
  Future<UserSettings> updateSecuritySettings({
    bool? autoLogin,
    bool? biometricLogin,
    int? sessionTimeoutMinutes,
  }) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (autoLogin != null) updateData['auto_login'] = autoLogin;
      if (biometricLogin != null) updateData['biometric_login'] = biometricLogin;
      if (sessionTimeoutMinutes != null) updateData['session_timeout_minutes'] = sessionTimeoutMinutes;

      final response = await _supabase
          .from('user_settings')
          .update(updateData)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update security settings: $e');
    }
  }

  // Create default settings for new users
  Future<UserSettings> createDefaultSettings() async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      final settingsData = {
        'user_id': _currentUserId!,
        'theme_mode': 'system',
        'primary_color': '#2196F3',
        'font_size': 'medium',
        'preferred_payment_method': 'credit_card',
        'auto_apply_coupons': true,
        'save_payment_methods': false,
        'show_online_status': true,
        'allow_location_tracking': false,
        'share_purchase_history': false,
        'auto_login': true,
        'biometric_login': false,
        'session_timeout_minutes': 30,
        'show_price_alerts': true,
        'show_stock_alerts': true,
        'show_deal_notifications': true,
        'auto_add_to_wishlist': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('user_settings')
          .insert(settingsData)
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DataException('Failed to create default settings: $e');
    }
  }

  // Delete user settings
  Future<void> deleteSettings() async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      await _supabase
          .from('user_settings')
          .delete()
          .eq('user_id', _currentUserId!);
    } catch (e) {
      throw DataException('Failed to delete settings: $e');
    }
  }
}