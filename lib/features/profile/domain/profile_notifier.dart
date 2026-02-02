import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealth_app/features/profile/data/profile_repository.dart';
import 'package:wealth_app/features/profile/data/user_addresses_repository.dart';
import 'package:wealth_app/features/profile/domain/profile_state.dart';
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/shared/models/address.dart';


class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final UserAddressesRepository _addressRepository;
  final Map<int, String> _addressIdMapping = {}; // Maps display ID to actual UUID

  ProfileNotifier(this._repository, this._addressRepository) : super(const ProfileState());

  Future<void> updateProfile({String? fullName, String? phoneNumber}) async {
    if (state.customer == null) return;
    
    state = state.copyWith(isUpdating: true);
    
    try {
      final updatedCustomer = await _repository.updateProfile(
        userId: state.customer!.id,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      
      state = state.copyWith(
        customer: updatedCustomer,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
  
  Future<void> uploadAvatar(File imageFile) async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    
    state = state.copyWith(isUploadingAvatar: true);
    
    try {
      final avatarUrl = await _repository.uploadProfileImageFromPicker(
        userId: user.id,
        imageFile: imageFile,
      );
      
      // Update the customer with new avatar URL
      if (state.customer != null) {
        final updatedCustomer = state.customer!.copyWith(avatarUrl: avatarUrl);
        state = state.copyWith(
          customer: updatedCustomer,
          isUploadingAvatar: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isUploadingAvatar: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Load profile image URL for current user
  Future<void> loadProfileImage() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    
    try {
      final imageUrl = await _repository.getProfileImageUrl(user.id);
      
      if (state.customer != null && imageUrl != null) {
        final updatedCustomer = state.customer!.copyWith(avatarUrl: imageUrl);
        state = state.copyWith(customer: updatedCustomer);
      }
    } catch (e) {
      // Silently handle error - profile image is optional
      debugPrint('Failed to load profile image: $e');
    }
  }

  /// Delete profile image
  Future<void> deleteProfileImage() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    
    state = state.copyWith(isUploadingAvatar: true);
    
    try {
      // Simply update the profile to remove the avatar URL
      final updatedCustomer = await _repository.updateProfile(
        userId: user.id,
        avatarUrl: null,
      );
      
      state = state.copyWith(
        customer: updatedCustomer,
        isUploadingAvatar: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUploadingAvatar: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Handle profile image update from picker widget
  void onProfileImageUpdated(String imageUrl) {
    if (state.customer != null) {
      final updatedCustomer = imageUrl.isEmpty 
          ? state.customer!.copyWith(avatarUrl: null)
          : state.customer!.copyWith(avatarUrl: imageUrl);
      state = state.copyWith(customer: updatedCustomer);
    }
  }
  
  Future<void> createAddress({
    required String name,
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required String country,
    bool isDefault = false,
    String? phoneNumber,
    String? additionalInfo,
  }) async {
    debugPrint('createAddress called');
    
    this.state = this.state.copyWith(isUpdating: true);
    
    try {
      await _addressRepository.addAddress(
        label: 'Home', // Default label
        fullName: name,
        phone: phoneNumber,
        addressLine1: street,
        addressLine2: additionalInfo,
        city: city,
        state: state,
        postalCode: zipCode,
        country: country,
        isDefault: isDefault,
      );
      
      // Refresh addresses after creating
      await loadAddresses();
      
      this.state = this.state.copyWith(isUpdating: false);
    } catch (e) {
      this.state = this.state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
  
  Future<void> updateAddress({
    required int id,
    String? name,
    String? street,
    String? city,
    String? stateRegion,
    String? zipCode,
    String? country,
    bool? isDefault,
    String? phoneNumber,
    String? additionalInfo,
  }) async {
    debugPrint('updateAddress called');
    
    // Get the actual UUID from the mapping
    final actualId = _addressIdMapping[id];
    if (actualId == null) {
      throw Exception('Address not found');
    }
    
    state = state.copyWith(isUpdating: true);
    
    try {
      await _addressRepository.updateAddress(
        addressId: actualId,
        fullName: name,
        phone: phoneNumber,
        addressLine1: street,
        addressLine2: additionalInfo,
        city: city,
        state: stateRegion,
        postalCode: zipCode,
        country: country,
        isDefault: isDefault,
      );
      
      // Refresh addresses after updating
      await loadAddresses();
      
      state = state.copyWith(isUpdating: false);
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
  
  Future<void> deleteAddress(int id) async {
    debugPrint('deleteAddress called');
    
    // Get the actual UUID from the mapping
    final actualId = _addressIdMapping[id];
    if (actualId == null) {
      throw Exception('Address not found');
    }
    
    state = state.copyWith(isUpdating: true);
    
    try {
      await _addressRepository.deleteAddress(actualId);
      
      // Refresh addresses after deleting
      await loadAddresses();
      
      state = state.copyWith(isUpdating: false);
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
  
  Future<void> setDefaultAddress(int id) async {
    debugPrint('setDefaultAddress called');
    
    // Get the actual UUID from the mapping
    final actualId = _addressIdMapping[id];
    if (actualId == null) {
      throw Exception('Address not found');
    }
    
    state = state.copyWith(isUpdating: true);
    
    try {
      await _addressRepository.setAsDefault(actualId);
      
      // Refresh addresses after setting default
      await loadAddresses();
      
      state = state.copyWith(isUpdating: false);
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
  
  Future<void> updateThemePreference(String theme) async {
    debugPrint('updateThemePreference called with $theme');
    // This method should be handled by the theme provider directly
    // The profile screen should call the theme provider instead
    return Future.value();
  }
  
  Future<void> updateLanguagePreference(String language) async {
    debugPrint('updateLanguagePreference called with $language');
    return Future.value();
  }
  
  Future<void> refreshProfile() async {
    debugPrint('refreshProfile called');
    final user = SupabaseService.currentUser;
    if (user == null) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final customer = await _repository.getProfile(user.id);
      
      // Also load addresses
      await loadAddresses();
      
      state = state.copyWith(
        customer: customer,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadAddresses() async {
    try {
      final userAddresses = await _addressRepository.getUserAddresses();
      
      // Convert UserAddress to Address model
      final addresses = userAddresses.map((userAddr) => Address(
        id: userAddr.id.hashCode, // Use hashCode for int ID but keep original for operations
        userId: userAddr.userId,
        name: userAddr.fullName,
        street: userAddr.addressLine1,
        city: userAddr.city,
        state: userAddr.state,
        zipCode: userAddr.postalCode,
        country: userAddr.country,
        isDefault: userAddr.isDefault,
        phoneNumber: userAddr.phone,
        additionalInfo: userAddr.addressLine2,
      )).toList();
      
      // Store the mapping of display ID to actual UUID for operations
      _addressIdMapping.clear();
      for (final userAddr in userAddresses) {
        _addressIdMapping[userAddr.id.hashCode] = userAddr.id;
      }
      
      state = state.copyWith(addresses: addresses);
    } catch (e) {
      debugPrint('Failed to load addresses: $e');
    }
  }

  Future<void> updateProfileImage(String imageUrl) async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    
    state = state.copyWith(isUpdating: true);
    
    try {
      final updatedCustomer = await _repository.updateProfile(
        userId: user.id,
        avatarUrl: imageUrl.isEmpty ? null : imageUrl,
      );
      
      state = state.copyWith(
        customer: updatedCustomer,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    
    try {
      await _repository.updateUserPreferences(
        userId: user.id,
        preferences: preferences,
      );
      
      // Update the local state
      if (state.customer != null) {
        final updatedCustomer = state.customer!.copyWith(preferences: preferences);
        state = state.copyWith(customer: updatedCustomer);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      debugPrint('Failed to update preferences: $e');
    }
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    ref.watch(profileRepositoryProvider),
    ref.watch(userAddressesRepositoryProvider),
  );
}); 