// Platform-specific exports for Paystack service
// This file conditionally exports the correct implementation based on the platform

export 'paystack_service_mobile.dart'
    if (dart.library.html) 'paystack_service_web.dart';
