import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'WealthStoreSecureStorage',
      publicKey: 'WealthStorePublicKey',
    ),
  );
  
  // Auth Token
  static Future<void> storeToken(String token) async {
    if (kIsWeb) {
      // Use SharedPreferences for web (more reliable)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } else {
      await _storage.write(key: 'auth_token', value: token);
    }
  }
  
  static Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } else {
      return await _storage.read(key: 'auth_token');
    }
  }
  
  static Future<void> deleteToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } else {
      await _storage.delete(key: 'auth_token');
    }
  }
  
  // User ID
  static Future<void> storeUserId(String userId) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
    } else {
      await _storage.write(key: 'user_id', value: userId);
    }
  }
  
  static Future<String?> getUserId() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    } else {
      return await _storage.read(key: 'user_id');
    }
  }
  
  // Onboarding status
  static Future<void> setHasSeenOnboarding(bool hasSeen) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', hasSeen);
    } else {
      await _storage.write(key: 'has_seen_onboarding', value: hasSeen.toString());
    }
  }
  
  static Future<String?> getHasSeenOnboarding() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getBool('has_seen_onboarding');
      return value?.toString();
    } else {
      return await _storage.read(key: 'has_seen_onboarding');
    }
  }
  
  // Clear all stored data
  static Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } else {
      await _storage.deleteAll();
    }
  }
} 