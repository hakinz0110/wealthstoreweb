import 'package:flutter/material.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
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
              'Agreement to Terms',
              'By accessing and using Wealth Store, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these terms, please do not use our service.',
            ),
            
            _buildSection(
              context,
              'Use of Service',
              'You agree to use our service only for lawful purposes and in accordance with these Terms. You agree not to:\n\n'
              '• Use the service in any way that violates any applicable law or regulation\n'
              '• Impersonate or attempt to impersonate the company or another user\n'
              '• Engage in any conduct that restricts or inhibits anyone\'s use of the service\n'
              '• Use any automated system to access the service',
            ),
            
            _buildSection(
              context,
              'Account Registration',
              'To use certain features of our service, you must register for an account. You agree to:\n\n'
              '• Provide accurate and complete information\n'
              '• Maintain the security of your password\n'
              '• Accept responsibility for all activities under your account\n'
              '• Notify us immediately of any unauthorized use',
            ),
            
            _buildSection(
              context,
              'Orders and Payments',
              'All orders are subject to acceptance and availability. We reserve the right to refuse any order. Prices are subject to change without notice. Payment must be received before order processing.',
            ),
            
            _buildSection(
              context,
              'Shipping and Delivery',
              'We will make every effort to deliver products within the estimated timeframe. However, we are not responsible for delays caused by circumstances beyond our control.',
            ),
            
            _buildSection(
              context,
              'Returns and Refunds',
              'Our return policy allows returns within 30 days of purchase for most items. Items must be in original condition. Refunds will be processed within 7-14 business days after receiving the returned item.',
            ),
            
            _buildSection(
              context,
              'Intellectual Property',
              'The service and its original content, features, and functionality are owned by Wealth Store and are protected by international copyright, trademark, and other intellectual property laws.',
            ),
            
            _buildSection(
              context,
              'Limitation of Liability',
              'In no event shall Wealth Store be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the service.',
            ),
            
            _buildSection(
              context,
              'Termination',
              'We may terminate or suspend your account and access to the service immediately, without prior notice, for any reason, including breach of these Terms.',
            ),
            
            _buildSection(
              context,
              'Changes to Terms',
              'We reserve the right to modify these terms at any time. We will notify users of any material changes. Your continued use of the service after changes constitutes acceptance of the new terms.',
            ),
            
            _buildSection(
              context,
              'Contact Information',
              'For questions about these Terms, please contact us:\n\n'
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
