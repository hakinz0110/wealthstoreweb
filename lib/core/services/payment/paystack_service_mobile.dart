import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_paystack_max/flutter_paystack_max.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wealth_app/core/config/env_config.dart';

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

  Future<void> initialize() async {
    debugPrint('✅ Paystack ready (Mobile)');
  }

  Future<PaystackPaymentResponse> chargeCard({
    required BuildContext context,
    required String email,
    required double amount,
    required String reference,
    String? currency,
  }) async {
    // Route to native SDK on Android, WebView on iOS
    if (Platform.isAndroid) {
      return _chargeCardNative(
        context: context,
        email: email,
        amount: amount,
        reference: reference,
        currency: currency ?? 'NGN',
      );
    } else {
      return _chargeCardWebView(
        context: context,
        email: email,
        amount: amount,
        reference: reference,
        currency: currency ?? 'NGN',
      );
    }
  }

  // Native Android implementation using flutter_paystack_max
  Future<PaystackPaymentResponse> _chargeCardNative({
    required BuildContext context,
    required String email,
    required double amount,
    required String reference,
    required String currency,
  }) async {
    try {
      final amountInKobo = (amount * 100).toInt();
      
      debugPrint('💳 Initiating native Paystack payment (Android): $amountInKobo kobo, ref: $reference');
      
      // Initialize transaction - only Card, Bank, and Transfer channels
      final request = PaystackTransactionRequest(
        reference: reference,
        secretKey: EnvConfig.paystackSecretKey,
        email: email,
        amount: amountInKobo.toDouble(),
        currency: PaystackCurrency.ngn,
        channel: [
          PaystackPaymentChannel.card,
          PaystackPaymentChannel.bank,
          PaystackPaymentChannel.bankTransfer,
        ],
      );

      final initializedTransaction = await PaymentService.initializeTransaction(request);

      if (!initializedTransaction.status) {
        return PaystackPaymentResponse(
          status: PaystackPaymentStatus.failed,
          message: initializedTransaction.message ?? 'Failed to initialize payment',
        );
      }

      debugPrint('✅ Transaction initialized: ${initializedTransaction.data?.reference}');

      // Show custom payment modal - waits for user to complete UI flow
      final uiResult = await _showCustomPaymentModal(
        context,
        transaction: initializedTransaction,
        reference: reference,
      );

      // Return UI result - actual verification happens in PaymentNotifier
      // DO NOT verify here - let the backend handle it
      debugPrint('📱 UI flow completed with result: $uiResult');
      
      if (uiResult == _PaymentUIResult.cancelled) {
        return PaystackPaymentResponse(
          status: PaystackPaymentStatus.cancelled,
          reference: reference,
          message: 'Payment cancelled',
        );
      }

      // UI flow completed - return success status for backend verification
      // This does NOT mean payment succeeded - backend will verify
      return PaystackPaymentResponse(
        status: PaystackPaymentStatus.success,
        reference: reference,
        message: 'Payment UI completed - awaiting verification',
      );
    } catch (e) {
      debugPrint('❌ Native Paystack charge error: $e');
      
      if (e.toString().toLowerCase().contains('cancel')) {
        return PaystackPaymentResponse(
          status: PaystackPaymentStatus.cancelled,
          reference: reference,
          message: 'Payment cancelled',
        );
      }
      
      return PaystackPaymentResponse(
        status: PaystackPaymentStatus.failed,
        reference: reference,
        message: e.toString(),
      );
    }
  }

  // WebView implementation for iOS
  Future<PaystackPaymentResponse> _chargeCardWebView({
    required BuildContext context,
    required String email,
    required double amount,
    required String reference,
    required String currency,
  }) async {
    try {
      final amountInKobo = (amount * 100).toInt();
      
      debugPrint('💳 Initiating WebView Paystack payment (iOS): $amountInKobo kobo, ref: $reference');
      
      // Initialize transaction - only Card, Bank, and Transfer channels
      final request = PaystackTransactionRequest(
        reference: reference,
        secretKey: EnvConfig.paystackSecretKey,
        email: email,
        amount: amountInKobo.toDouble(),
        currency: PaystackCurrency.ngn,
        channel: [
          PaystackPaymentChannel.card,
          PaystackPaymentChannel.bank,
          PaystackPaymentChannel.bankTransfer,
        ],
      );

      final initializedTransaction = await PaymentService.initializeTransaction(request);

      if (!initializedTransaction.status) {
        return PaystackPaymentResponse(
          status: PaystackPaymentStatus.failed,
          message: initializedTransaction.message ?? 'Failed to initialize payment',
        );
      }

      final authUrl = initializedTransaction.data?.authorizationUrl;
      if (authUrl == null) {
        return PaystackPaymentResponse(
          status: PaystackPaymentStatus.failed,
          message: 'No authorization URL received',
        );
      }

      final result = await Navigator.push<PaystackPaymentResponse>(
        context,
        MaterialPageRoute(
          builder: (context) => _PaystackWebView(
            url: authUrl,
            reference: reference,
          ),
        ),
      );

      return result ?? PaystackPaymentResponse(
        status: PaystackPaymentStatus.cancelled,
        reference: reference,
        message: 'Payment cancelled',
      );
    } catch (e) {
      debugPrint('❌ WebView Paystack charge error: $e');
      return PaystackPaymentResponse(
        status: PaystackPaymentStatus.failed,
        message: e.toString(),
      );
    }
  }

  Future<_PaymentUIResult> _showCustomPaymentModal(
    BuildContext context, {
    required PaystackInitializedTraction transaction,
    required String reference,
  }) async {
    final completer = Completer<_PaymentUIResult>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        minHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      builder: (context) => _CustomPaymentWidget(
        transaction: transaction,
        reference: reference,
        onFlowComplete: (result) {
          if (!completer.isCompleted) {
            Navigator.pop(context);
            completer.complete(result);
          }
        },
      ),
    );

    // If modal was dismissed without completing, treat as cancelled
    if (!completer.isCompleted) {
      completer.complete(_PaymentUIResult.cancelled);
    }

    return completer.future;
  }

  String generateReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'WS_$timestamp';
  }
}

