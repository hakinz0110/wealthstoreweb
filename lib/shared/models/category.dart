import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

// Custom converter to handle both String and int for IDs
class FlexibleIntConverter implements JsonConverter<int, dynamic> {
  const FlexibleIntConverter();

  @override
  int fromJson(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  @override
  dynamic toJson(int value) => value;
}

@JsonSerializable()
class Category {
  @FlexibleIntConverter()
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'product_count')
  final int productCount;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.iconUrl,
    this.isActive = true,
    this.productCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  Category copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    String? iconUrl,
    bool? isActive,
    int? productCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 