// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BannerImpl _$$BannerImplFromJson(Map<String, dynamic> json) => _$BannerImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imagePath: json['image_path'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$BannerImplToJson(_$BannerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'image_path': instance.imagePath,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$BannerFormDataImpl _$$BannerFormDataImplFromJson(Map<String, dynamic> json) =>
    _$BannerFormDataImpl(
      title: json['title'] as String,
      description: json['description'] as String?,
      imagePath: json['image_path'] as String,
    );

Map<String, dynamic> _$$BannerFormDataImplToJson(
        _$BannerFormDataImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'image_path': instance.imagePath,
    };
