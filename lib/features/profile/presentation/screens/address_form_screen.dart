import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/nigeria_locations.dart';
import 'package:wealth_app/features/profile/domain/profile_notifier.dart';
import 'package:wealth_app/shared/models/address.dart';
import 'package:wealth_app/shared/widgets/base_screen.dart';
import 'package:wealth_app/shared/widgets/custom_button.dart';
import 'package:wealth_app/shared/widgets/custom_text_field.dart';

class AddressFormScreen extends ConsumerStatefulWidget {
  final int? addressId;
  
  const AddressFormScreen({
    super.key,
    this.addressId,
  });

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _phoneController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  String? _selectedState;
  String? _selectedCity;
  bool _isDefault = false;
  bool _isLoading = false;
  Address? _existingAddress;
  List<String> _availableCities = [];

  bool get _isEditing => widget.addressId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAddress();
      });
    }
  }

  Future<void> _loadAddress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final addresses = ref.read(profileNotifierProvider).addresses;
      _existingAddress = addresses.firstWhere((a) => a.id == widget.addressId);
      
      _nameController.text = _existingAddress!.name;
      _streetController.text = _existingAddress!.street;
      _selectedState = _existingAddress!.state;
      _selectedCity = _existingAddress!.city;
      _availableCities = NigeriaLocations.getCities(_selectedState ?? '');
      _phoneController.text = _existingAddress!.phoneNumber ?? '';
      _additionalInfoController.text = _existingAddress!.additionalInfo ?? '';
      _isDefault = _existingAddress!.isDefault;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load address: $e'),
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

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _phoneController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedState == null || _selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select state and city'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_isEditing && _existingAddress != null) {
        await ref.read(profileNotifierProvider.notifier).updateAddress(
          id: _existingAddress!.id,
          name: _nameController.text,
          street: _streetController.text,
          city: _selectedCity!,
          stateRegion: _selectedState!,
          zipCode: '',
          country: 'Nigeria',
          isDefault: _isDefault,
          phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          additionalInfo: _additionalInfoController.text.isNotEmpty ? _additionalInfoController.text : null,
        );
      } else {
        await ref.read(profileNotifierProvider.notifier).createAddress(
          name: _nameController.text,
          street: _streetController.text,
          city: _selectedCity!,
          state: _selectedState!,
          zipCode: '',
          country: 'Nigeria',
          isDefault: _isDefault,
          phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          additionalInfo: _additionalInfoController.text.isNotEmpty ? _additionalInfoController.text : null,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save address: $e'),
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

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final isUpdating = profileState.isUpdating;

    return BaseScreen(
      title: _isEditing ? 'Edit Address' : 'Add Address',
      showBackButton: true,
      body: _isLoading && _isEditing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Address Name',
                      hintText: 'E.g., Home, Work, etc.',
                      prefixIcon: const Icon(Icons.bookmark),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an address name';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSpacing.medium),
                    
                    // Street field
                    CustomTextField(
                      controller: _streetController,
                      labelText: 'Street Address',
                      hintText: 'Enter your street address',
                      prefixIcon: const Icon(Icons.home),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a street address';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSpacing.medium),
                    
                    // State dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedState,
                      decoration: InputDecoration(
                        labelText: 'State/Province',
                        prefixIcon: const Icon(Icons.map),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: NigeriaLocations.states.map((state) {
                        return DropdownMenuItem(
                          value: state,
                          child: Text(state),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedState = value;
                          _selectedCity = null;
                          _availableCities = NigeriaLocations.getCities(value ?? '');
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a state';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSpacing.medium),
                    
                    // City dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: InputDecoration(
                        labelText: 'City',
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _availableCities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a city';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSpacing.medium),
                    
                    // Country field (read-only)
                    CustomTextField(
                      controller: TextEditingController(text: 'Nigeria'),
                      labelText: 'Country',
                      hintText: 'Nigeria',
                      prefixIcon: const Icon(Icons.public),
                      readOnly: true,
                    ),
                    
                    const SizedBox(height: AppSpacing.medium),
                    
                    // Phone field (optional)
                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number (Optional)',
                      hintText: 'Enter phone number for delivery',
                      prefixIcon: const Icon(Icons.phone),
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: AppSpacing.medium),
                    
                    // Additional Info field (optional)
                    CustomTextField(
                      controller: _additionalInfoController,
                      labelText: 'Additional Information (Optional)',
                      hintText: 'Apartment number, building, landmark, etc.',
                      prefixIcon: const Icon(Icons.info),
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: AppSpacing.medium),
                    
                    // Set as default checkbox
                    CheckboxListTile(
                      title: const Text('Set as default address'),
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() {
                          _isDefault = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    
                    const SizedBox(height: AppSpacing.large),
                    
                    // Save button
                    CustomButton(
                      text: 'Save Address',
                      isLoading: _isLoading || isUpdating,
                      onPressed: _saveAddress,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 