enum _PaymentUIResult { completed, cancelled }

class _CustomPaymentWidget extends StatefulWidget {
  final PaystackInitializedTraction transaction;
  final String reference;
  final void Function(_PaymentUIResult result) onFlowComplete;

  const _CustomPaymentWidget({
    required this.transaction,
    required this.reference,
    required this.onFlowComplete,
  });

  @override
  State<_CustomPaymentWidget> createState() => _CustomPaymentWidgetState();
}

class _CustomPaymentWidgetState extends State<_CustomPaymentWidget> {
  late final WebViewController _controller;
  double _loadingProgress = 0;
  bool _flowCompleted = false;

  // Domains that should be allowed in WebView (Paystack and payment partners)
  static const _allowedDomains = [
    'paystack.com',
    'paystack.co',
    'standard.paystack.co',
    'opaycheckout.com',
    'opay.com',
    'flutterwave.com',
    'rave.flutterwave.com',
  ];

  bool _isAllowedDomain(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final host = uri.host.toLowerCase();
    return _allowedDomains.any((domain) => host.contains(domain));
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100;
            });
          },
          onPageFinished: (url) {
            debugPrint('📄 Page finished loading: $url');
            // Check if we landed on a success/callback page
            _checkForCompletion(url);
            
            // For OPay pages, inject script to force web mode
            if (url.contains('opaycheckout.com') || url.contains('opay.com')) {
              _controller.runJavaScript('''
                // Force OPay to use web flow instead of app deep link
                window.isNativeApp = false;
                window.isInApp = false;
                if (window.OPayBridge) window.OPayBridge = null;
              ''');
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ WebView error: ${error.description}');
            // Don't cancel on minor resource errors - only on critical failures
            if (error.errorType == WebResourceErrorType.connect ||
                error.errorType == WebResourceErrorType.hostLookup) {
              _completeFlow(_PaymentUIResult.cancelled);
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            debugPrint('🔗 Payment navigation: $url');

            // Handle USSD codes - launch dialer
            if (url.startsWith('tel:')) {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
              return NavigationDecision.prevent;
            }

            // Handle non-HTTP URLs (deep links, tel:, etc.)
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              // For OPay/payment app deep links - try to launch, if fails the page will fallback
              if (url.startsWith('opay://') || 
                  url.startsWith('btravel://') ||
                  url.startsWith('gtbank://') ||
                  url.startsWith('firstbank://')) {
                debugPrint('📱 Attempting to launch payment app: $url');
                final uri = Uri.tryParse(url);
                if (uri != null) {
                  final canLaunch = await canLaunchUrl(uri);
                  if (canLaunch) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    debugPrint('⏭️ Payment app not installed, web flow will handle it');
                  }
                }
                return NavigationDecision.prevent;
              }
              
              // For other deep links, try to launch externally
              debugPrint('📱 Launching external app: $url');
              final uri = Uri.tryParse(url);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              return NavigationDecision.prevent;
            }

            // Check for payment completion callbacks
            if (_isCompletionUrl(url)) {
              debugPrint('📋 Callback URL detected - completing flow');
              _completeFlow(_PaymentUIResult.completed);
              return NavigationDecision.prevent;
            }

            // Handle explicit cancellation
            if (url.contains('/cancel') || url.contains('?cancelled=true')) {
              debugPrint('❌ Cancel detected in URL');
              _completeFlow(_PaymentUIResult.cancelled);
              return NavigationDecision.prevent;
            }

            // Allow navigation to payment partner domains
            if (_isAllowedDomain(url)) {
              debugPrint('✅ Allowing navigation to payment domain: $url');
              return NavigationDecision.navigate;
            }

            // For unknown external URLs, open in external browser
            if (!url.contains('paystack')) {
              debugPrint('🌐 Opening external URL in browser: $url');
              final uri = Uri.tryParse(url);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.transaction.data!.authorizationUrl));
  }

  bool _isCompletionUrl(String url) {
    return url.contains('paystack-callback') ||
        url.contains('paystack-webhook') ||
        url.contains('trxref=') ||
        url.contains('reference=${widget.reference}') ||
        url.contains('transaction_status=success') ||
        url.contains('opay-wallet-info-app-result') ||
        url.contains('payment_status=success');
  }

  void _checkForCompletion(String url) {
    if (_isCompletionUrl(url)) {
      debugPrint('📋 Completion detected on page load');
      _completeFlow(_PaymentUIResult.completed);
    }
  }

  void _completeFlow(_PaymentUIResult result) {
    if (!_flowCompleted) {
      _flowCompleted = true;
      widget.onFlowComplete(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with close button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Complete Payment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _completeFlow(_PaymentUIResult.cancelled),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // WebView content
        Expanded(
          child: _loadingProgress < 1
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Loading payment page...'),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: LinearProgressIndicator(value: _loadingProgress),
                      ),
                    ],
                  ),
                )
              : WebViewWidget(controller: _controller),
        ),
      ],
    );
  }
}

