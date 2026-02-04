import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Supabase - Try compile-time constants first, then fall back to .env file
  static String get supabaseUrl {
    const compileTimeUrl = String.fromEnvironment('SUPABASE_URL');
    if (compileTimeUrl.isNotEmpty) return compileTimeUrl;
    return dotenv.env['SUPABASE_URL'] ?? '';
  }
  
  static String get supabaseAnonKey {
    const compileTimeKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (compileTimeKey.isNotEmpty) return compileTimeKey;
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }
  
  // Paystack - Try compile-time constants first, then fall back to .env file
  static String get paystackPublicKey {
    const compileTimeKey = String.fromEnvironment('PAYSTACK_PUBLIC_KEY');
    if (compileTimeKey.isNotEmpty) return compileTimeKey;
    return dotenv.env['PAYSTACK_PUBLIC_KEY'] ?? '';
  }
  
  static String get paystackSecretKey {
    const compileTimeKey = String.fromEnvironment('PAYSTACK_SECRET_KEY');
    if (compileTimeKey.isNotEmpty) return compileTimeKey;
    return dotenv.env['PAYSTACK_SECRET_KEY'] ?? '';
  }
  
  // Initialize environment
  static Future<void> initialize() async {
    try {
      // Try to load .env file (for local development)
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // .env file not found - this is OK for production builds
      // where environment variables are passed via --dart-define
      print('Note: .env file not found, using compile-time environment variables');
    }
  }
}
