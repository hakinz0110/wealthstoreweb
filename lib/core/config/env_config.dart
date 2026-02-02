import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // Paystack
  static String get paystackPublicKey => dotenv.env['PAYSTACK_PUBLIC_KEY'] ?? '';
  static String get paystackSecretKey => dotenv.env['PAYSTACK_SECRET_KEY'] ?? '';
  
  // Initialize environment
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }
}
