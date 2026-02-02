import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../settings/presentation/screens/privacy_policy_screen.dart';
import '../../../settings/presentation/screens/terms_of_service_screen.dart';

class ProfileAboutSection extends ConsumerWidget {
  const ProfileAboutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'App Information',
            icon: Icons.info,
            children: [
              _buildInfoItem('Version', '1.0.0'),
              const Divider(),
              _buildInfoItem('Build Number', '100'),
              const Divider(),
              _buildInfoItem('Last Updated', 'August 2, 2025'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSectionCard(
            title: 'Support & Help',
            icon: Icons.help,
            children: [
              _buildActionItem(
                icon: Icons.help_center,
                title: 'Help Center',
                subtitle: 'Find answers to common questions',
                onTap: () => _launchUrl('https://help.wealthstore.com'),
              ),
              const Divider(),
              _buildActionItem(
                icon: Icons.chat,
                title: 'Contact Support',
                subtitle: 'Get help from our support team',
                onTap: () => _showContactSupportDialog(context),
              ),
              const Divider(),
              _buildActionItem(
                icon: Icons.bug_report,
                title: 'Report a Bug',
                subtitle: 'Help us improve the app',
                onTap: () => _showBugReportDialog(context),
              ),
              const Divider(),
              _buildActionItem(
                icon: Icons.star_rate,
                title: 'Rate the App',
                subtitle: 'Share your feedback on the app store',
                onTap: () => _launchUrl('https://play.google.com/store/apps/details?id=com.wealthstore.shop'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSectionCard(
            title: 'Legal & Policies',
            icon: Icons.gavel,
            children: [
              _buildActionItem(
                icon: Icons.description,
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsOfServiceScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              _buildActionItem(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                subtitle: 'Learn how we protect your data',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSectionCard(
            title: 'Connect With Us',
            icon: Icons.connect_without_contact,
            children: [
              _buildSocialItem(
                icon: Icons.language,
                title: 'Website',
                subtitle: 'Visit our official website',
                onTap: () => _launchUrl('https://wealthstore.com'),
              ),
              const Divider(),
              _buildSocialItem(
                icon: Icons.facebook,
                title: 'Facebook',
                subtitle: 'Follow us on Facebook',
                onTap: () => _launchUrl('https://facebook.com/wealthstore'),
              ),
              const Divider(),
              _buildSocialItem(
                icon: Icons.alternate_email,
                title: 'Twitter',
                subtitle: 'Follow us on Twitter',
                onTap: () => _launchUrl('https://twitter.com/wealthstore'),
              ),
              const Divider(),
              _buildSocialItem(
                icon: Icons.camera_alt,
                title: 'Instagram',
                subtitle: 'Follow us on Instagram',
                onTap: () => _launchUrl('https://instagram.com/wealthstore'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // App Logo and Copyright
          Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Wealth Store',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your trusted shopping companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '© 2025 Wealth Store. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
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

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSocialItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showContactSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose how you\'d like to contact our support team:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              subtitle: const Text('support@wealthstore.com'),
              onTap: () {
                Navigator.pop(context);
                _launchUrl('mailto:support@wealthstore.com');
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone Support'),
              subtitle: const Text('+1 (555) 123-4567'),
              onTap: () {
                Navigator.pop(context);
                _launchUrl('tel:+15551234567');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Live Chat'),
              subtitle: const Text('Available 24/7'),
              onTap: () {
                Navigator.pop(context);
                // Implement live chat functionality
              },
            ),
          ],
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

  void _showBugReportDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Help us improve the app by reporting any bugs you encounter.'),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Describe the bug',
                border: OutlineInputBorder(),
                hintText: 'Please provide as much detail as possible...',
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bug report submitted. Thank you for your feedback!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }
}