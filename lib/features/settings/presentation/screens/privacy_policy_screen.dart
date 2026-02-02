import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://sites.google.com/view/wealth-store-policies/privacy-policy');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last Updated: November 14, 2025',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Introduction',
              'Wealth Store is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),
            _buildSection(
              'Information We Collect',
              'Personal Information:\n'
              '• Account Information: Email, name, password (encrypted)\n'
              '• Profile Information: Display name, profile picture (optional)\n'
              '• Contact Information: Phone number (optional)\n\n'
              'Transaction Information:\n'
              '• Order History: Products purchased, order dates, amounts\n'
              '• Payment Information: Processed securely through Paystack\n'
              '• Shipping Address: Delivery addresses\n\n'
              'Automatically Collected:\n'
              '• Device Information: Device type, OS, identifiers\n'
              '• Usage Data: App features used, interaction patterns\n'
              '• Location Data: Approximate location for delivery',
            ),
            _buildSection(
              'How We Use Your Information',
              '1. Provide Services: Process orders, manage accounts, deliver products\n'
              '2. Improve Experience: Personalize content and features\n'
              '3. Communication: Send updates, offers, and support\n'
              '4. Security: Detect and prevent fraud and abuse\n'
              '5. Analytics: Understand usage patterns\n'
              '6. Legal Compliance: Comply with legal obligations',
            ),
            _buildSection(
              'Data Security',
              'Security Measures:\n'
              '• Encryption: All data transmitted via SSL/TLS\n'
              '• Secure Storage: Passwords hashed and salted\n'
              '• Access Control: Limited access on need-to-know basis\n'
              '• Regular Audits: Periodic security assessments\n\n'
              'Data Retention:\n'
              '• Active accounts: Data retained while active\n'
              '• Inactive accounts: May be deleted after 2 years\n'
              '• Deletion requests: Available at any time',
            ),
            _buildSection(
              'Third-Party Services',
              'Supabase (Backend & Authentication):\n'
              '• Purpose: User authentication, database, storage\n'
              '• Data Shared: Email, encrypted passwords, profile data\n\n'
              'Paystack (Payment Processing):\n'
              '• Purpose: Secure payment processing\n'
              '• Data Shared: Payment card details, transaction amounts\n\n'
              'Google Play Services:\n'
              '• Purpose: App distribution and updates\n'
              '• Data Shared: Device information, usage statistics',
            ),
            _buildSection(
              'Your Rights',
              '1. Access: Request a copy of your personal data\n'
              '2. Correction: Update or correct inaccurate information\n'
              '3. Deletion: Request deletion of your account and data\n'
              '4. Portability: Receive your data in machine-readable format\n'
              '5. Opt-Out: Unsubscribe from marketing communications\n'
              '6. Withdraw Consent: Revoke permissions for camera, location, etc.',
            ),
            _buildSection(
              'Contact Us',
              'Email: wealthstores@gmail.com\n'
              'Data Protection Officer: lordkingman360@gmail.com',
            ),
            _buildSection(
              'Compliance',
              'This Privacy Policy complies with:\n'
              '• General Data Protection Regulation (GDPR)\n'
              '• California Consumer Privacy Act (CCPA)\n'
              '• Nigeria Data Protection Regulation (NDPR)\n'
              '• Google Play Store Privacy Requirements',
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _launchPrivacyPolicy,
                icon: const Icon(Icons.open_in_new),
                label: const Text('View Full Privacy Policy'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
