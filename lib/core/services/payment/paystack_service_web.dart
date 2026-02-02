import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:wealth_app/core/config/env_config.dart';

// Web-specific imports
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

/// Payment status from Paystack UI interaction.
/// IMPORTANT: This status only indicates UI flow completion, NOT actual payment success.
/// Always verify through backend before trusting payment status.
enum PaystackPaymentStatus { 
  /// UI flow completed - user clicked through payment. MUST verify via backend.
  success, 
  /// Payment failed during UI flow
  failed, 
  /// User cancelled the payment
  cancelled 
}

class PaystackPaymentResponse {
  final PaystackPaymentStatus status;
  final String? reference;
  final String? message;

  PaystackPaymentResponse({
    required this.status,
    this.reference,
    this.message,
  });
}

class PaystackService {
  static final PaystackService _instance = PaystackService._internal();
  factory PaystackService() => _instance;
  PaystackService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _initialized = true;
      debugPrint('✅ Paystack initialized successfully (Web)');
    } catch (e) {
      debugPrint('❌ Paystack initialization error: $e');
      rethrow;
    }
  }

  Future<PaystackPaymentResponse> chargeCard({
    required BuildContext context,
    required String email,
    required double amount,
    required String reference,
    String? currency,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => PaystackPaymentScreen(
            email: email,
            amount: amount,
            reference: reference,
            currency: currency ?? 'NGN',
            publicKey: EnvConfig.paystackPublicKey,
          ),
        ),
      );

      if (result != null && result['status'] == 'success') {
        // IMPORTANT: This only means UI flow completed, NOT that payment succeeded
        // Backend verification is required
        return PaystackPaymentResponse(
          status: PaystackPaymentStatus.success,
          reference: result['reference'],
          message: 'Payment UI completed - awaiting verification',
        );
      } else if (result != null && result['status'] == 'cancelled') {
        return PaystackPaymentResponse(
          status: PaystackPaymentStatus.cancelled,
          message: 'Payment cancelled',
        );
      } else {
        return PaystackPaymentResponse(
          status: PaystackPaymentStatus.failed,
          message: result?['message'] ?? 'Payment failed',
        );
      }
    } catch (e) {
      debugPrint('❌ Paystack charge error: $e');
      return PaystackPaymentResponse(
        status: PaystackPaymentStatus.failed,
        message: e.toString(),
      );
    }
  }

  String generateReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'WS_$timestamp';
  }
}

class PaystackPaymentScreen extends StatefulWidget {
  final String email;
  final double amount;
  final String reference;
  final String currency;
  final String publicKey;

  const PaystackPaymentScreen({
    super.key,
    required this.email,
    required this.amount,
    required this.reference,
    required this.currency,
    required this.publicKey,
  });

  @override
  State<PaystackPaymentScreen> createState() => _PaystackPaymentScreenState();
}

class _PaystackPaymentScreenState extends State<PaystackPaymentScreen> {
  bool _isLoading = true;
  late final String _iframeId;
  bool _viewRegistered = false;

  @override
  void initState() {
    super.initState();
    _iframeId = 'paystack-iframe-${DateTime.now().millisecondsSinceEpoch}';
    _registerWebView();
    _initializeWebPayment();
  }

  void _registerWebView() {
    if (_viewRegistered) return;
    
    final amountInKobo = (widget.amount * 100).toInt();
    
    // Register view factory for iframe
    // ignore: avoid_web_libraries_in_flutter
    ui_web.platformViewRegistry.registerViewFactory(_iframeId, (int viewId) {
      final iframe = html.IFrameElement();
      iframe.style.width = '100%';
      iframe.style.height = '100%';
      iframe.style.border = 'none';
      
      // IMPORTANT: The callback here only indicates UI completion
      // Actual payment verification happens on the backend
      final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://js.paystack.co/v1/inline.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: #f5f5f5;
        }
        .container {
            text-align: center;
            padding: 20px;
        }
        .loader {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #3498db;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 20px auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Processing Payment...</h2>
        <div class="loader"></div>
        <p>Please wait while we redirect you to Paystack</p>
    </div>
    <script>
        var handler = PaystackPop.setup({
            key: '${widget.publicKey}',
            email: '${widget.email}',
            amount: $amountInKobo,
            currency: '${widget.currency}',
            ref: '${widget.reference}',
            channels: ['card', 'bank', 'bank_transfer'],
            callback: function(response) {
                // UI flow completed - backend will verify actual payment status
                window.parent.postMessage({status: 'success', reference: response.reference}, '*');
            },
            onClose: function() {
                window.parent.postMessage({status: 'cancelled'}, '*');
            }
        });
        
        setTimeout(function() {
            handler.openIframe();
        }, 1000);
        
        // Listen for messages from parent
        window.addEventListener('message', function(e) {
          if (e.data.action === 'close') {
            window.parent.postMessage({status: 'cancelled'}, '*');
          }
        });
    </script>
</body>
</html>
      ''';
      
      iframe.srcdoc = htmlContent;
      return iframe;
    });
    
    _viewRegistered = true;
  }

  void _initializeWebPayment() {
    // Listen for messages from iframe
    html.window.onMessage.listen((event) {
      if (event.data is Map) {
        final data = event.data as Map;
        if (data['status'] == 'success') {
          // UI flow completed - return for backend verification
          Navigator.pop(context, {
            'status': 'success',
            'reference': data['reference'],
          });
        } else if (data['status'] == 'cancelled') {
          Navigator.pop(context, {'status': 'cancelled'});
        }
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paystack Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context, {'status': 'cancelled'});
          },
        ),
      ),
      body: Stack(
        children: [
          HtmlElementView(viewType: _iframeId),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
