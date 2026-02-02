import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  GoRouter? _router;

  /// Initialize deep link handling
  Future<void> initialize(GoRouter router) async {
    _router = router;
    _appLinks = AppLinks();

    // Handle app launch from deep link
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      await _handleDeepLink(initialUri);
    }

    // Handle deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  /// Handle incoming deep links
  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('Received deep link: $uri');
    debugPrint('Deep link host: ${uri.host}');
    debugPrint('Deep link path: ${uri.path}');
    debugPrint('Deep link query: ${uri.query}');

    try {
      // Check if this is a password reset link (has type=recovery or access_token)
      final type = uri.queryParameters['type'];
      final accessToken = uri.queryParameters['access_token'];
      final fragment = uri.fragment;
      
      // Parse fragment if it exists (Supabase sometimes puts tokens in fragment)
      Map<String, String> fragmentParams = {};
      if (fragment.isNotEmpty) {
        fragmentParams = Uri.splitQueryString(fragment);
      }
      
      final fragmentType = fragmentParams['type'];
      final fragmentAccessToken = fragmentParams['access_token'];
      
      // Handle password reset from query params or fragment
      if (type == 'recovery' || fragmentType == 'recovery' || 
          (accessToken != null && accessToken.isNotEmpty) ||
          (fragmentAccessToken != null && fragmentAccessToken.isNotEmpty)) {
        await _handlePasswordResetLink(uri);
      }
      // Handle OAuth callback (Google Sign-In)
      else if (uri.host == 'login-callback' || uri.host == 'auth-callback') {
        await _handleOAuthCallback(uri);
      }
      // Handle password reset deep links by path
      else if (uri.path == '/password-update') {
        await _handlePasswordResetLink(uri);
      } else {
        debugPrint('Unhandled deep link: ${uri.host}${uri.path}');
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  /// Handle OAuth callback from Google Sign-In
  Future<void> _handleOAuthCallback(Uri uri) async {
    debugPrint('Handling OAuth callback');
    
    // Extract tokens from the URI fragment or query parameters
    final fragment = uri.fragment;
    final queryParams = uri.queryParameters;
    
    debugPrint('Fragment: $fragment');
    debugPrint('Query params: $queryParams');
    
    // Supabase returns tokens in the fragment for OAuth
    if (fragment.isNotEmpty) {
      final fragmentParams = Uri.splitQueryString(fragment);
      final accessToken = fragmentParams['access_token'];
      final refreshToken = fragmentParams['refresh_token'];
      
      if (accessToken != null) {
        try {
          debugPrint('Setting session from OAuth callback');
          await Supabase.instance.client.auth.setSession(accessToken);
          
          // Navigate to home after successful authentication
          _router?.go('/home');
          debugPrint('OAuth authentication successful');
        } catch (e) {
          debugPrint('Error setting session from OAuth: $e');
          _router?.go('/auth');
        }
      }
    } else {
      debugPrint('No fragment found in OAuth callback');
      // Still try to navigate home in case session was already set
      _router?.go('/home');
    }
  }

  /// Handle password reset deep links
  Future<void> _handlePasswordResetLink(Uri uri) async {
    debugPrint('Handling password reset link');
    debugPrint('Full URI: $uri');
    
    // Try to get tokens from query parameters first
    var accessToken = uri.queryParameters['access_token'];
    var refreshToken = uri.queryParameters['refresh_token'];
    var type = uri.queryParameters['type'];
    var code = uri.queryParameters['code']; // Supabase PKCE flow uses 'code'
    
    // If not in query params, check fragment (Supabase often uses fragment)
    if (accessToken == null && uri.fragment.isNotEmpty) {
      final fragmentParams = Uri.splitQueryString(uri.fragment);
      accessToken = fragmentParams['access_token'];
      refreshToken = fragmentParams['refresh_token'];
      type = fragmentParams['type'];
      code = fragmentParams['code'];
      debugPrint('Found tokens in fragment: accessToken=${accessToken != null}, refreshToken=${refreshToken != null}, type=$type, code=$code');
    }

    // Handle PKCE flow (code exchange)
    if (code != null && code.isNotEmpty) {
      try {
        debugPrint('Exchanging code for session (PKCE flow)');
        final response = await Supabase.instance.client.auth.exchangeCodeForSession(code);
        if (response.session != null) {
          debugPrint('Code exchange successful');
          _router?.go('/password-update?access_token=${response.session!.accessToken}&refresh_token=${response.session!.refreshToken ?? ""}');
          return;
        }
      } catch (e) {
        debugPrint('Error exchanging code: $e');
      }
    }

    // Handle direct token flow
    if (accessToken != null && accessToken.isNotEmpty) {
      try {
        debugPrint('Setting recovery session with access token');
        
        // Try to set session - for recovery, we need both tokens ideally
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await Supabase.instance.client.auth.setSession(accessToken);
        } else {
          // Try recover session for single token
          await Supabase.instance.client.auth.recoverSession(accessToken);
        }
        debugPrint('Recovery session set successfully');

        // Navigate to password update screen
        _router?.go('/password-update?access_token=$accessToken&refresh_token=${refreshToken ?? ""}');
        debugPrint('Navigated to password update screen');
      } catch (e) {
        debugPrint('Error setting session from deep link: $e');
        // Still try to navigate - the session might already be set by Supabase
        _router?.go('/password-update?access_token=$accessToken&refresh_token=${refreshToken ?? ""}');
      }
    } else {
      debugPrint('No access token or code found in password reset link');
      _router?.go('/forgot-password');
    }
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}