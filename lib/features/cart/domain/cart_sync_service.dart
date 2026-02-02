import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/core/services/auth_service.dart';
import 'package:wealth_app/features/cart/domain/cart_notifier.dart';

part 'cart_sync_service.g.dart';

@riverpod
CartSyncService cartSyncService(CartSyncServiceRef ref) {
  return CartSyncService(ref);
}

class CartSyncService {
  final CartSyncServiceRef _ref;

  CartSyncService(this._ref);

  /// Initialize cart sync service
  /// This should be called when the app starts
  void initialize() {
    // Listen to auth state changes
    AuthService.authStateChanges.listen((authState) {
      if (authState.session != null) {
        // User logged in - sync local cart to Supabase
        _syncCartOnLogin();
      } else {
        // User logged out - reload cart (will switch to local storage)
        _reloadCartOnLogout();
      }
    });
  }

  /// Sync local cart to Supabase when user logs in
  Future<void> _syncCartOnLogin() async {
    try {
      final cartNotifier = _ref.read(cartNotifierProvider.notifier);
      await cartNotifier.syncLocalCartToSupabase();
      print('Cart synced successfully after login');
    } catch (e) {
      print('Failed to sync cart after login: $e');
    }
  }

  /// Reload cart when user logs out (switches to local storage)
  Future<void> _reloadCartOnLogout() async {
    try {
      final cartNotifier = _ref.read(cartNotifierProvider.notifier);
      // Force reload cart from local storage
      await cartNotifier.build();
      print('Cart reloaded after logout');
    } catch (e) {
      print('Failed to reload cart after logout: $e');
    }
  }

  /// Manually sync cart (can be called from UI)
  Future<void> syncCart() async {
    try {
      if (AuthService.isAuthenticated) {
        final cartNotifier = _ref.read(cartNotifierProvider.notifier);
        await cartNotifier.syncLocalCartToSupabase();
      }
    } catch (e) {
      print('Manual cart sync failed: $e');
      rethrow;
    }
  }
}