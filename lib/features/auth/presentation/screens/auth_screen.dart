import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_assets.dart';
import 'package:wealth_app/core/utils/input_validators.dart';
import 'package:wealth_app/features/auth/domain/auth_notifier.dart';
import 'package:wealth_app/features/auth/presentation/screens/forgot_password_screen.dart';


class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  DateTime? _dateOfBirth;
  String? _gender;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    try {
      if (_isLogin) {
        await ref.read(authNotifierProvider.notifier).signIn(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await ref.read(authNotifierProvider.notifier).signUp(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          dateOfBirth: _dateOfBirth,
          gender: _gender,
        );
      }
      
      final authState = ref.read(authNotifierProvider);
      
      if (authState.isAuthenticated) {
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  

  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final error = authState.error;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light background like admin
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: AppAssets.logoUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (context, url, error) {
                                  debugPrint('Error loading logo: $error');
                                  return const Center(
                                    child: Text(
                                      'T',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Welcome text
                        Text(
                          _isLogin ? 'Welcome back.' : 'Create Account',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          _isLogin 
                              ? 'Discover Limitless Choices and Unmatched Convenience'
                              : 'Join us and start shopping today',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Toggle between login and register
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => setState(() => _isLogin = true),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: _isLogin ? AppColors.primary : const Color(0xFF6B7280),
                                  fontWeight: _isLogin ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            const Text(' | '),
                            TextButton(
                              onPressed: () => setState(() => _isLogin = false),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: !_isLogin ? AppColors.primary : const Color(0xFF6B7280),
                                  fontWeight: !_isLogin ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Error message
                        if (error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: AppColors.error, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    error,
                                    style: TextStyle(color: AppColors.error, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().slideY(
                                begin: -0.2,
                                end: 0,
                                duration: 300.ms,
                              ).fadeIn(),
                        
                        if (error != null) const SizedBox(height: 16),
                        
                        // Form fields
                        if (!_isLogin) ...[
                          // Full name field for registration
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            enabled: !isLoading,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Full name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Phone field
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            enabled: !isLoading,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Gender dropdown
                          DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            items: ['Male', 'Female', 'Other', 'Prefer not to say']
                                .map((gender) => DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender),
                                    ))
                                .toList(),
                            onChanged: isLoading ? null : (value) {
                              setState(() => _gender = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Date of Birth
                          InkWell(
                            onTap: isLoading ? null : () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dateOfBirth ?? DateTime(2000),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => _dateOfBirth = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date of Birth',
                                prefixIcon: Icon(Icons.calendar_today_outlined),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _dateOfBirth != null
                                    ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                    : 'Select date',
                                style: TextStyle(
                                  color: _dateOfBirth != null ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: 'E-Mail',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: InputValidators.validateEmail,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          enabled: !isLoading,
                          onFieldSubmitted: (_) => _submitForm(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword 
                                    ? Icons.visibility_outlined 
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: InputValidators.validatePassword,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Remember me and forgot password row (only for login)
                        if (_isLogin)
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: isLoading ? null : (value) {
                                  setState(() => _rememberMe = value ?? false);
                                },
                                activeColor: AppColors.primary,
                              ),
                              const Text('Remember Me'),
                              const Spacer(),
                              TextButton(
                                onPressed: isLoading ? null : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        
                        if (_isLogin) const SizedBox(height: 24),
                        if (!_isLogin) const SizedBox(height: 16),
                        
                        // Terms and conditions for registration
                        if (!_isLogin)
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: const Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'By registering, you agree to our Terms of Service and Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        
                        if (!_isLogin) const SizedBox(height: 24),
                        
                        // Sign in/up button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    _isLogin ? 'Sign In' : 'Create Account',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Privacy Policy and Terms links
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              'By continuing, you agree to our ',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/terms-of-service'),
                              child: Text(
                                'Terms of Service',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(
                              ' and ',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/privacy-policy'),
                              child: Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}