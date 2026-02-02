import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/features/profile/data/profile_repository.dart';
import 'package:wealth_app/features/profile/domain/profile_notifier.dart';

class ProfileImagePicker extends ConsumerStatefulWidget {
  final String? currentImageUrl;
  final Function(String?)? onImageChanged;
  final double radius;

  const ProfileImagePicker({
    super.key,
    this.currentImageUrl,
    this.onImageChanged,
    this.radius = 60,
  });

  @override
  ConsumerState<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends ConsumerState<ProfileImagePicker> {
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isUploading = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.currentImageUrl;
  }

  ImageProvider? _getImageProvider() {
    if (kIsWeb && _selectedImageBytes != null) {
      return MemoryImage(_selectedImageBytes!);
    } else if (!kIsWeb && _selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_currentImageUrl != null) {
      return CachedNetworkImageProvider(_currentImageUrl!);
    }
    return null;
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show options dialog
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes; // Always store bytes for cross-platform
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
        });
        
        await _uploadImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null && _selectedImageBytes == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      print('🔄 Starting image upload...');
      final user = SupabaseService.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      print('✅ User authenticated: ${user.id}');

      // Upload image directly to storage
      final supabaseClient = ref.read(supabaseProvider);
      final fileName = 'profile-images/${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Always use bytes for cross-platform consistency
      Uint8List? uploadBytes = _selectedImageBytes;
      
      // On mobile, read bytes from file if not already available
      if (uploadBytes == null && _selectedImage != null) {
        print('📱 Reading bytes from file: ${_selectedImage!.path}');
        uploadBytes = await _selectedImage!.readAsBytes();
      }
      
      if (uploadBytes == null) {
        throw Exception('No image selected');
      }
      
      print('📤 Uploading ${uploadBytes.length} bytes...');
      await supabaseClient.storage
          .from('app-storage')
          .uploadBinary(fileName, uploadBytes);
      
      // Get the public URL
      final imageUrl = supabaseClient.storage
          .from('app-storage')
          .getPublicUrl(fileName);

      print('✅ Image uploaded to storage: $imageUrl');

      // Update the user_profiles table directly with the avatar_url
      print('🔄 Updating user profile...');
      await supabaseClient
          .from('user_profiles')
          .update({'avatar_url': imageUrl})
          .eq('id', user.id);

      print('✅ User profile updated');

      // Refresh the profile to get the updated data
      print('🔄 Refreshing profile...');
      await ref.read(profileNotifierProvider.notifier).refreshProfile();
      print('✅ Profile refreshed');

      setState(() {
        _currentImageUrl = imageUrl;
        _selectedImage = null;
        _selectedImageBytes = null;
      });

      // Notify parent widget
      widget.onImageChanged?.call(imageUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      print('❌ Upload failed: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _removeImage() async {
    try {
      // Update profile to remove image URL
      await ref.read(profileNotifierProvider.notifier).updateProfileImage('');

      setState(() {
        _currentImageUrl = null;
        _selectedImage = null;
        _selectedImageBytes = null;
      });

      // Notify parent widget
      widget.onImageChanged?.call(null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image removed'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              if (_currentImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeImage();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes; // Always store bytes for cross-platform
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
        });
        
        await _uploadImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUploading ? null : _showImageOptions,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: widget.radius,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: _isUploading ? null : _getImageProvider(),
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : _selectedImage == null && _selectedImageBytes == null && _currentImageUrl == null
                      ? Icon(
                          Icons.person,
                          size: widget.radius,
                          color: Colors.grey.shade600,
                    )
                  : null,
            ),
          ),
          
          // Loading indicator
          if (_isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          
          // Edit button
          if (!_isUploading)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Simple profile image picker for smaller use cases
class SimpleProfileImagePicker extends ConsumerWidget {
  final String? currentImageUrl;
  final Function(String?)? onImageChanged;
  final double size;

  const SimpleProfileImagePicker({
    super.key,
    this.currentImageUrl,
    this.onImageChanged,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileImagePicker(
      currentImageUrl: currentImageUrl,
      onImageChanged: onImageChanged,
      radius: size / 2,
    );
  }
}