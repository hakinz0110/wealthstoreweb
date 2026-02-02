import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealth_app/core/services/payment/paystack_service.dart';
import 'package:wealth_app/core/services/payment/payment_verification_service.dart';

class PaymentState {
  final bool isProcessing;
  final bool isVerifying;
  final String? error;
  final String? transactionReference;
  final String? verificationStatus;
  final String? verificationMessage;

  PaymentState({
    this.isProcessing = false,
    this.isVerifying = false,
    this.error,
    this.transactionReference,
    this.verificationStatus,
    this.verificationMessage,
  });

  PaymentState copyWith({
    bool? isProcessing,
    bool? isVerifying,
    String? error,
    String? transactionReference,
    String? verificationStatus,
    String? verificationMessage,
  }) {
    return PaymentState(
      isProcessing: isProcessing ?? this.isProcessing,
      isVerifying: isVerifying ?? this.isVerifying,
      error: error,
      transactionReference: transactionReference ?? this.transactionReference,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationMessage: verificationMessage ?? this.verificationMessage,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaystackService _paystackService;
  final PaymentVerificationService _verificationService;

  PaymentNotifier({
    PaystackService? paystackService,
    PaymentVerificationService? verificationService,
  })  : _paystackService = paystackService ?? PaystackService(),
        _verificationService = verificationService ?? PaymentVerificationService(),
        super(PaymentState());

  /// Process payment WITHOUT creating an order first.
  /// Order is only created AFTER payment is verified.
  /// This prevents orphan orders from failed/cancelled payments.
  Future<bool> processPaymentWithoutOrder({
    required BuildContext context,
    required String reference,
    required double amount,
    required String email,
  }) async {
    state = state.copyWith(
      isProcessing: true, 
      isVerifying: false,
      error: null,
      verificationStatus: null,
      verificationMessage: null,
    );

    try {
      debugPrint('💳 Starting payment flow with reference: $reference');
      
      // Step 1: Show Paystack UI and wait for user interaction
      final response = await _paystackService.chargeCard(
        context: context,
        email: email,
        amount: amount,
        reference: reference,
      );
      
      // User cancelled the payment
      if (response.status == PaystackPaymentStatus.cancelled) {
        debugPrint('❌ User cancelled payment');
        state = state.copyWith(
          isProcessing: false,
          error: 'Payment cancelled',
        );
        return false;
      }

      // Step 2: Verify through backend (without order ID - just verify payment)
      debugPrint('🔐 Paystack UI completed, verifying through backend...');
      state = state.copyWith(
        isProcessing: false,
        isVerifying: true,
        verificationStatus: 'verifying',
        verificationMessage: 'Verifying payment...',
      );

      // Verify payment only (no order update)
      final verification = await _verificationService.verifyPaymentOnly(
        reference: reference,
        expectedAmount: amount,
        onStatusUpdate: (status, message) {
          debugPrint('📊 Verification status: $status - $message');
          state = state.copyWith(
            verificationStatus: status,
            verificationMessage: message,
          );
        },
      );

      debugPrint('📦 Final verification result: $verification');

      if (verification['success'] == true) {
        debugPrint('✅ Payment verified successfully via backend');
        state = state.copyWith(
          isVerifying: false,
          transactionReference: reference,
          verificationStatus: 'success',
          verificationMessage: 'Payment confirmed!',
        );
        return true;
      } else {
        final status = verification['status'] as String? ?? 'failed';
        final message = verification['message'] as String? ?? 'Payment verification failed';
        
        debugPrint('❌ Payment verification failed: $status - $message');
        state = state.copyWith(
          isVerifying: false,
          error: _getHumanReadableError(status, message),
          verificationStatus: status,
          verificationMessage: message,
        );
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Payment error: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isProcessing: false,
        isVerifying: false,
        error: 'An error occurred during payment. Please try again.',
      );
      return false;
    }
  }

  /// Process payment with secure backend verification (legacy - with order ID).
  /// 
  /// IMPORTANT: This method NEVER trusts the Paystack UI callback.
  /// It always verifies through the backend Edge Function before
  /// considering a payment successful.
  Future<bool> processPayment({
    required BuildContext context,
    required String orderId,
    required double amount,
    required String email,
  }) async {
    state = state.copyWith(
      isProcessing: true, 
      isVerifying: false,
      error: null,
      verificationStatus: null,
      verificationMessage: null,
    );

    try {
      final reference = _paystackService.generateReference();
      debugPrint('💳 Starting payment flow with reference: $reference');
      
      // Step 1: Show Paystack UI and wait for user interaction
      final response = await _paystackService.chargeCard(
        context: context,
        email: email,
        amount: amount,
        reference: reference,
      );
      
      // User cancelled the payment
      if (response.status == PaystackPaymentStatus.cancelled) {
        debugPrint('❌ User cancelled payment');
        state = state.copyWith(
          isProcessing: false,
          error: 'Payment cancelled',
        );
        return false;
      }

      // Step 2: ALWAYS verify through backend, regardless of UI callback status
      // This is critical - we NEVER trust the client-side callback
      debugPrint('🔐 Paystack UI completed, verifying through backend...');
      state = state.copyWith(
        isProcessing: false,
        isVerifying: true,
        verificationStatus: 'verifying',
        verificationMessage: 'Verifying payment...',
      );

      // Use polling for channels that may have delayed confirmation
      final verification = await _verificationService.verifyPaymentWithPolling(
        reference: reference,
        orderId: orderId,
        expectedAmount: amount,
        onStatusUpdate: (status, message) {
          debugPrint('📊 Verification status: $status - $message');
          state = state.copyWith(
            verificationStatus: status,
            verificationMessage: message,
          );
        },
      );

      debugPrint('📦 Final verification result: $verification');

      if (verification['success'] == true) {
        debugPrint('✅ Payment verified successfully via backend');
        state = state.copyWith(
          isVerifying: false,
          transactionReference: reference,
          verificationStatus: 'success',
          verificationMessage: 'Payment confirmed!',
        );
        return true;
      } else {
        final status = verification['status'] as String? ?? 'failed';
        final message = verification['message'] as String? ?? 'Payment verification failed';
        
        debugPrint('❌ Payment verification failed: $status - $message');
        state = state.copyWith(
          isVerifying: false,
          error: _getHumanReadableError(status, message),
          verificationStatus: status,
          verificationMessage: message,
        );
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Payment error: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isProcessing: false,
        isVerifying: false,
        error: 'An error occurred during payment. Please try again.',
      );
      return false;
    }
  }

  /// Converts technical status codes to user-friendly messages
  String _getHumanReadableError(String status, String message) {
    switch (status) {
      case 'failed':
        return 'Payment failed. Please try again or use a different payment method.';
      case 'abandoned':
        return 'Payment was not completed. Please try again.';
      case 'reversed':
        return 'Payment was reversed. Please contact support if you were charged.';
      case 'amount_mismatch':
        return 'Payment amount does not match. Please contact support.';
      case 'timeout':
        return 'Payment verification timed out. If you completed the payment, please check your order status.';
      case 'pending':
      case 'processing':
        return 'Payment is still being processed. Please check your order status in a few minutes.';
      default:
        return message.isNotEmpty ? message : 'Payment could not be verified. Please try again.';
    }
  }

  void clearError() {
    state = state.copyWith(error: null, verificationStatus: null, verificationMessage: null);
  }
}

final paymentNotifierProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier();
});
