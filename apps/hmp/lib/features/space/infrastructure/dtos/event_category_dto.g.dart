// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_category_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventCategoryDto _$EventCategoryDtoFromJson(Map<String, dynamic> json) =>
    EventCategoryDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      nameEn: json['nameEn'] as String?,
      description: json['description'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
      colorCode: json['colorCode'] as String?,
      iconUrl: json['iconUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EventCategoryDtoToJson(EventCategoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameEn': instance.nameEn,
      'description': instance.description,
      'descriptionEn': instance.descriptionEn,
      'displayOrder': instance.displayOrder,
      'isActive': instance.isActive,
      'colorCode': instance.colorCode,
      'iconUrl': instance.iconUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
