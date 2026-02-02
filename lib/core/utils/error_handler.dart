import 'dart:io';

class ErrorHandler {
  /// Converts technical errors into user-friendly messages
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'Something went wrong. Please try again.';
    }

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socketexception') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('no address associated with hostname')) {
      return 'No internet connection. Please check your network and try again.';
    }

    // Timeout errors
    if (errorString.contains('timeout') ||
        errorString.contains('timed out')) {
      return 'Request timed out. Please check your connection and try again.';
    }

    // Server errors
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504') ||
        errorString.contains('server error')) {
      return 'Server is temporarily unavailable. Please try again later.';
    }

    // Authentication errors
    if (errorString.contains('unauthorized') ||
        errorString.contains('401') ||
        errorString.contains('authentication') ||
        errorString.contains('invalid credentials')) {
      return 'Authentication failed. Please log in again.';
    }

    // Permission errors
    if (errorString.contains('forbidden') ||
        errorString.contains('403') ||
        errorString.contains('permission denied')) {
      return 'You don\'t have permission to access this resource.';
    }

    // Not found errors
    if (errorString.contains('404') ||
        errorString.contains('not found')) {
      return 'The requested resource was not found.';
    }

    // Bad request errors
    if (errorString.contains('400') ||
        errorString.contains('bad request')) {
      return 'Invalid request. Please check your input and try again.';
    }

    // Database errors
    if (errorString.contains('database') ||
        errorString.contains('sql') ||
        errorString.contains('query')) {
      return 'Database error. Please try again later.';
    }

    // Format errors
    if (errorString.contains('format') ||
        errorString.contains('parse') ||
        errorString.contains('json')) {
      return 'Data format error. Please try again.';
    }

    // Certificate errors
    if (errorString.contains('certificate') ||
        errorString.contains('ssl') ||
        errorString.contains('handshake')) {
      return 'Security certificate error. Please check your connection.';
    }

    // Default message for unknown errors
    return 'Something went wrong. Please try again.';
  }

  /// Check if error is a network error
  static bool isNetworkError(dynamic error) {
    if (error == null) return false;
    
    if (error is SocketException) return true;
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('failed host lookup');
  }

  /// Check if error is a timeout error
  static bool isTimeoutError(dynamic error) {
    if (error == null) return false;
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('timeout') ||
        errorString.contains('timed out');
  }

  /// Check if error is a server error
  static bool isServerError(dynamic error) {
    if (error == null) return false;
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504') ||
        errorString.contains('server error');
  }

  /// Get error icon based on error type
  static String getErrorIcon(dynamic error) {
    if (isNetworkError(error)) return '📡';
    if (isTimeoutError(error)) return '⏱️';
    if (isServerError(error)) return '🔧';
    return '⚠️';
  }
}
