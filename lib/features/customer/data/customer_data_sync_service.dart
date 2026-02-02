import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/core/services/auth_service.dart';
import 'package:wealth_app/features/profile/data/user_profile_repository.dart';
import 'package:wealth_app/features/settings/data/user_settings_repository.dart';
import 'package:wealth_app/features/cart/domain/cart_sync_service.dart';

part 'customer_data_sync_service.g.dart';

@riverpod
CustomerDataSyncService customerDataSyncService(CustomerDataSyncServiceRef ref) {
  return CustomerDataSyncService(ref);
}

class CustomerDataSyncService {
  final CustomerDataSyncServiceRef _ref;

  CustomerDataSyncService(this._ref);

  /// Initialize customer data sync service
  /// This should be called when the app starts
  void initialize() {
    // Listen to auth state changes
    AuthService.authStateChanges.listen((authState) {
      if (authState.session != null) {
        // User logged in - initialize all customer data
        _initializeCustomerData();
      } else {
        // User logged out - cleanup if needed
        _handleUserLogout();
      }
    });
  }

  /// Initialize all customer data when user logs in
  Future<void> _initializeCustomerData() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      print('Initializing customer data for user: ${user.id}');

      // Initialize user profile
      await _initializeUserProfile(user.id, user.email, user.userMetadata?['full_name']);

      // Initialize user settings
      await _initializeUserSettings();

      // Sync cart data
      await _syncCartData();

      // Update last login
      await _updateLastLogin();

      print('Customer data initialization completed');
    } catch (e) {
      print('Failed to initialize customer data: $e');
    }
  }

  /// Initialize user profile
  Future<void> _initializeUserProfile(String userId, String? email, String? fullName) async {
    try {
      final profileRepo = _ref.read(userProfileRepositoryProvider);
      
      // Check if profile exists
      final existingProfile = await profileRepo.getCurrentUserProfile();
      
      if (existingProfile == null) {
        // Create initial profile for new user
        await profileRepo.createInitialProfile(
          userId: userId,
          email: email,
          fullName: fullName,
        );
        print('Created initial user profile');
      } else {
        print('User profile already exists');
      }
    } catch (e) {
      print('Failed to initialize user profile: $e');
    }
  }

  /// Initialize user settings
  Future<void> _initializeUserSettings() async {
    try {
      final settingsRepo = _ref.read(userSettingsRepositoryProvider);
      
      // Check if settings exist
      final existingSettings = await settingsRepo.getUserSettings();
      
      if (existingSettings == null) {
        // Create default settings for new user
        await settingsRepo.createDefaultSettings();
        print('Created default user settings');
      } else {
        print('User settings already exist');
      }
    } catch (e) {
      print('Failed to initialize user settings: $e');
    }
  }

  /// Sync cart data
  Future<void> _syncCartData() async {
    try {
      final cartSyncService = _ref.read(cartSyncServiceProvider);
      await cartSyncService.syncCart();
      print('Cart data synced successfully');
    } catch (e) {
      print('Failed to sync cart data: $e');
    }
  }

  /// Update last login timestamp
  Future<void> _updateLastLogin() async {
    try {
      final profileRepo = _ref.read(userProfileRepositoryProvider);
      await profileRepo.updateLastLogin();
      print('Last login updated');
    } catch (e) {
      print('Failed to update last login: $e');
    }
  }

  /// Handle user logout
  Future<void> _handleUserLogout() async {
    try {
      print('Handling user logout - cleaning up customer data');
      // Add any cleanup logic here if needed
      // For now, we don't need to do anything special
    } catch (e) {
      print('Failed to handle user logout: $e');
    }
  }

  /// Manually sync all customer data
  Future<void> syncAllCustomerData() async {
    try {
      if (!AuthService.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      await _initializeCustomerData();
    } catch (e) {
      print('Manual customer data sync failed: $e');
      rethrow;
    }
  }

  /// Get customer data summary
  Future<Map<String, dynamic>> getCustomerDataSummary() async {
    try {
      if (!AuthService.isAuthenticated) {
        return {'error': 'User not authenticated'};
      }

      final profileRepo = _ref.read(userProfileRepositoryProvider);
      final settingsRepo = _ref.read(userSettingsRepositoryProvider);

      final profile = await profileRepo.getCurrentUserProfile();
      final settings = await settingsRepo.getUserSettings();

      return {
        'user_id': AuthService.currentUser?.id,
        'email': AuthService.currentUser?.email,
        'profile_exists': profile != null,
        'settings_exists': settings != null,
        'profile_complete': profile?.fullName != null && profile?.phone != null,
        'last_login': profile?.lastLoginAt?.toIso8601String(),
        'preferred_language': profile?.preferredLanguage ?? 'en',
        'preferred_currency': profile?.preferredCurrency ?? 'USD',
        'theme_mode': settings?.themeMode ?? 'system',
        'notifications_enabled': profile?.pushNotifications ?? true,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}