class _PaystackWebView extends StatefulWidget {
  final String url;
  final String reference;

  const _PaystackWebView({
    required this.url,
    required this.reference,
  });

  @override
  State<_PaystackWebView> createState() => _PaystackWebViewState();
}

class _PaystackWebViewState extends State<_PaystackWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  // Domains that should be allowed in WebView
  static const _allowedDomains = [
    'paystack.com',
    'paystack.co',
    'standard.paystack.co',
    'opaycheckout.com',
    'opay.com',
    'flutterwave.com',
  ];

  bool _isAllowedDomain(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final host = uri.host.toLowerCase();
    return _allowedDomains.any((domain) => host.contains(domain));
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('📄 Page started: $url');
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            debugPrint('✅ Page finished: $url');
            setState(() => _isLoading = false);
            _checkForFlowCompletion(url);
            
            // For OPay pages, inject script to force web mode
            if (url.contains('opaycheckout.com') || url.contains('opay.com')) {
              _controller.runJavaScript('''
                window.isNativeApp = false;
                window.isInApp = false;
                if (window.OPayBridge) window.OPayBridge = null;
              ''');
            }
          },
          onNavigationRequest: (request) async {
            final url = request.url;
            debugPrint('🔗 Navigation: $url');

            // Handle USSD codes - launch dialer
            if (url.startsWith('tel:')) {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
              return NavigationDecision.prevent;
            }

            // Handle non-HTTP URLs (deep links)
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              // For payment app deep links - try to launch, page will fallback if not installed
              if (url.startsWith('opay://') || 
                  url.startsWith('btravel://') ||
                  url.startsWith('gtbank://') ||
                  url.startsWith('firstbank://')) {
                debugPrint('📱 Attempting to launch payment app: $url');
                final uri = Uri.tryParse(url);
                if (uri != null) {
                  final canLaunch = await canLaunchUrl(uri);
                  if (canLaunch) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    debugPrint('⏭️ Payment app not installed, web flow will handle it');
                  }
                }
                return NavigationDecision.prevent;
              }
              
              debugPrint('📱 Launching external app: $url');
              final uri = Uri.tryParse(url);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              return NavigationDecision.prevent;
            }

            // Check for completion
            if (_isCompletionUrl(url)) {
              _completeWithSuccess();
              return NavigationDecision.prevent;
            }

            // Allow payment partner domains
            if (_isAllowedDomain(url)) {
              return NavigationDecision.navigate;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  bool _isCompletionUrl(String url) {
    return url.contains('wealth-store-success.com') ||
        url.contains('trxref=${widget.reference}') ||
        url.contains('reference=${widget.reference}') ||
        url.contains('paystack-callback') ||
        url.contains('transaction_status=success') ||
        url.contains('opay-wallet-info-app-result') ||
        url.contains('payment_status=success');
  }

  void _checkForFlowCompletion(String url) {
    if (_isCompletionUrl(url)) {
      _completeWithSuccess();
    }
  }

  void _completeWithSuccess() {
    debugPrint('📋 Callback detected - UI flow complete, returning for backend verification');
    Navigator.pop(
      context,
      PaystackPaymentResponse(
        status: PaystackPaymentStatus.success,
        reference: widget.reference,
        message: 'Payment UI completed - awaiting verification',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(
              context,
              PaystackPaymentResponse(
                status: PaystackPaymentStatus.cancelled,
                reference: widget.reference,
                message: 'Payment cancelled',
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
