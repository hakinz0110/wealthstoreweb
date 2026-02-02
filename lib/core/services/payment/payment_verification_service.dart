import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for verifying payments through the secure backend Edge Function.
/// NEVER verifies payments client-side - always delegates to backend.
class PaymentVerificationService {
  static const int _maxRetries = 10;
  static const Duration _retryDelay = Duration(seconds: 3);
  static const Duration _initialDelay = Duration(seconds: 2);

  /// Verifies a payment through the Supabase Edge Function.
  /// This is the ONLY way payments should be verified - never trust client-side callbacks.
  /// 
  /// Returns a map with:
  /// - success: bool - whether payment was verified as successful
  /// - status: String - payment status (success, pending, failed, etc.)
  /// - message: String - human-readable message
  /// - data: Map - additional payment data if successful
  Future<Map<String, dynamic>> verifyPaymentViaBackend({
    required String reference,
    required String orderId,
    required double expectedAmount,
  }) async {
    try {
      debugPrint('🔐 Verifying payment via backend: $reference for order: $orderId');

      final supabase = Supabase.instance.client;
      
      final response = await supabase.functions.invoke(
        'verify-payment',
        body: {
          'reference': reference,
          'orderId': orderId,
          'expectedAmount': expectedAmount,
        },
      );

      debugPrint('📦 Backend verification response: ${response.data}');

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] == true,
          'status': data['status'] ?? 'unknown',
          'message': data['message'] ?? 'Verification complete',
          'data': data,
        };
      } else if (response.status == 202) {
        // Payment still processing
        return {
          'success': false,
          'status': 'pending',
          'message': 'Payment is still being processed',
          'data': response.data,
        };
      } else {
        final data = response.data as Map<String, dynamic>?;
        return {
          'success': false,
          'status': data?['status'] ?? 'failed',
          'message': data?['message'] ?? 'Verification failed',
          'data': data,
        };
      }
    } catch (e) {
      debugPrint('❌ Backend verification error: $e');
      return {
        'success': false,
        'status': 'error',
        'message': 'Error verifying payment: $e',
      };
    }
  }

  /// Polls the backend for payment verification with retries.
  /// Use this for channels like USSD, Bank Transfer, Zap, OPay where
  /// payment confirmation may be delayed.
  /// 
  /// [onStatusUpdate] is called with each status update during polling.
  Future<Map<String, dynamic>> verifyPaymentWithPolling({
    required String reference,
    required String orderId,
    required double expectedAmount,
    void Function(String status, String message)? onStatusUpdate,
  }) async {
    debugPrint('⏳ Starting payment verification polling for: $reference');
    
    // Initial delay to allow payment to process
    onStatusUpdate?.call('processing', 'Waiting for payment confirmation...');
    await Future.delayed(_initialDelay);

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      debugPrint('🔄 Verification attempt $attempt/$_maxRetries');
      
      final result = await verifyPaymentViaBackend(
        reference: reference,
        orderId: orderId,
        expectedAmount: expectedAmount,
      );

      final status = result['status'] as String;
      final message = result['message'] as String;

      // Payment successful
      if (result['success'] == true) {
        debugPrint('✅ Payment verified successfully on attempt $attempt');
        onStatusUpdate?.call('success', 'Payment confirmed!');
        return result;
      }

      // Terminal failure states - stop polling
      if (status == 'failed' || 
          status == 'abandoned' || 
          status == 'reversed' ||
          status == 'amount_mismatch' ||
          status == 'order_not_found') {
        debugPrint('❌ Payment failed with terminal status: $status');
        onStatusUpdate?.call(status, message);
        return result;
      }

      // Still pending - continue polling
      if (status == 'pending' || status == 'processing' || status == 'queued') {
        onStatusUpdate?.call(status, 'Verifying payment... (attempt $attempt/$_maxRetries)');
        
        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay);
          continue;
        }
      }

      // Unknown status or max retries reached
      if (attempt >= _maxRetries) {
        debugPrint('⚠️ Max retries reached, payment status: $status');
        onStatusUpdate?.call('timeout', 'Payment verification timed out. Please check your order status.');
        return {
          'success': false,
          'status': 'timeout',
          'message': 'Payment verification timed out. If you completed the payment, it will be confirmed shortly.',
          'data': result['data'],
        };
      }

      await Future.delayed(_retryDelay);
    }

    return {
      'success': false,
      'status': 'timeout',
      'message': 'Payment verification timed out',
    };
  }

  /// Checks the current payment status without polling.
  /// Useful for checking order status on the orders screen.
  Future<Map<String, dynamic>> checkPaymentStatus({
    required String reference,
    required String orderId,
  }) async {
    return verifyPaymentViaBackend(
      reference: reference,
      orderId: orderId,
      expectedAmount: 0, // Not checking amount for status check
    );
  }

  /// Verifies payment ONLY (without order update).
  /// Used when order hasn't been created yet - we verify payment first,
  /// then create order only if payment is successful.
  /// This prevents orphan orders from failed/cancelled payments.
  Future<Map<String, dynamic>> verifyPaymentOnly({
    required String reference,
    required double expectedAmount,
    void Function(String status, String message)? onStatusUpdate,
  }) async {
    debugPrint('⏳ Starting payment-only verification for: $reference');
    
    // Initial delay to allow payment to process
    onStatusUpdate?.call('processing', 'Waiting for payment confirmation...');
    await Future.delayed(_initialDelay);

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      debugPrint('🔄 Verification attempt $attempt/$_maxRetries');
      
      final result = await _verifyPaymentOnlyViaBackend(
        reference: reference,
        expectedAmount: expectedAmount,
      );

      final status = result['status'] as String;
      final message = result['message'] as String;

      // Payment successful
      if (result['success'] == true) {
        debugPrint('✅ Payment verified successfully on attempt $attempt');
        onStatusUpdate?.call('success', 'Payment confirmed!');
        return result;
      }

      // Terminal failure states - stop polling
      if (status == 'failed' || 
          status == 'abandoned' || 
          status == 'reversed' ||
          status == 'amount_mismatch') {
        debugPrint('❌ Payment failed with terminal status: $status');
        onStatusUpdate?.call(status, message);
        return result;
      }

      // Still pending - continue polling
      if (status == 'pending' || status == 'processing' || status == 'queued') {
        onStatusUpdate?.call(status, 'Verifying payment... (attempt $attempt/$_maxRetries)');
        
        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay);
          continue;
        }
      }

      // Unknown status or max retries reached
      if (attempt >= _maxRetries) {
        debugPrint('⚠️ Max retries reached, payment status: $status');
        onStatusUpdate?.call('timeout', 'Payment verification timed out.');
        return {
          'success': false,
          'status': 'timeout',
          'message': 'Payment verification timed out.',
          'data': result['data'],
        };
      }

      await Future.delayed(_retryDelay);
    }

    return {
      'success': false,
      'status': 'timeout',
      'message': 'Payment verification timed out',
    };
  }

  /// Backend call for payment-only verification (no order update).
  Future<Map<String, dynamic>> _verifyPaymentOnlyViaBackend({
    required String reference,
    required double expectedAmount,
  }) async {
    try {
      debugPrint('🔐 Verifying payment only via backend: $reference');

      final supabase = Supabase.instance.client;
      
      final response = await supabase.functions.invoke(
        'verify-payment',
        body: {
          'reference': reference,
          'expectedAmount': expectedAmount,
          'verifyOnly': true, // Flag to skip order update
        },
      );

      debugPrint('📦 Backend verification response: ${response.data}');

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] == true,
          'status': data['status'] ?? 'unknown',
          'message': data['message'] ?? 'Verification complete',
          'data': data,
        };
      } else if (response.status == 202) {
        return {
          'success': false,
          'status': 'pending',
          'message': 'Payment is still being processed',
          'data': response.data,
        };
      } else {
        final data = response.data as Map<String, dynamic>?;
        return {
          'success': false,
          'status': data?['status'] ?? 'failed',
          'message': data?['message'] ?? 'Verification failed',
          'data': data,
        };
      }
    } catch (e) {
      debugPrint('❌ Backend verification error: $e');
      return {
        'success': false,
        'status': 'error',
        'message': 'Error verifying payment: $e',
      };
    }
  }
}
