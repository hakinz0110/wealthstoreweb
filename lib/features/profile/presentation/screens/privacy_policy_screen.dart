import 'package:flutter/material.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            _buildSection(
              context,
              'Introduction',
              'Welcome to Wealth Store. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you visit our app and tell you about your privacy rights.',
            ),
            
            _buildSection(
              context,
              'Information We Collect',
              'We collect and process the following data:\n\n'
              '• Personal identification information (Name, email address, phone number)\n'
              '• Billing and shipping addresses\n'
              '• Payment information (processed securely through our payment providers)\n'
              '• Order history and preferences\n'
              '• Device information and usage data',
            ),
            
            _buildSection(
              context,
              'How We Use Your Information',
              'We use your information to:\n\n'
              '• Process your orders and manage your account\n'
              '• Communicate with you about your orders\n'
              '• Improve our services and user experience\n'
              '• Send you marketing communications (with your consent)\n'
              '• Comply with legal obligations',
            ),
            
            _buildSection(
              context,
              'Data Security',
              'We implement appropriate security measures to protect your personal information. Your data is stored securely using industry-standard encryption and security protocols.',
            ),
            
            _buildSection(
              context,
              'Your Rights',
              'You have the right to:\n\n'
              '• Access your personal data\n'
              '• Correct inaccurate data\n'
              '• Request deletion of your data\n'
              '• Object to processing of your data\n'
              '• Data portability\n'
              '• Withdraw consent at any time',
            ),
            
            _buildSection(
              context,
              'Cookies and Tracking',
              'We use cookies and similar tracking technologies to track activity on our app and hold certain information. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent.',
            ),
            
            _buildSection(
              context,
              'Third-Party Services',
              'We may employ third-party companies and individuals to facilitate our service, provide the service on our behalf, or assist us in analyzing how our service is used. These third parties have access to your personal data only to perform these tasks on our behalf.',
            ),
            
            _buildSection(
              context,
              'Children\'s Privacy',
              'Our service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13.',
            ),
            
            _buildSection(
              context,
              'Changes to This Privacy Policy',
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
            ),
            
            _buildSection(
              context,
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us:\n\n'
              'Email: support@wealthstore.com',
            ),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
