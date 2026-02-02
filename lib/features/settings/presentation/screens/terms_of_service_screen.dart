import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  Future<void> _launchTerms() async {
    final Uri url = Uri.parse('https://sites.google.com/view/wealth-store-policies/terms-of-service');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last Updated: November 14, 2025',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using Wealth Store mobile application, you accept and agree to be bound by these Terms of Service. If you do not agree to these Terms, please do not use the App.',
            ),
            _buildSection(
              '2. Description of Service',
              'Wealth Store is an e-commerce platform that allows users to:\n'
              '• Browse and purchase products\n'
              '• Create and manage user accounts\n'
              '• Track orders and delivery status\n'
              '• Leave product reviews and ratings\n'
              '• Receive promotional offers and updates',
            ),
            _buildSection(
              '3. User Accounts',
              'Account Creation:\n'
              '• Provide accurate and complete information\n'
              '• Must be at least 13 years old\n'
              '• Maintain account security\n'
              '• Notify us of unauthorized access\n\n'
              'Account Responsibilities:\n'
              '• Keep password confidential\n'
              '• Responsible for all account activities\n'
              '• Do not share account with others',
            ),
            _buildSection(
              '4. Orders and Payments',
              'Product Information:\n'
              '• Prices subject to change without notice\n'
              '• Product images for illustration only\n'
              '• We reserve right to limit quantities\n\n'
              'Payment Processing:\n'
              '• Payments processed securely via Paystack\n'
              '• All prices in Nigerian Naira (NGN)\n'
              '• You are responsible for applicable taxes\n\n'
              'Refunds and Returns:\n'
              '• Defective products may be returned within 7 days\n'
              '• Refunds processed within 14 business days\n'
              '• Original payment method will be credited',
            ),
            _buildSection(
              '5. User Conduct',
              'You agree NOT to:\n'
              '• Violate any laws or regulations\n'
              '• Infringe on intellectual property rights\n'
              '• Upload malicious code or viruses\n'
              '• Harass, abuse, or harm other users\n'
              '• Impersonate any person or entity\n'
              '• Collect user information without consent\n'
              '• Attempt to gain unauthorized access\n'
              '• Interfere with proper functioning of the App',
            ),
            _buildSection(
              '6. Intellectual Property',
              'Our Rights:\n'
              '• All content, trademarks, and logos are our property\n'
              '• App and content protected by copyright\n'
              '• May not copy, modify, or distribute without permission\n\n'
              'User Content:\n'
              '• You retain ownership of content you upload\n'
              '• You grant us license to use and distribute your content\n'
              '• We may remove content that violates these Terms',
            ),
            _buildSection(
              '7. Privacy and Data Protection',
              '• Your use is subject to our Privacy Policy\n'
              '• We collect and process data as described in Privacy Policy\n'
              '• You consent to data collection and processing\n'
              '• We implement security measures to protect your data',
            ),
            _buildSection(
              '8. Disclaimers',
              'Service Availability:\n'
              '• App provided "as is" and "as available"\n'
              '• No guarantee of uninterrupted service\n'
              '• May modify or discontinue features without notice\n\n'
              'Product Warranties:\n'
              '• Products sold with manufacturer warranties where applicable\n'
              '• Not responsible for manufacturer defects\n'
              '• No warranties beyond those explicitly stated',
            ),
            _buildSection(
              '9. Limitation of Liability',
              'To the maximum extent permitted by law:\n'
              '• Not liable for indirect, incidental, or consequential damages\n'
              '• Total liability shall not exceed amount you paid for products\n'
              '• Not responsible for third-party actions or content\n'
              '• Not liable for losses due to service interruptions',
            ),
            _buildSection(
              '10. Delivery and Shipping',
              '• Delivery times are estimates and not guaranteed\n'
              '• Risk of loss passes to you upon delivery\n'
              '• You must provide accurate delivery information\n'
              '• Not responsible for delays beyond our control\n'
              '• Additional charges may apply for remote locations',
            ),
            _buildSection(
              '11. Dispute Resolution',
              'Governing Law:\n'
              '• These Terms are governed by Nigerian law\n'
              '• Disputes shall be resolved in Nigerian courts\n\n'
              'Arbitration:\n'
              '• Disputes may be resolved through arbitration\n'
              '• Arbitration conducted in Lagos, Nigeria\n'
              '• Arbitration decisions are final and binding',
            ),
            _buildSection(
              '12. Contact Information',
              'For questions about these Terms, contact us:\n'
              'Email: wealthstores@gmail.com',
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _launchTerms,
                icon: const Icon(Icons.open_in_new),
                label: const Text('View Full Terms of Service'),
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
              color: Colors.red,
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
