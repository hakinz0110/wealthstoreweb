import 'package:intl/intl.dart';

class CurrencyUtils {
  static const String currencySymbol = '₦';
  
  static String formatPrice(double price, {bool showDecimals = false}) {
    final formatter = NumberFormat('#,###');
    final formattedNumber = formatter.format(price.round());
    return '$currencySymbol$formattedNumber${showDecimals ? '.00' : ''}';
  }
  
  static String formatPriceRange(double minPrice, double maxPrice) {
    if (minPrice == maxPrice) {
      return formatPrice(minPrice);
    }
    return '${formatPrice(minPrice)} - ${formatPrice(maxPrice)}';
  }
  
  static String formatCompactPrice(double price) {
    if (price >= 1000000) {
      return '$currencySymbol${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '$currencySymbol${(price / 1000).toStringAsFixed(1)}K';
    }
    return formatPrice(price);
  }
}
