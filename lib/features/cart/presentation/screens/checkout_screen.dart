import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/nigeria_locations.dart';
import 'package:wealth_app/core/services/payment/paystack_service.dart';
import 'package:wealth_app/core/utils/currency_utils.dart';
import 'package:wealth_app/features/cart/domain/cart_notifier.dart';
import 'package:wealth_app/features/cart/domain/payment_notifier.dart';
import 'package:wealth_app/features/cart/presentation/widgets/coupon_input_widget.dart';
import 'package:wealth_app/features/orders/domain/order_notifier.dart';
import 'package:wealth_app/shared/models/order.dart';
import 'package:wealth_app/shared/widgets/custom_button.dart';
import 'package:wealth_app/shared/widgets/custom_text_field.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _pageController = PageController();
  
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isLoadingProfile = true;
  String? _errorMessage;
  
  // Form data
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  String? _selectedState;
  String? _selectedCity;
  List<String> _availableCities = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _initializePaystack();
  }

  Future<void> _initializePaystack() async {
    try {
      await PaystackService().initialize();
    } catch (e) {
      debugPrint('Failed to initialize Paystack: $e');
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user != null) {
        // Try to load default address first
        try {
          final addressResponse = await supabase
              .from('addresses')
              .select()
              .eq('user_id', user.id)
              .eq('is_default', true)
              .single();
          
          if (mounted && addressResponse != null) {
            setState(() {
              _fullNameController.text = addressResponse['name'] ?? '';
              _emailController.text = user.email ?? '';
              _phoneController.text = addressResponse['phone_number'] ?? '';
              _addressController.text = addressResponse['street'] ?? '';
              _selectedState = addressResponse['state'];
              _selectedCity = addressResponse['city'];
              _availableCities = NigeriaLocations.getCities(_selectedState ?? '');
              _isLoadingProfile = false;
            });
            return;
          }
        } catch (e) {
          // No default address found, try loading from user profile
        }
        
        // Fallback to user profile data
        final response = await supabase
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .single();
        
        if (mounted) {
          setState(() {
            _fullNameController.text = response['full_name'] ?? '';
            _emailController.text = response['email'] ?? user.email ?? '';
            _phoneController.text = response['phone'] ?? '';
            _addressController.text = response['address'] ?? '';
            _selectedState = response['state'];
            _selectedCity = response['city'];
            _availableCities = NigeriaLocations.getCities(_selectedState ?? '');
            _isLoadingProfile = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _saveShippingAddress() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user != null) {
        await supabase.from('user_profiles').update({
          'full_name': _fullNameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'city': _selectedCity,
          'state': _selectedState,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
      }
    } catch (e) {
      // Silently fail - shipping address save is not critical
      print('Failed to save shipping address: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_currentStep < 1) {
      if (_currentStep == 0) {
        // Check if address is filled
        if (_fullNameController.text.isEmpty || 
            _addressController.text.isEmpty || 
            _selectedCity == null || 
            _selectedState == null ||
            _phoneController.text.isEmpty ||
            _emailController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete all required shipping fields'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        // Save shipping address before moving to review
        await _saveShippingAddress();
        
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _placeOrder() async {
    final cartState = ref.read(cartNotifierProvider);
    
    if (cartState.items.isEmpty) {
      setState(() {
        _errorMessage = 'Your cart is empty';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current user
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to place an order'),
              backgroundColor: Colors.red,
            ),
          );
        }
        throw Exception('You must be logged in to place an order');
      }
      
      debugPrint('Starting payment flow for user: ${user.id}');

      // Prepare order data (but don't create order yet)
      final shippingAddress = ShippingAddress(
        fullName: _fullNameController.text,
        addressLine1: _addressController.text,
        addressLine2: _additionalInfoController.text,
        city: _selectedCity ?? '',
        state: _selectedState ?? '',
        postalCode: '',
        country: 'Nigeria',
        phone: _phoneController.text,
        email: _emailController.text,
      );

      final orderItems = cartState.items.map((item) => OrderItem(
        id: '',
        orderId: '',
        productId: int.tryParse(item.productId) ?? 0,
        productName: item.displayName,
        quantity: item.quantity,
        unitPrice: item.price,
        totalPrice: item.price * item.quantity,
        imageUrl: item.imageUrl,
        variantId: item.variantId,
        variantAttributes: item.variantAttributes,
      )).toList();

      // STEP 1: Process payment FIRST (no order created yet)
      // Generate a temporary reference for payment
      final paymentReference = PaystackService().generateReference();
      debugPrint('💳 Processing payment with reference: $paymentReference');

      bool paymentSuccess = false;
      
      try {
        paymentSuccess = await ref.read(paymentNotifierProvider.notifier).processPaymentWithoutOrder(
          context: context,
          reference: paymentReference,
          amount: cartState.total,
          email: _emailController.text,
        );
      } catch (e, stackTrace) {
        debugPrint('Exception during payment: $e');
        debugPrint('Stack trace: $stackTrace');
        paymentSuccess = false;
      }

      if (!paymentSuccess) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = ref.read(paymentNotifierProvider).error ?? 'Payment failed';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage ?? 'Payment failed'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // STEP 2: Payment verified - NOW create the order
      debugPrint('✅ Payment verified, creating order...');
      
      final order = await ref.read(orderNotifierProvider.notifier).createOrder(
        total: cartState.total,
        items: orderItems,
        shippingAddress: shippingAddress,
        paymentMethod: 'paystack',
        paymentReference: paymentReference,
      );
      
      debugPrint('Order created successfully: ${order.id}');

      // Clear cart after successful order creation
      try {
        await ref.read(cartNotifierProvider.notifier).clearCart();
      } catch (e) {
        debugPrint('Error clearing cart: $e');
      }
      
      // Navigate to success
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
          
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment verified! Order placed successfully.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        context.go('/profile/orders');
      }
    } catch (e, stackTrace) {
      debugPrint('Error placing order: $e');
      debugPrint('Stack trace: $stackTrace');
      
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Failed to place order'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentStep == 0 
              ? () => context.pop() 
              : _previousStep,
        ),
      ),
      body: Column(
        children: [
          // Stepper indicator
          _StepperIndicator(currentStep: _currentStep),
          
          // Main content - scrollable
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1: Shipping Information
                _buildShippingForm(),
                
                // Step 2: Review & Payment
                _buildOrderSummary(cartState),
              ],
            ),
          ),
          
          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          
          // Action buttons
          _buildBottomBar(cartState),
        ],
      ),
    );
  }
  
  Widget _buildShippingForm() {
    if (_isLoadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          
          // Address Name field
          CustomTextField(
            controller: _fullNameController,
            labelText: 'Address Name',
            hintText: 'E.g., Home, Work, etc.',
            prefixIcon: const Icon(Icons.bookmark),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an address name';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.medium),
          
          // Street Address field
          CustomTextField(
            controller: _addressController,
            labelText: 'Street Address',
            hintText: 'Enter your street address',
            prefixIcon: const Icon(Icons.home),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a street address';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.medium),
          
          // State dropdown
          DropdownButtonFormField<String>(
            value: _selectedState,
            decoration: InputDecoration(
              labelText: 'State/Province',
              prefixIcon: const Icon(Icons.map),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: NigeriaLocations.states.map((state) {
              return DropdownMenuItem(
                value: state,
                child: Text(state),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedState = value;
                _selectedCity = null;
                _availableCities = NigeriaLocations.getCities(value ?? '');
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a state';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.medium),
          
          // City dropdown
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: InputDecoration(
              labelText: 'City',
              prefixIcon: const Icon(Icons.location_city),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _availableCities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a city';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.medium),
          
          // Country field (read-only)
          CustomTextField(
            controller: TextEditingController(text: 'Nigeria'),
            labelText: 'Country',
            hintText: 'Nigeria',
            prefixIcon: const Icon(Icons.public),
            readOnly: true,
          ),
          const SizedBox(height: AppSpacing.medium),
          
          // Phone field
          CustomTextField(
            controller: _phoneController,
            labelText: 'Phone Number',
            hintText: 'Enter phone number for delivery',
            prefixIcon: const Icon(Icons.phone),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.medium),
          
          // Additional Info field
          CustomTextField(
            controller: _additionalInfoController,
            labelText: 'Additional Information',
            hintText: 'Apartment number, building, landmark, etc.',
            prefixIcon: const Icon(Icons.info),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.medium),
          
          // Email field
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email',
            prefixIcon: const Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }
  

  
  Widget _buildOrderSummary(cartState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          
          // Order details card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items
                  ...cartState.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.small),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.name}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          CurrencyUtils.formatPrice(item.price * item.quantity),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )),
                  
                  const Divider(height: 24),
                  
                  // Coupon Input
                  const CouponInputWidget(),
                  const SizedBox(height: AppSpacing.medium),
                  
                  const Divider(height: 24),
                  
                  // Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        CurrencyUtils.formatPrice(cartState.subtotal),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.small),
                  
                  // Discount (if coupon applied)
                  if (cartState.discount > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Discount',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          '-${CurrencyUtils.formatPrice(cartState.discount)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.small),
                  ],
                  
                  // Shipping
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shipping',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        CurrencyUtils.formatPrice(cartState.shipping),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        CurrencyUtils.formatPrice(cartState.total),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.large),
          
          // Shipping information
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shipping Address',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(_fullNameController.text),
                  Text(_addressController.text),
                  if (_additionalInfoController.text.isNotEmpty)
                    Text(_additionalInfoController.text),
                  Text('${_selectedCity ?? ''}, ${_selectedState ?? ''}'),
                  Text('Nigeria'),
                  const SizedBox(height: AppSpacing.small),
                  Text('Phone: ${_phoneController.text}'),
                  Text('Email: ${_emailController.text}'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }
  
  Widget _buildBottomBar(cartState) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Show back button on review step
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0)
              const SizedBox(width: AppSpacing.medium),
            
            Expanded(
              flex: 2,
              child: CustomButton(
                text: _currentStep == 1
                    ? 'Place Order ${CurrencyUtils.formatPrice(cartState.total)}'
                    : 'Continue',
                onPressed: _isLoading
                    ? null
                    : _currentStep == 1
                        ? _placeOrder
                        : _nextStep,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final paymentState = ref.watch(paymentNotifierProvider);
          
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (paymentState.isVerifying) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    paymentState.verificationMessage ?? 'Verifying payment...',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we confirm your payment with Paystack.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ] else if (paymentState.verificationStatus == 'success') ...[
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Payment Verified!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ] else ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Processing...'),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StepperIndicator extends StatelessWidget {
  final int currentStep;
  
  const _StepperIndicator({
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.medium,
        horizontal: AppSpacing.large,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildStep(
            context, 
            index: 0, 
            title: 'Shipping',
            isActive: currentStep >= 0,
            isComplete: currentStep > 0,
          ),
          _buildLine(context, isActive: currentStep > 0),
          _buildStep(
            context, 
            index: 1, 
            title: 'Review & Pay',
            isActive: currentStep >= 1,
            isComplete: false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep(
    BuildContext context, {
    required int index,
    required String title,
    required bool isActive,
    required bool isComplete,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? isComplete
                      ? AppColors.success
                      : AppColors.primary
                  : Colors.grey[300],
            ),
            child: Center(
              child: isComplete
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLine(BuildContext context, {required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primary : Colors.grey[300],
      ),
    );
  }
} 


