import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/auth_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';

part 'user_profile_repository.g.dart';

@riverpod
UserProfileRepository userProfileRepository(UserProfileRepositoryRef ref) {
  return UserProfileRepository();
}

class UserProfile {
  final String id;
  final String? email;
  final String? fullName;
  final String? username;
  final String? phone;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final String preferredLanguage;
  final String preferredCurrency;
  final String timezone;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final bool marketingEmails;
  final bool isActive;
  final bool isVerified;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.email,
    this.fullName,
    this.username,
    this.phone,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.preferredLanguage = 'en',
    this.preferredCurrency = 'USD',
    this.timezone = 'UTC',
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.pushNotifications = true,
    this.marketingEmails = true,
    this.isActive = true,
    this.isVerified = false,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      preferredCurrency: json['preferred_currency'] as String? ?? 'USD',
      timezone: json['timezone'] as String? ?? 'UTC',
      emailNotifications: json['email_notifications'] as bool? ?? true,
      smsNotifications: json['sms_notifications'] as bool? ?? false,
      pushNotifications: json['push_notifications'] as bool? ?? true,
      marketingEmails: json['marketing_emails'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'username': username,
      'phone': phone,
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'gender': gender,
      'preferred_language': preferredLanguage,
      'preferred_currency': preferredCurrency,
      'timezone': timezone,
      'email_notifications': emailNotifications,
      'sms_notifications': smsNotifications,
      'push_notifications': pushNotifications,
      'marketing_emails': marketingEmails,
      'is_active': isActive,
      'is_verified': isVerified,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    String? phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? gender,
    String? preferredLanguage,
    String? preferredCurrency,
    String? timezone,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
    bool? marketingEmails,
    bool? isActive,
    bool? isVerified,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      timezone: timezone ?? this.timezone,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserProfileRepository {
  final SupabaseClient _supabase = AuthService.client;

  String? get _currentUserId => AuthService.currentUser?.id;

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      if (_currentUserId == null) return null;

      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('id', _currentUserId!)
          .maybeSingle();

      if (response == null) return null;

      return UserProfile.fromJson(response);
    } catch (e) {
      throw DataException('Failed to load user profile: $e');
    }
  }

  // Create or update user profile
  Future<UserProfile> upsertUserProfile(UserProfile profile) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      final profileData = profile.toJson();
      profileData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('user_profiles')
          .upsert(profileData)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw DataException('Failed to save user profile: $e');
    }
  }

  // Update specific profile fields
  Future<UserProfile> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? gender,
    String? preferredLanguage,
    String? preferredCurrency,
    String? timezone,
  }) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      // Check if profile exists first
      final existingProfile = await getCurrentUserProfile();
      
      if (existingProfile == null) {
        // Create initial profile if it doesn't exist
        final user = AuthService.currentUser;
        await createInitialProfile(
          userId: _currentUserId!,
          email: user?.email,
          fullName: fullName,
        );
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (dateOfBirth != null) updateData['date_of_birth'] = dateOfBirth.toIso8601String().split('T')[0];
      if (gender != null) updateData['gender'] = gender;
      if (preferredLanguage != null) updateData['preferred_language'] = preferredLanguage;
      if (preferredCurrency != null) updateData['preferred_currency'] = preferredCurrency;
      if (timezone != null) updateData['timezone'] = timezone;

      final response = await _supabase
          .from('user_profiles')
          .update(updateData)
          .eq('id', _currentUserId!)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update profile: $e');
    }
  }

  // Update notification preferences
  Future<UserProfile> updateNotificationPreferences({
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
    bool? marketingEmails,
  }) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      // Check if profile exists first
      final existingProfile = await getCurrentUserProfile();
      
      if (existingProfile == null) {
        // Create initial profile if it doesn't exist
        final user = AuthService.currentUser;
        await createInitialProfile(
          userId: _currentUserId!,
          email: user?.email,
        );
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (emailNotifications != null) updateData['email_notifications'] = emailNotifications;
      if (smsNotifications != null) updateData['sms_notifications'] = smsNotifications;
      if (pushNotifications != null) updateData['push_notifications'] = pushNotifications;
      if (marketingEmails != null) updateData['marketing_emails'] = marketingEmails;

      final response = await _supabase
          .from('user_profiles')
          .update(updateData)
          .eq('id', _currentUserId!)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update notification preferences: $e');
    }
  }

  // Update last login timestamp
  Future<void> updateLastLogin() async {
    try {
      if (_currentUserId == null) return;

      await _supabase
          .from('user_profiles')
          .update({
            'last_login_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentUserId!);
    } catch (e) {
      print('Failed to update last login: $e');
      // Don't throw error as this is not critical
    }
  }

  // Create initial profile for new users
  Future<UserProfile> createInitialProfile({
    required String userId,
    String? email,
    String? fullName,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    try {
      final profileData = {
        'id': userId,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
        'gender': gender,
        'preferred_language': 'en',
        'preferred_currency': 'USD',
        'timezone': 'UTC',
        'email_notifications': true,
        'sms_notifications': false,
        'push_notifications': true,
        'marketing_emails': true,
        'is_active': true,
        'is_verified': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('user_profiles')
          .insert(profileData)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw DataException('Failed to create user profile: $e');
    }
  }

  // Delete user profile
  Future<void> deleteProfile() async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      await _supabase
          .from('user_profiles')
          .delete()
          .eq('id', _currentUserId!);
    } catch (e) {
      throw DataException('Failed to delete profile: $e');
    }
  }

  // Update profile image
  Future<void> updateProfileImage(String? imageUrl) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      await _supabase
          .from('user_profiles')
          .update({
            'avatar_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentUserId!);
    } catch (e) {
      throw DataException('Failed to update profile image: $e');
    }
  }
}