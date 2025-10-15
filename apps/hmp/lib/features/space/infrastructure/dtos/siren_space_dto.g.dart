// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siren_space_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SirenSpaceDto _$SirenSpaceDtoFromJson(Map<String, dynamic> json) =>
    SirenSpaceDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      nameEn: json['nameEn'] as String?,
      image: json['image'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      category: json['category'] as String?,
    );

Map<String, dynamic> _$SirenSpaceDtoToJson(SirenSpaceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameEn': instance.nameEn,
      'image': instance.image,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'category': instance.category,
    };
