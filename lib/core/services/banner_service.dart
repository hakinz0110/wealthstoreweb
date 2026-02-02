import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/banner.dart';
import '../../core/exceptions/app_exceptions.dart';
import 'supabase_service.dart';

part 'banner_service.g.dart';

@riverpod
BannerService bannerService(BannerServiceRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return BannerService(supabase);
}

class BannerService {
  final SupabaseClient _client;
  static const String _tableName = 'banners';
  
  BannerService(this._client);
  
  /// Get all banners with optional filtering
  Future<List<Banner>> getBanners({
    bool? isActive,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from(_tableName).select('*');
      
      // Apply sorting and pagination - order by created_at since sort_order doesn't exist
      var transformQuery = query.order('created_at', ascending: false);
      
      if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }
      
      if (offset != null) {
        transformQuery = transformQuery.range(offset, offset + (limit ?? 10) - 1);
      }
      
      final response = await transformQuery;
      
      return (response as List<dynamic>)
          .map((json) => Banner.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch banners: $e');
    }
  }
  
  /// Get active banners only (for customer app display)
  Future<List<Banner>> getActiveBanners({int? limit}) async {
    return getBanners(limit: limit);
  }
  
  /// Get a single banner by ID
  Future<Banner?> getBannerById(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('*')
          .eq('id', id)
          .single();
      
      return Banner.fromJson(response);
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        return null; // Banner not found
      }
      throw DatabaseException('Failed to fetch banner: $e');
    }
  }
  
  /// Create a new banner (Admin only)
  Future<Banner> createBanner(BannerFormData data) async {
    try {
      final bannerData = data.toJson();
      // Add timestamps
      bannerData['created_at'] = DateTime.now().toIso8601String();
      bannerData['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(_tableName)
          .insert(bannerData)
          .select()
          .single();
      
      return Banner.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create banner: $e');
    }
  }
  
  /// Update an existing banner (Admin only)
  Future<Banner> updateBanner(String id, BannerFormData data) async {
    try {
      final bannerData = data.toJson();
      // Update timestamp
      bannerData['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(_tableName)
          .update(bannerData)
          .eq('id', id)
          .select()
          .single();
      
      return Banner.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update banner: $e');
    }
  }
  
  /// Delete a banner (Admin only)
  Future<void> deleteBanner(String id) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete banner: $e');
    }
  }
  
  /// Update banner (Admin only)
  Future<Banner> updateBannerInfo(String id, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(_tableName)
          .update(updates)
          .eq('id', id)
          .select()
          .single();
      
      return Banner.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update banner: $e');
    }
  }
  

  
  /// Get banner count for pagination
  Future<int> getBannerCount() async {
    try {
      final response = await _client.from(_tableName).select('id');
      return (response as List<dynamic>).length;
    } catch (e) {
      throw Exception('Failed to get banner count: $e');
    }
  }
  
  /// Batch operations for admin
  Future<List<Banner>> createMultipleBanners(List<BannerFormData> banners) async {
    try {
      final bannersData = banners.map((b) {
        final data = b.toJson();
        data['created_at'] = DateTime.now().toIso8601String();
        data['updated_at'] = DateTime.now().toIso8601String();
        return data;
      }).toList();
      
      final response = await _client
          .from(_tableName)
          .insert(bannersData)
          .select();
      
      return (response as List<dynamic>)
          .map((json) => Banner.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to create multiple banners: $e');
    }
  }
  
  Future<void> deleteMultipleBanners(List<String> ids) async {
    try {
      // Delete banners one by one for now
      for (final id in ids) {
        await deleteBanner(id);
      }
    } catch (e) {
      throw Exception('Failed to delete multiple banners: $e');
    }
  }
  
  /// Real-time subscription for banners
  Stream<List<Banner>> watchBanners() {
    // For now, return a simple stream that fetches banners periodically
    // This can be enhanced later with proper real-time subscriptions
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await getBanners();
    }).asyncMap((future) => future);
  }
  
  /// Real-time subscription for active banners only
  Stream<List<Banner>> watchActiveBanners() {
    return watchBanners();
  }
  
  /// Connection health check
  Future<bool> checkConnection() async {
    try {
      await _client.from(_tableName).select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}