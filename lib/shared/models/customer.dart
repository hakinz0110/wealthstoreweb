import 'package:json_annotation/json_annotation.dart';

part 'customer.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Customer {
  final String id;
  final String? fullName;
  final String? email; // Made nullable - may not exist in DB
  final String? phoneNumber;
  final String? avatarUrl;
  final Map<String, dynamic>? preferences;
  final DateTime? createdAt; // Made nullable for safety

  const Customer({
    required this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.preferences,
    this.createdAt,
  });

  Customer copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);
} 