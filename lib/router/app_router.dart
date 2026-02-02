import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:wealth_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:wealth_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:wealth_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:wealth_app/features/auth/presentation/screens/startup_screen.dart';
import 'package:wealth_app/features/auth/screens/password_reset_screen.dart';
import 'package:wealth_app/features/auth/screens/password_update_screen.dart';
import 'package:wealth_app/features/cart/presentation/screens/modern_cart_screen.dart';
import 'package:wealth_app/features/cart/presentation/screens/checkout_screen.dart';

import 'package:wealth_app/features/home/presentation/screens/home_screen.dart';
import 'package:wealth_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:wealth_app/features/orders/presentation/screens/order_details_screen.dart';
import 'package:wealth_app/features/orders/presentation/screens/order_history_screen.dart';
import 'package:wealth_app/features/products/presentation/screens/product_details_screen.dart';
import 'package:wealth_app/features/products/presentation/screens/product_list_screen.dart';
import 'package:wealth_app/features/profile/presentation/screens/address_form_screen.dart';
import 'package:wealth_app/features/profile/presentation/screens/address_list_screen.dart';
import 'package:wealth_app/features/profile/presentation/screens/enhanced_profile_screen.dart';
import 'package:wealth_app/features/profile/presentation/screens/enhanced_edit_profile_screen.dart';
import 'package:wealth_app/features/profile/presentation/screens/privacy_policy_screen.dart';
import 'package:wealth_app/features/profile/presentation/screens/terms_of_service_screen.dart';
import 'package:wealth_app/features/support/presentation/screens/support_screen.dart';
import 'package:wealth_app/features/search/presentation/screens/search_screen.dart';
import 'package:wealth_app/features/wishlist/presentation/screens/supabase_wishlist_screen.dart';
import 'package:wealth_app/features/categories/presentation/screens/category_product_page.dart';
import 'package:wealth_app/router/main_navigation_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/startup',
  navigatorKey: rootNavigatorKey,
  routes: [
    // Auth flow
    GoRoute(
      path: '/startup',
      builder: (context, state) => const StartupScreen(),
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/auth/callback',
      redirect: (context, state) {
        // OAuth callback - Supabase handles the session automatically
        // Just redirect to home
        return '/home';
      },
    ),
    GoRoute(
      path: '/password-reset',
      builder: (context, state) => const PasswordResetScreen(),
    ),
    GoRoute(
      path: '/password-update',
      builder: (context, state) {
        final accessToken = state.uri.queryParameters['access_token'];
        final refreshToken = state.uri.queryParameters['refresh_token'];
        return PasswordUpdateScreen(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    
    // Privacy and Terms
    GoRoute(
      path: '/privacy-policy',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/terms-of-service',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const TermsOfServiceScreen(),
    ),

    // Product details (outside of the shell to show full screen)
    GoRoute(
      path: '/product/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final productId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return ProductDetailsScreen(productId: productId);
      },
    ),
    
    // Checkout (outside of the shell to show full screen)
    GoRoute(
      path: '/checkout',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const CheckoutScreen(),
    ),
    
    // Order details (outside of the shell for full screen view)
    GoRoute(
      path: '/order-details/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final orderId = state.pathParameters['id'] ?? '';
        return OrderDetailsScreen(orderId: orderId);
      },
    ),
    
    // Notifications screen (outside of the shell to show full screen)
    GoRoute(
      path: '/notifications',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NotificationsScreen(),
    ),
    
    // Search screen (outside of the shell to show full screen)
    GoRoute(
      path: '/search',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),
    
    // Wishlist screen (outside of the shell to show full screen)
    GoRoute(
      path: '/wishlist',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SupabaseWishlistScreen(),
    ),
    
    // Cart screen (outside of the shell for direct navigation from product details)
    GoRoute(
      path: '/cart-view',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ModernCartScreen(),
    ),
    
    // Category product page (outside of the shell to show full screen)
    GoRoute(
      path: '/category/:categoryId/:categoryName',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final categoryId = int.tryParse(state.pathParameters['categoryId'] ?? '') ?? 0;
        final categoryName = Uri.decodeComponent(state.pathParameters['categoryName'] ?? 'Category');
        return CategoryProductPage(
          categoryId: categoryId,
          categoryName: categoryName,
        );
      },
    ),
    
    // Enhanced profile screens (full screen versions)
    GoRoute(
      path: '/profile-enhanced',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const EnhancedProfileScreen(),
    ),
    GoRoute(
      path: '/profile-edit-enhanced',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const EnhancedEditProfileScreen(),
    ),
    
    // Help center (placeholder for future implementation)

    
    // Main app shell with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainNavigationShell(
        navigationShell: navigationShell, 
        child: navigationShell,
      ),
      branches: [
        // Home branch
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
              routes: [
                // Add nested routes for home here
              ],
            ),
          ],
        ),
        
        // Products branch
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: '/products',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProductListScreen(),
              ),
              routes: [
                // Add product category routes here if needed
              ],
            ),
          ],
        ),
        
        // Cart branch
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: '/cart',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ModernCartScreen(),
              ),
            ),
          ],
        ),
        

        
        // Profile branch
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: EnhancedProfileScreen(),
              ),
              routes: [
                // Enhanced profile routes
                GoRoute(
                  path: 'edit-enhanced',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: EnhancedEditProfileScreen(),
                  ),
                ),
                
                // Address management
                GoRoute(
                  path: 'addresses',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: AddressListScreen(),
                  ),
                ),
                GoRoute(
                  path: 'addresses/add',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: AddressFormScreen(),
                  ),
                ),
                GoRoute(
                  path: 'addresses/edit/:id',
                  pageBuilder: (context, state) {
                    final addressId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                    return NoTransitionPage(
                      child: AddressFormScreen(addressId: addressId),
                    );
                  },
                ),
                

                
                // Orders from profile
                GoRoute(
                  path: 'orders',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: OrderHistoryScreen(),
                  ),
                ),
                
                // Support tickets
                GoRoute(
                  path: 'support',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: SupportScreen(),
                  ),
                ),
                
                // Notification preferences (placeholder for future implementation)
                GoRoute(
                  path: 'notifications',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: NotificationsScreen(),
                  ),
                ),
                

              ],
            ),
          ],
        ),
      ],
    ),
  ],
  
  // Global redirect to check auth state
  redirect: (context, state) {
    // TODO: Implement auth redirect logic
    // Protected routes should redirect to auth if not logged in
    // e.g. checkout, profile, orders
    return null;
  },
  
  // Error handling
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('The path ${state.uri.path} does not exist'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
); 