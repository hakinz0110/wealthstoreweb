import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wealth_app/core/config/app_config.dart';
import 'package:wealth_app/core/config/env_config.dart';
import 'package:wealth_app/core/services/database/database_initializer.dart';
import 'package:wealth_app/core/services/payment/paystack_service.dart';
import 'package:wealth_app/core/theme/app_theme.dart' as app_theme;
import 'package:wealth_app/core/theme/app_theme_provider.dart';
import 'package:wealth_app/core/utils/performance_optimizer.dart';
import 'package:wealth_app/core/services/deep_link_service.dart';
import 'package:wealth_app/features/cart/domain/cart_sync_service.dart';
import 'package:wealth_app/features/customer/data/customer_data_sync_service.dart';
import 'package:wealth_app/router/app_router.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment variables
  try {
    debugPrint('Loading environment variables');
    await EnvConfig.initialize();
    debugPrint('Environment variables loaded successfully');
  } catch (e, stackTrace) {
    debugPrint('Error loading environment variables: $e');
    debugPrint('Stack trace: $stackTrace');
  }
  
  // Initialize Supabase with better error handling
  try {
    debugPrint('Initializing Supabase with URL: ${AppConfig.supabaseUrl}');
    
    // Initialize Supabase
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      debug: AppConfig.isDevelopment,
    );
    
    // Get the client instance for verification
    final supabase = Supabase.instance.client;
    debugPrint('Supabase initialized successfully - Client ready: ${AppConfig.supabaseUrl}');
  } catch (e, stackTrace) {
    debugPrint('Error initializing Supabase: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue execution to show UI with error state
  }

  // Initialize performance optimization systems
  try {
    debugPrint('Initializing performance optimization systems');
    PerformanceOptimizer().initialize();
    debugPrint('Performance optimization systems initialized');
  } catch (e, stackTrace) {
    debugPrint('Error initializing performance systems: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  // Initialize Paystack
  try {
    debugPrint('Initializing Paystack');
    await PaystackService().initialize();
    debugPrint('Paystack initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Error initializing Paystack: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  // Initialize deep link service
  try {
    debugPrint('Initializing deep link service');
    await DeepLinkService().initialize(appRouter);
    debugPrint('Deep link service initialized');
  } catch (e, stackTrace) {
    debugPrint('Error initializing deep link service: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  // Set up auth state listener for OAuth callbacks and password recovery
  try {
    debugPrint('Setting up auth state listener');
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      debugPrint('Auth state changed: $event');
      
      if (event == AuthChangeEvent.passwordRecovery && session != null) {
        debugPrint('Password recovery detected - navigating to password update screen');
        // Navigate to password update screen
        appRouter.go('/password-update?access_token=${session.accessToken}&refresh_token=${session.refreshToken ?? ""}');
      } else if (event == AuthChangeEvent.signedIn && session != null) {
        debugPrint('User signed in: ${session.user.email}');
        // Navigation will be handled by the auth notifier
      } else if (event == AuthChangeEvent.signedOut) {
        debugPrint('User signed out');
      }
    });
    debugPrint('Auth state listener set up');
  } catch (e, stackTrace) {
    debugPrint('Error setting up auth state listener: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  // Initialize database if needed - with more careful handling
  if (AppConfig.isDevelopment) {
    try {
      debugPrint('Initializing database');
      
      // First verify the Supabase instance is properly initialized
      final client = Supabase.instance.client;
      final databaseInitializer = DatabaseInitializer(client);
      
      // Wait a short delay to ensure auth is ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Initialize the database
      await databaseInitializer.ensureDatabaseInitialized();
      debugPrint('Database initialization complete');
    } catch (e, stackTrace) {
      debugPrint('Error initializing database: $e');
      debugPrint('Stack trace: $stackTrace');
      // Continue anyway, as the database might already be set up
    }
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeProvider);
    
    // Initialize cart sync service
    ref.read(cartSyncServiceProvider).initialize();
    
    // Initialize customer data sync service
    ref.read(customerDataSyncServiceProvider).initialize();
    
    return ScreenUtilInit(
      designSize: const Size(402, 874), // Base mobile design size
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Wealth App',
          theme: app_theme.AppTheme.lightTheme(),
          darkTheme: app_theme.AppTheme.darkTheme(),
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          debugShowMaterialGrid: false,
          routerConfig: appRouter,
          builder: (context, widget) => ResponsiveBreakpoints.builder(
            child: widget!,
            breakpoints: [
              const Breakpoint(start: 0, end: 600, name: MOBILE),
              const Breakpoint(start: 601, end: 1024, name: TABLET),
              const Breakpoint(start: 1025, end: 1440, name: DESKTOP),
              const Breakpoint(start: 1441, end: double.infinity, name: '4K'),
            ],
          ),
        );
      },
    );
  }
}
