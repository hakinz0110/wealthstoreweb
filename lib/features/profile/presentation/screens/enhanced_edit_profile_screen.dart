import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/features/profile/data/user_profile_repository.dart';
import 'package:wealth_app/shared/widgets/custom_button.dart';
import 'package:wealth_app/shared/widgets/custom_text_field.dart';
import 'package:wealth_app/shared/widgets/profile_image_picker.dart';

class EnhancedEditProfileScreen extends ConsumerStatefulWidget {
  const EnhancedEditProfileScreen({super.key});

  @override
  ConsumerState<EnhancedEditProfileScreen> createState() => _EnhancedEditProfileScreenState();
}

class _EnhancedEditProfileScreenState extends ConsumerState<EnhancedEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  String _selectedLanguage = 'en';
  String _selectedCurrency = 'USD';
  
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _marketingEmails = true;
  
  bool _isLoading = false;
  UserProfile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    try {
      final profile = await ref.read(userProfileRepositoryProvider).getCurrentUserProfile()
          .timeout(const Duration(seconds: 10));
      
      if (mounted) {
        setState(() {
          if (profile != null) {
            _currentProfile = profile;
            _nameController.text = profile.fullName ?? '';
            _phoneController.text = profile.phone ?? '';
            _selectedGender = profile.gender;
            _selectedDateOfBirth = profile.dateOfBirth;
            _selectedLanguage = profile.preferredLanguage;
            _selectedCurrency = profile.preferredCurrency;
            _emailNotifications = profile.emailNotifications;
            _smsNotifications = profile.smsNotifications;
            _pushNotifications = profile.pushNotifications;
            _marketingEmails = profile.marketingEmails;
          } else {
            // Create a default profile if none exists
            _currentProfile = UserProfile(
              id: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Create a default profile on error
        setState(() {
          _currentProfile = UserProfile(
            id: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Update profile information
      await ref.read(userProfileRepositoryProvider).updateProfile(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDateOfBirth,
        preferredLanguage: _selectedLanguage,
        preferredCurrency: _selectedCurrency,
      );

      // Update notification preferences
      await ref.read(userProfileRepositoryProvider).updateNotificationPreferences(
        emailNotifications: _emailNotifications,
        smsNotifications: _smsNotifications,
        pushNotifications: _pushNotifications,
        marketingEmails: _marketingEmails,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _currentProfile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    _buildProfilePictureSection(),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Personal Information Section
                    _buildSectionHeader('Personal Information'),
                    _buildPersonalInfoSection(),
                    
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // Save Button
                    CustomButton(
                      text: 'Save Changes',
                      isLoading: _isLoading,
                      onPressed: _saveProfile,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: ProfileImagePicker(
        currentImageUrl: _currentProfile?.avatarUrl,
        radius: 60,
        onImageChanged: (imageUrl) {
          // Update the current profile state
          if (_currentProfile != null) {
            setState(() {
              _currentProfile = _currentProfile!.copyWith(avatarUrl: imageUrl);
            });
          }
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      children: [
        CustomTextField(
          controller: _nameController,
          labelText: 'Full Name',
          hintText: 'Enter your full name',
          prefixIcon: const Icon(Icons.person_outline),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        CustomTextField(
          controller: _phoneController,
          labelText: 'Phone Number',
          hintText: 'Enter your phone number',
          prefixIcon: const Icon(Icons.phone_outlined),
          keyboardType: TextInputType.phone,
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Gender Dropdown
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: const InputDecoration(
            labelText: 'Gender',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Male')),
            DropdownMenuItem(value: 'female', child: Text('Female')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
            DropdownMenuItem(value: 'prefer_not_to_say', child: Text('Prefer not to say')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Date of Birth
        InkWell(
          onTap: _selectDateOfBirth,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              border: OutlineInputBorder(),
            ),
            child: Text(
              _selectedDateOfBirth != null
                  ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                  : 'Select date of birth',
              style: TextStyle(
                color: _selectedDateOfBirth != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      children: [
        // Language Dropdown
        DropdownButtonFormField<String>(
          value: _selectedLanguage,
          decoration: const InputDecoration(
            labelText: 'Preferred Language',
            prefixIcon: Icon(Icons.language_outlined),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'es', child: Text('Spanish')),
            DropdownMenuItem(value: 'fr', child: Text('French')),
            DropdownMenuItem(value: 'de', child: Text('German')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedLanguage = value!;
            });
          },
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Currency Dropdown
        DropdownButtonFormField<String>(
          value: _selectedCurrency,
          decoration: const InputDecoration(
            labelText: 'Preferred Currency',
            prefixIcon: Icon(Icons.attach_money_outlined),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
            DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
            DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound')),
            DropdownMenuItem(value: 'NGN', child: Text('NGN - Nigerian Naira')),
            DropdownMenuItem(value: 'CAD', child: Text('CAD - Canadian Dollar')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCurrency = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Email Notifications'),
          subtitle: const Text('Receive order updates via email'),
          value: _emailNotifications,
          onChanged: (value) {
            setState(() {
              _emailNotifications = value;
            });
          },
          activeColor: AppColors.primary,
        ),
        
        SwitchListTile(
          title: const Text('SMS Notifications'),
          subtitle: const Text('Receive order updates via SMS'),
          value: _smsNotifications,
          onChanged: (value) {
            setState(() {
              _smsNotifications = value;
            });
          },
          activeColor: AppColors.primary,
        ),
        
        SwitchListTile(
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive app notifications'),
          value: _pushNotifications,
          onChanged: (value) {
            setState(() {
              _pushNotifications = value;
            });
          },
          activeColor: AppColors.primary,
        ),
        
        SwitchListTile(
          title: const Text('Marketing Emails'),
          subtitle: const Text('Receive promotional offers and news'),
          value: _marketingEmails,
          onChanged: (value) {
            setState(() {
              _marketingEmails = value;
            });
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}