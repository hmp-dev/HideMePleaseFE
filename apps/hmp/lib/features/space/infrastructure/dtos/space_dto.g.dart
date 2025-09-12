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
      hotPoints: (json['hotPoints'] as num?)?.toInt(),
      hidingCount: (json['hidingCount'] as num?)?.toInt(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      businessHours: (json['SpaceBusinessHours'] as List<dynamic>?)
          ?.map((e) => BusinessHoursDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      isTemporarilyClosed: json['isTemporarilyClosed'] as bool?,
      spaceEventCategories: (json['SpaceEventCategory'] as List<dynamic>?)
          ?.map(
              (e) => SpaceEventCategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentGroupProgress: json['currentGroupProgress'] as String?,
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
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'SpaceBusinessHours': instance.businessHours,
      'isTemporarilyClosed': instance.isTemporarilyClosed,
      'SpaceEventCategory': instance.spaceEventCategories,
      'currentGroupProgress': instance.currentGroupProgress,
    };
