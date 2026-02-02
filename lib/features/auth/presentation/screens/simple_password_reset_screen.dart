import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/services/auth_service.dart';
import 'package:wealth_app/shared/widgets/custom_button.dart';

/// Simple password reset screen that sends a magic link
/// User clicks link in email which opens the app to set new password
class SimplePasswordResetScreen extends StatefulWidget {
  final String email;

  const SimplePasswordResetScreen({
    super.key,
    required this.email,
  });

  @override
  State<SimplePasswordResetScreen> createState() => _SimplePasswordResetScreenState();
}

class _SimplePasswordResetScreenState extends State<SimplePasswordResetScreen> {
  bool _emailSent = false;
  bool _isLoading = false;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _sendResetEmail();
  }

  Future<void> _sendResetEmail() async {
    setState(() => _isLoading = true);

    try {
      await AuthService.resetPassword(widget.email);
      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
      _startResendCountdown();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _resendCountdown > 0) {
        setState(() => _resendCountdown--);
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _emailSent 
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _emailSent ? Icons.mark_email_read : Icons.email_outlined,
                  size: 60,
                  color: _emailSent ? AppColors.success : AppColors.primary,
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              // Title
              Text(
                _emailSent ? 'Check Your Email' : 'Sending Reset Link...',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Description
              if (_emailSent) ...[
                Text(
                  'We\'ve sent a password reset link to:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSpacing.xs),
                
                Text(
                  widget.email,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Instructions
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Next Steps:',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildStep('1', 'Open your email inbox'),
                      _buildStep('2', 'Click the reset password link'),
                      _buildStep('3', 'Set your new password'),
                      _buildStep('4', 'Log in with your new password'),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Link expires in 1 hour',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.orange.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Resend Button
                if (_resendCountdown > 0)
                  Text(
                    'Resend link in ${_resendCountdown}s',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: _isLoading ? null : _sendResetEmail,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Resend Reset Link'),
                  ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Back to Login
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/auth'),
                    child: const Text('Back to Login'),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Troubleshooting
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Didn\'t receive the email?'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTip('Check your spam/junk folder'),
                            _buildTip('Make sure the email address is correct'),
                            _buildTip('Wait a few minutes for the email to arrive'),
                            _buildTip('Check your internet connection'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Didn\'t receive the email?'),
                ),
              ] else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              tip,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
