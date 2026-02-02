import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/core/utils/secure_storage.dart';
import 'package:wealth_app/shared/models/customer.dart';
import 'package:flutter/foundation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  // Get the currently authenticated user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Sign up a new user
  Future<AuthResponse> signUp(
    String email,
    String password,
    String fullName, {
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    try {
      debugPrint('Starting sign up for $email in auth repository');
      
      // Step 1: Sign up the user (this creates the auth record)
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.wealthapp://auth-callback/',
        data: {
          'full_name': fullName,
          'phone': phone,
          'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
          'gender': gender,
        }
      );
      
      debugPrint('Sign up response received: ${response.user != null}');

      if (response.user != null) {
        // Database trigger automatically creates profiles in:
        // - public.users
        // - public.user_profiles  
        // - public.customers
        // No need to manually create them!
        
        debugPrint('User created: ${response.user!.id}');
        debugPrint('Database trigger will create profiles automatically');
        
        // Store the user ID securely
        await SecureStorage.storeUserId(response.user!.id);
        
        // Store auth session for future requests
        if (response.session != null) {
          await SecureStorage.storeToken(response.session!.accessToken);
          debugPrint('Access token stored for future requests');
        }
        
        // Wait a moment for database trigger to complete
        await Future.delayed(const Duration(milliseconds: 500));
      }

      return response;
    } catch (e, stackTrace) {
      debugPrint('Sign up error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw AppAuthException('Sign up failed: $e');
    }
  }

  // NOTE: Profile creation is now handled by database trigger
  // The trigger automatically creates records in:
  // - public.users
  // - public.user_profiles
  // - public.customers
  // when a new user signs up in auth.users

  // Sign in an existing user
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      debugPrint('Starting sign in for $email in auth repository');
      
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      debugPrint('Sign in response received: ${response.user != null}');

      if (response.user != null) {
        debugPrint('Storing user ID: ${response.user!.id}');
        // Store the user ID securely
        await SecureStorage.storeUserId(response.user!.id);
        
        // Store auth token
        if (response.session != null) {
          await SecureStorage.storeToken(response.session!.accessToken);
        }
        
        // Profile should already exist from signup trigger
        // Just verify it exists
        try {
          final existingCustomer = await _client
              .from('customers')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();
              
          if (existingCustomer != null) {
            debugPrint('Customer profile exists: ${existingCustomer['full_name']}');
          } else {
            debugPrint('Warning: Customer profile not found - may need to be created by trigger');
          }
        } catch (e) {
          debugPrint('Error checking customer profile: $e');
          // Continue anyway, as the user is authenticated
        }
      } else {
        debugPrint('Warning: No user returned from sign in');
      }

      return response;
    } catch (e, stackTrace) {
      debugPrint('Sign in error: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (e is AuthException) {
        throw AppAuthException('Sign in failed: ${e.message}');
      } else {
        throw AppAuthException('Sign in failed: $e');
      }
    }
  }
  
  // Sign out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      await SecureStorage.clearAll();
    } catch (e) {
      throw AppAuthException('Sign out failed: $e');
    }
  }

  // Get customer profile data
  Future<Customer> getCustomerProfile() async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw AppAuthException('User not authenticated');
      }
      
      final response = await _client
          .from('customers')
          .select()
          .eq('id', user.id)
          .single();
      
      return Customer.fromJson(response);
    } catch (e) {
      throw DataException('Failed to load profile: $e');
    }
  }

  // Update customer profile data
  Future<Customer> updateCustomerProfile({
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw AppAuthException('User not authenticated');
      }

      final updates = {
        'full_name': fullName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      };
      
      final response = await _client
          .from('customers')
          .update(updates)
          .eq('id', user.id)
          .select()
          .single();
      
      return Customer.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update profile: $e');
    }
  }

  // Send password reset email with deep link redirect
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.wealthstore.shop://password-update',
      );
    } catch (e) {
      throw AppAuthException('Failed to send reset email: $e');
    }
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.watch(supabaseProvider));
} 