import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/profile_notifier.dart';

class ProfilePreferencesSection extends ConsumerStatefulWidget {
  const ProfilePreferencesSection({super.key});

  @override
  ConsumerState<ProfilePreferencesSection> createState() => _ProfilePreferencesSectionState();
}

class _ProfilePreferencesSectionState extends ConsumerState<ProfilePreferencesSection> {
  String _selectedTheme = 'system';
  String _selectedLanguage = 'en';
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  bool _marketingEmails = false;
  bool _orderUpdates = true;
  bool _promotionalOffers = true;

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final preferences = profileState.customer?.preferences;

    // Load preferences from customer data
    if (preferences != null) {
      _selectedTheme = preferences['theme'] ?? 'system';
      _selectedLanguage = preferences['language'] ?? 'en';
      _emailNotifications = preferences['emailNotifications'] ?? true;
      _pushNotifications = preferences['pushNotifications'] ?? true;
      _smsNotifications = preferences['smsNotifications'] ?? false;
      _marketingEmails = preferences['marketingEmails'] ?? false;
      _orderUpdates = preferences['orderUpdates'] ?? true;
      _promotionalOffers = preferences['promotionalOffers'] ?? true;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'Appearance',
            icon: Icons.palette,
            children: [
              _buildDropdownPreference(
                title: 'Theme',
                subtitle: 'Choose your preferred theme',
                value: _selectedTheme,
                items: const [
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                  DropdownMenuItem(value: 'system', child: Text('System Default')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  _updatePreferences();
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSectionCard(
            title: 'Language & Region',
            icon: Icons.language,
            children: [
              _buildDropdownPreference(
                title: 'Language',
                subtitle: 'Select your preferred language',
                value: _selectedLanguage,
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
                  _updatePreferences();
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSectionCard(
            title: 'Notifications',
            icon: Icons.notifications,
            children: [
              _buildSwitchPreference(
                title: 'Email Notifications',
                subtitle: 'Receive notifications via email',
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                  _updatePreferences();
                },
              ),
              _buildSwitchPreference(
                title: 'Push Notifications',
                subtitle: 'Receive push notifications on your device',
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                  _updatePreferences();
                },
              ),
              _buildSwitchPreference(
                title: 'SMS Notifications',
                subtitle: 'Receive notifications via SMS',
                value: _smsNotifications,
                onChanged: (value) {
                  setState(() {
                    _smsNotifications = value;
                  });
                  _updatePreferences();
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSectionCard(
            title: 'Marketing & Communications',
            icon: Icons.campaign,
            children: [
              _buildSwitchPreference(
                title: 'Marketing Emails',
                subtitle: 'Receive promotional emails and newsletters',
                value: _marketingEmails,
                onChanged: (value) {
                  setState(() {
                    _marketingEmails = value;
                  });
                  _updatePreferences();
                },
              ),
              _buildSwitchPreference(
                title: 'Order Updates',
                subtitle: 'Receive updates about your orders',
                value: _orderUpdates,
                onChanged: (value) {
                  setState(() {
                    _orderUpdates = value;
                  });
                  _updatePreferences();
                },
              ),
              _buildSwitchPreference(
                title: 'Promotional Offers',
                subtitle: 'Get notified about special deals and offers',
                value: _promotionalOffers,
                onChanged: (value) {
                  setState(() {
                    _promotionalOffers = value;
                  });
                  _updatePreferences();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchPreference({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownPreference<T>({
    required String title,
    required String subtitle,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updatePreferences() {
    final preferences = {
      'theme': _selectedTheme,
      'language': _selectedLanguage,
      'emailNotifications': _emailNotifications,
      'pushNotifications': _pushNotifications,
      'smsNotifications': _smsNotifications,
      'marketingEmails': _marketingEmails,
      'orderUpdates': _orderUpdates,
      'promotionalOffers': _promotionalOffers,
    };

    // Update preferences through the profile notifier
    // This would be implemented in the profile repository
    ref.read(profileNotifierProvider.notifier).updateUserPreferences(preferences);
  }
}