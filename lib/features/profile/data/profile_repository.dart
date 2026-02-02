import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/shared/models/customer.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<Customer> getProfile(String userId) async {
    try {
      final response = await _client
          .from('customers')
          .select()
          .eq('id', userId)
          .single();
      
      return Customer.fromJson(response);
    } catch (e) {
      throw DataException('Failed to load profile: $e');
    }
  }

  Future<Customer> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (fullName != null) updateData['full_name'] = fullName;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (preferences != null) updateData['preferences'] = preferences;
      
      final response = await _client
          .from('customers')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();
      
      return Customer.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update profile: $e');
    }
  }

  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final fileExtension = path.extension(imageFile.path);
      final originalName = path.basename(imageFile.path);
      final fileName = 'profile-images/${userId}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      
      // Read bytes from file for cross-platform compatibility
      final bytes = await imageFile.readAsBytes();
      
      // Determine mime type based on extension
      final mimeType = _getMimeType(fileExtension);
      
      // Upload to app-storage bucket using bytes
      await _client
          .storage
          .from('app-storage')
          .uploadBinary(fileName, bytes);
      
      // Get the public URL
      final publicUrl = _client
          .storage
          .from('app-storage')
          .getPublicUrl(fileName);
      
      // Save to media_files table with all required fields
      final mediaResponse = await _client
          .from('media_files')
          .insert({
            'filename': path.basename(fileName),
            'original_name': originalName,
            'file_path': fileName,
            'file_url': publicUrl,
            'file_size': bytes.length,
            'mime_type': mimeType,
            'file_type': 'image',
            'bucket_name': 'app-storage',
            'uploaded_by': userId,
            'tag': 'profile',
            'is_public': true,
          })
          .select()
          .single();
      
      final mediaId = mediaResponse['id'];
      
      // Update the user profile with the new profile_image_id
      await _client
          .from('users')
          .update({'profile_image_id': mediaId})
          .eq('id', userId);
      
      // Also update the customers table with the avatar_url
      await _client
          .from('customers')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);
      
      return publicUrl;
    } catch (e) {
      throw DataException('Failed to upload avatar: $e');
    }
  }
  
  /// Helper to get mime type from file extension
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  Future<String> uploadAvatarBytes({
    required String userId,
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    try {
      final fileName = 'profile-images/${userId}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final mimeType = _getMimeType(fileExtension);
      
      // Upload to app-storage bucket
      await _client
          .storage
          .from('app-storage')
          .uploadBinary(fileName, bytes);
      
      // Get the public URL
      final publicUrl = _client
          .storage
          .from('app-storage')
          .getPublicUrl(fileName);
      
      // Save to media_files table with all required fields
      final mediaResponse = await _client
          .from('media_files')
          .insert({
            'filename': path.basename(fileName),
            'original_name': 'profile_image$fileExtension',
            'file_path': fileName,
            'file_url': publicUrl,
            'file_size': bytes.length,
            'mime_type': mimeType,
            'file_type': 'image',
            'bucket_name': 'app-storage',
            'uploaded_by': userId,
            'tag': 'profile',
            'is_public': true,
          })
          .select()
          .single();
      
      final mediaId = mediaResponse['id'];
      
      // Update the user profile with the new profile_image_id
      await _client
          .from('users')
          .update({'profile_image_id': mediaId})
          .eq('id', userId);
      
      // Also update the customers table with the avatar_url
      await _client
          .from('customers')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);
      
      return publicUrl;
    } catch (e) {
      throw DataException('Failed to upload avatar: $e');
    }
  }

  Future<void> updateUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      // First get current preferences
      final customer = await getProfile(userId);
      final currentPreferences = customer.preferences ?? {};
      
      // Merge with new preferences
      final updatedPreferences = {
        ...currentPreferences,
        ...preferences,
      };
      
      // Update profile with merged preferences
      await updateProfile(
        userId: userId,
        preferences: updatedPreferences,
      );
    } catch (e) {
      throw DataException('Failed to update preferences: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserPreferences(String userId) async {
    try {
      final customer = await getProfile(userId);
      return customer.preferences;
    } catch (e) {
      throw DataException('Failed to get preferences: $e');
    }
  }

  /// Upload profile image using ImagePicker
  Future<String> uploadProfileImageFromPicker({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw DataException('User not authenticated');
      }

      final fileExtension = path.extension(imageFile.path);
      final originalName = path.basename(imageFile.path);
      final fileName = 'profile-images/${user.id}_${DateTime.now().millisecondsSinceEpoch}${fileExtension.isNotEmpty ? fileExtension : '.jpg'}';
      final mimeType = _getMimeType(fileExtension.isNotEmpty ? fileExtension : '.jpg');
      
      // Read bytes from file for cross-platform compatibility
      final bytes = await imageFile.readAsBytes();
      
      // Upload to app-storage bucket using bytes
      await _client
          .storage
          .from('app-storage')
          .uploadBinary(fileName, bytes);
      
      // Get the public URL
      final publicUrl = _client
          .storage
          .from('app-storage')
          .getPublicUrl(fileName);
      
      // Save to media_files table with all required fields
      final mediaResponse = await _client
          .from('media_files')
          .insert({
            'filename': path.basename(fileName),
            'original_name': originalName.isNotEmpty ? originalName : 'profile_image.jpg',
            'file_path': fileName,
            'file_url': publicUrl,
            'file_size': bytes.length,
            'mime_type': mimeType,
            'file_type': 'image',
            'bucket_name': 'app-storage',
            'uploaded_by': user.id,
            'tag': 'profile',
            'is_public': true,
          })
          .select()
          .single();
      
      final mediaId = mediaResponse['id'];
      
      // Update user's profile_image_id
      await _client
          .from('users')
          .update({'profile_image_id': mediaId})
          .eq('id', user.id);
      
      // Also update the customers table with the avatar_url
      await _client
          .from('customers')
          .update({'avatar_url': publicUrl})
          .eq('id', user.id);
      
      return publicUrl;
    } catch (e) {
      throw DataException('Failed to upload profile image: $e');
    }
  }

  /// Load user with media files (profile image)
  Future<Map<String, dynamic>> getUserWithMedia(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('*, media_files!inner(file_url)')
          .eq('id', userId)
          .single();
      
      return response;
    } catch (e) {
      throw DataException('Failed to load user with media: $e');
    }
  }

  /// Get profile image URL for user
  Future<String?> getProfileImageUrl(String userId) async {
    try {
      final user = await getUserWithMedia(userId);
      final mediaFiles = user['media_files'];
      
      if (mediaFiles != null) {
        return mediaFiles['file_url'] as String?;
      }
      
      return null;
    } catch (e) {
      // Return null if no media found instead of throwing
      return null;
    }
  }

  /// Delete media file from storage and database
  Future<void> deleteMedia({
    required String mediaId,
    required String filePath,
  }) async {
    try {
      // Remove from storage
      await _client
          .storage
          .from('app-storage')
          .remove([filePath]);
      
      // Remove from database
      await _client
          .from('media_files')
          .delete()
          .eq('id', mediaId);
    } catch (e) {
      throw DataException('Failed to delete media: $e');
    }
  }

  /// Delete user's profile image
  Future<void> deleteProfileImage(String userId) async {
    try {
      // Get current profile image info
      final user = await _client
          .from('users')
          .select('profile_image_id, media_files!inner(id, file_path)')
          .eq('id', userId)
          .single();
      
      final mediaFiles = user['media_files'];
      if (mediaFiles != null) {
        final mediaId = mediaFiles['id'];
        final filePath = mediaFiles['file_path'];
        
        // Delete the media file
        await deleteMedia(mediaId: mediaId, filePath: filePath);
        
        // Clear profile_image_id from user
        await _client
            .from('users')
            .update({'profile_image_id': null})
            .eq('id', userId);
        
        // Also clear avatar_url from customers table
        await _client
            .from('customers')
            .update({'avatar_url': null})
            .eq('id', userId);
      }
    } catch (e) {
      throw DataException('Failed to delete profile image: $e');
    }
  }
}

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository(ref.watch(supabaseProvider));
} 