import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wealth_app/features/cart/data/cart_repository.dart';
import 'package:wealth_app/shared/models/coupon.dart';

part 'cart_state.freezed.dart';
part 'cart_state.g.dart';

@freezed
class CartState with _$CartState {
  const factory CartState({
    @Default([]) List<CartItem> items,
    @Default(0.0) double total,
    @Default(0.0) double subtotal,
    @Default(0.0) double shipping,
    @Default(0) int itemCount,
    @Default(false) bool isLoading,
    String? error,
    Coupon? appliedCoupon,
    @Default(0.0) double discount,
  }) = _CartState;

  const CartState._();

  factory CartState.initial() => const CartState();

  factory CartState.loading() => const CartState(isLoading: true);

  factory CartState.error(String message) => CartState(error: message);

  factory CartState.loaded(List<CartItem> items, {Coupon? appliedCoupon, double discount = 0.0}) {
    double subtotal = 0.0;
    double shippingTotal = 0.0;
    int count = 0;
    
    // Only calculate totals from selected items
    for (final item in items) {
      if (item.isSelected) {
        subtotal += item.total;
        shippingTotal += item.shipping;
        count += item.quantity;
      }
    }
    
    final total = subtotal + shippingTotal - discount;
    
    return CartState(
      items: items,
      subtotal: subtotal,
      shipping: shippingTotal,
      total: total,
      itemCount: count,
      appliedCoupon: appliedCoupon,
      discount: discount,
    );
  }
  
  double get finalTotal => total;

  factory CartState.fromJson(Map<String, dynamic> json) => _$CartStateFromJson(json);
} 