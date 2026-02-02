import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/auth_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';

part 'user_addresses_repository.g.dart';

@riverpod
UserAddressesRepository userAddressesRepository(UserAddressesRepositoryRef ref) {
  return UserAddressesRepository();
}

class UserAddress {
  final String id;
  final String userId;
  final String label;
  final String fullName;
  final String? phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final String addressType;
  final String? deliveryInstructions;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserAddress({
    required this.id,
    required this.userId,
    required this.label,
    required this.fullName,
    this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'USA',
    this.isDefault = false,
    this.addressType = 'residential',
    this.deliveryInstructions,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      label: json['label'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String? ?? 'USA',
      isDefault: json['is_default'] as bool? ?? false,
      addressType: json['address_type'] as String? ?? 'residential',
      deliveryInstructions: json['delivery_instructions'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'full_name': fullName,
      'phone': phone,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'is_default': isDefault,
      'address_type': addressType,
      'delivery_instructions': deliveryInstructions,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserAddress copyWith({
    String? id,
    String? userId,
    String? label,
    String? fullName,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
    String? addressType,
    String? deliveryInstructions,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserAddress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      addressType: addressType ?? this.addressType,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get formatted address string
  String get formattedAddress {
    final parts = <String>[
      addressLine1,
      if (addressLine2?.isNotEmpty == true) addressLine2!,
      '$city, $state $postalCode',
      if (country != 'USA') country,
    ];
    return parts.join('\n');
  }

  // Get single line address
  String get singleLineAddress {
    final parts = <String>[
      addressLine1,
      if (addressLine2?.isNotEmpty == true) addressLine2!,
      city,
      state,
      postalCode,
    ];
    return parts.join(', ');
  }
}

class UserAddressesRepository {
  final SupabaseClient _supabase = AuthService.client;

  String? get _currentUserId => AuthService.currentUser?.id;

  // Get all user addresses
  Future<List<UserAddress>> getUserAddresses() async {
    try {
      if (_currentUserId == null) return [];

      final response = await _supabase
          .from('user_addresses')
          .select('*')
          .eq('user_id', _currentUserId!)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((item) => UserAddress.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DataException('Failed to load user addresses: $e');
    }
  }

  // Get default address
  Future<UserAddress?> getDefaultAddress() async {
    try {
      if (_currentUserId == null) return null;

      final response = await _supabase
          .from('user_addresses')
          .select('*')
          .eq('user_id', _currentUserId!)
          .eq('is_default', true)
          .maybeSingle();

      if (response == null) return null;

      return UserAddress.fromJson(response);
    } catch (e) {
      throw DataException('Failed to load default address: $e');
    }
  }

  // Get address by ID
  Future<UserAddress?> getAddressById(String addressId) async {
    try {
      if (_currentUserId == null) return null;

      final response = await _supabase
          .from('user_addresses')
          .select('*')
          .eq('id', addressId)
          .eq('user_id', _currentUserId!)
          .maybeSingle();

      if (response == null) return null;

      return UserAddress.fromJson(response);
    } catch (e) {
      throw DataException('Failed to load address: $e');
    }
  }

  // Add new address
  Future<UserAddress> addAddress({
    required String label,
    required String fullName,
    String? phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    String country = 'USA',
    bool isDefault = false,
    String addressType = 'residential',
    String? deliveryInstructions,
    double? latitude,
    double? longitude,
  }) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      // If this is set as default, unset other default addresses
      if (isDefault) {
        await _unsetOtherDefaultAddresses();
      }

      final addressData = {
        'user_id': _currentUserId!,
        'label': label,
        'full_name': fullName,
        'phone': phone,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
        'is_default': isDefault,
        'address_type': addressType,
        'delivery_instructions': deliveryInstructions,
        'latitude': latitude,
        'longitude': longitude,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('user_addresses')
          .insert(addressData)
          .select()
          .single();

      return UserAddress.fromJson(response);
    } catch (e) {
      throw DataException('Failed to add address: $e');
    }
  }

  // Update address
  Future<UserAddress> updateAddress({
    required String addressId,
    String? label,
    String? fullName,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
    String? addressType,
    String? deliveryInstructions,
    double? latitude,
    double? longitude,
  }) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      // If this is set as default, unset other default addresses
      if (isDefault == true) {
        await _unsetOtherDefaultAddresses(excludeId: addressId);
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (label != null) updateData['label'] = label;
      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (addressLine1 != null) updateData['address_line1'] = addressLine1;
      if (addressLine2 != null) updateData['address_line2'] = addressLine2;
      if (city != null) updateData['city'] = city;
      if (state != null) updateData['state'] = state;
      if (postalCode != null) updateData['postal_code'] = postalCode;
      if (country != null) updateData['country'] = country;
      if (isDefault != null) updateData['is_default'] = isDefault;
      if (addressType != null) updateData['address_type'] = addressType;
      if (deliveryInstructions != null) updateData['delivery_instructions'] = deliveryInstructions;
      if (latitude != null) updateData['latitude'] = latitude;
      if (longitude != null) updateData['longitude'] = longitude;

      final response = await _supabase
          .from('user_addresses')
          .update(updateData)
          .eq('id', addressId)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      return UserAddress.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update address: $e');
    }
  }

  // Set address as default
  Future<UserAddress> setAsDefault(String addressId) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      // Unset other default addresses
      await _unsetOtherDefaultAddresses(excludeId: addressId);

      // Set this address as default
      final response = await _supabase
          .from('user_addresses')
          .update({
            'is_default': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', addressId)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      return UserAddress.fromJson(response);
    } catch (e) {
      throw DataException('Failed to set address as default: $e');
    }
  }

  // Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      if (_currentUserId == null) {
        throw DataException('User not authenticated');
      }

      await _supabase
          .from('user_addresses')
          .delete()
          .eq('id', addressId)
          .eq('user_id', _currentUserId!);
    } catch (e) {
      throw DataException('Failed to delete address: $e');
    }
  }

  // Get addresses by type
  Future<List<UserAddress>> getAddressesByType(String addressType) async {
    try {
      if (_currentUserId == null) return [];

      final response = await _supabase
          .from('user_addresses')
          .select('*')
          .eq('user_id', _currentUserId!)
          .eq('address_type', addressType)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((item) => UserAddress.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DataException('Failed to load addresses by type: $e');
    }
  }

  // Search addresses
  Future<List<UserAddress>> searchAddresses(String query) async {
    try {
      if (_currentUserId == null) return [];

      final response = await _supabase
          .from('user_addresses')
          .select('*')
          .eq('user_id', _currentUserId!)
          .or('label.ilike.%$query%,full_name.ilike.%$query%,address_line1.ilike.%$query%,city.ilike.%$query%')
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((item) => UserAddress.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DataException('Failed to search addresses: $e');
    }
  }

  // Get addresses count
  Future<int> getAddressesCount() async {
    try {
      if (_currentUserId == null) return 0;

      final response = await _supabase
          .from('user_addresses')
          .select('id')
          .eq('user_id', _currentUserId!);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // Private helper to unset other default addresses
  Future<void> _unsetOtherDefaultAddresses({String? excludeId}) async {
    try {
      var query = _supabase
          .from('user_addresses')
          .update({
            'is_default': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', _currentUserId!)
          .eq('is_default', true);

      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }

      await query;
    } catch (e) {
      // Don't throw error as this is a helper function
      print('Failed to unset other default addresses: $e');
    }
  }

  // Watch addresses changes (for real-time updates)
  Stream<List<UserAddress>> watchAddresses() {
    if (_currentUserId != null) {
      return _supabase
          .from('user_addresses')
          .stream(primaryKey: ['id'])
          .eq('user_id', _currentUserId!)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false)
          .map((data) => data.map((item) => UserAddress.fromJson(item)).toList());
    } else {
      return Stream.value([]);
    }
  }
}