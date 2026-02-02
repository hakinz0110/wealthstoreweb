import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner.freezed.dart';
part 'banner.g.dart';

@freezed
class Banner with _$Banner {
  const factory Banner({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'image_path') required String imagePath,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Banner;

  factory Banner.fromJson(Map<String, dynamic> json) => _$BannerFromJson(json);
}

@freezed
class BannerFormData with _$BannerFormData {
  const factory BannerFormData({
    required String title,
    String? description,
    @JsonKey(name: 'image_path') required String imagePath,
  }) = _BannerFormData;

  factory BannerFormData.fromJson(Map<String, dynamic> json) => _$BannerFormDataFromJson(json);
  
  factory BannerFormData.empty() {
    return const BannerFormData(
      title: '',
      imagePath: '',
    );
  }
  
  factory BannerFormData.fromBanner(Banner banner) {
    return BannerFormData(
      title: banner.title,
      description: banner.description,
      imagePath: banner.imagePath,
    );
  }
}