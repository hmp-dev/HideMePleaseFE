// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpaceDto _$SpaceDtoFromJson(Map<String, dynamic> json) => SpaceDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
      category: json['category'] as String?,
      benefitDescription: json['benefitDescription'] as String?,
      hot: json['hot'] as bool?,
      hotPoints: json['hotPoints'] as int?,
      hidingCount: json['hidingCount'] as int?,
    );

Map<String, dynamic> _$SpaceDtoToJson(SpaceDto instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'category': instance.category,
      'benefitDescription': instance.benefitDescription,
      'hot': instance.hot,
      'hotPoints': instance.hotPoints,
      'hidingCount': instance.hidingCount,
    };
