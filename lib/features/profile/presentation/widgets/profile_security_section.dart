import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileSecuritySection extends ConsumerWidget {
  const ProfileSecuritySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'Password & Authentication',
            icon: Icons.lock,
            children: [
              _buildSecurityOption(
                icon: Icons.password,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () => _showChangePasswordDialog(context),
              ),
              const Divider(),
              _buildSecurityOption(
                icon: Icons.security,
                title: 'Two-Factor Authentication',
                subtitle: 'Add an extra layer of security',
                trailing: Switch(
                  value: false, // This would come from user settings
                  onChanged: (value) {
                    // Implement 2FA toggle
                  },
                  activeColor: AppColors.primary,
                ),
                onTap: null,
              ),
              const Divider(),
              _buildSecurityOption(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                subtitle: 'Use fingerprint or face ID to login',
                trailing: Switch(
                  value: true, // This would come from user settings
                  onChanged: (value) {
                    // Implement biometric toggle
                  },
                  activeColor: AppColors.primary,
                ),
                onTap: null,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSectionCard(
            title: 'Account Security',
            icon: Icons.shield,
            children: [
              _buildSecurityOption(
                icon: Icons.devices,
                title: 'Active Sessions',
                subtitle: 'Manage your active login sessions',
                onTap: () => _showActiveSessionsDialog(context),
              ),
              const Divider(),
              _buildSecurityOption(
                icon: Icons.history,
                title: 'Login History',
                subtitle: 'View your recent login activity',
                onTap: () => _showLoginHistoryDialog(context),
              ),
              const Divider(),
              _buildSecurityOption(
                icon: Icons.email,
                title: 'Email Verification',
                subtitle: 'Verify your email address',
                trailing: const Icon(
                  Icons.verified,
                  color: Colors.green,
                ),
                onTap: null,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSectionCard(
            title: 'Privacy & Data',
            icon: Icons.privacy_tip,
            children: [
              _buildSecurityOption(
                icon: Icons.download,
                title: 'Download My Data',
                subtitle: 'Get a copy of your personal data',
                onTap: () => _showDownloadDataDialog(context),
              ),
              const Divider(),
              _buildSecurityOption(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                titleColor: Colors.red,
                onTap: () => _showDeleteAccountDialog(context),
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

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement password change logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Sessions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSessionItem('Current Device', 'Chrome on Windows', true),
            const Divider(),
            _buildSessionItem('Mobile App', 'iPhone 12', false),
            const Divider(),
            _buildSessionItem('Web Browser', 'Safari on Mac', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement logout from all devices
              Navigator.pop(context);
            },
            child: const Text('Logout All'),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(String device, String details, bool isCurrent) {
    return Row(
      children: [
        Icon(
          isCurrent ? Icons.smartphone : Icons.computer,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                details,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Current',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          TextButton(
            onPressed: () {
              // Implement logout from specific device
            },
            child: const Text('Logout'),
          ),
      ],
    );
  }

  void _showLoginHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login History'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLoginHistoryItem('Today, 2:30 PM', 'Chrome on Windows', true),
              _buildLoginHistoryItem('Yesterday, 9:15 AM', 'Mobile App', true),
              _buildLoginHistoryItem('2 days ago, 6:45 PM', 'Safari on Mac', true),
              _buildLoginHistoryItem('3 days ago, 11:20 AM', 'Unknown Device', false),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginHistoryItem(String time, String device, bool isSuccessful) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isSuccessful ? Icons.check_circle : Icons.error,
            color: isSuccessful ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  device,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download My Data'),
        content: const Text(
          'We\'ll prepare a copy of your personal data and send it to your email address. This may take a few minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export request submitted. You\'ll receive an email shortly.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement account deletion logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}