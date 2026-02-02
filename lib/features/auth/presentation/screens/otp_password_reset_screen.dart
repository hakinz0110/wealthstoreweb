import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/services/auth_service.dart';
import 'package:wealth_app/shared/widgets/custom_button.dart';
import 'package:wealth_app/features/auth/presentation/screens/new_password_screen.dart';

class OTPPasswordResetScreen extends StatefulWidget {
  final String email;

  const OTPPasswordResetScreen({
    super.key,
    required this.email,
  });

  @override
  State<OTPPasswordResetScreen> createState() => _OTPPasswordResetScreenState();
}

class _OTPPasswordResetScreenState extends State<OTPPasswordResetScreen> {
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  
  bool _isLoading = false;
  String? _errorMessage;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
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

  String _getOTP() {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _verifyOTP() async {
    final otp = _getOTP();
    
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verify OTP and sign in the user
      await AuthService.verifyOTPAndSignIn(
        email: widget.email,
        token: otp,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code verified! Now set your new password.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );
        
        // Navigate to new password screen
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const NewPasswordScreen(),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid or expired code. Please try again.';
      });
    }
  }



  Future<void> _resendOTP() async {
    if (_resendCountdown > 0) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.sendPasswordResetOTP(widget.email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New code sent to your email'),
            backgroundColor: AppColors.success,
          ),
        );
        _startResendCountdown();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend code: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: _buildOTPForm(),
        ),
      ),
    );
  }

  Widget _buildOTPForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpacing.xl),
        
        // Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mail_outline,
            size: 50,
            color: AppColors.primary,
          ),
        ),
        
        const SizedBox(height: AppSpacing.xl),
        
        // Title
        Text(
          'Check Your Email',
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Description
        Text(
          'We\'ve sent a 6-digit verification code to',
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
        
        // OTP Input Fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildOTPField(index)),
        ),
        
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            _errorMessage!,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        
        const SizedBox(height: AppSpacing.xxl),
        
        // Verify Button
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Verify Code',
            onPressed: _isLoading ? null : _verifyOTP,
            isLoading: _isLoading,
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Resend Code
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Didn\'t receive the code? ',
              style: AppTextStyles.bodyMedium,
            ),
            if (_resendCountdown > 0)
              Text(
                'Resend in ${_resendCountdown}s',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey,
                ),
              )
            else
              TextButton(
                onPressed: _isLoading ? null : _resendOTP,
                child: const Text('Resend Code'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildOTPField(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppTextStyles.headlineSmall.copyWith(
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          
          // Auto-verify when all fields are filled
          if (index == 5 && value.isNotEmpty) {
            _verifyOTP();
          }
        },
      ),
    );
  }
}
