// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpaceDetailDto _$SpaceDetailDtoFromJson(Map<String, dynamic> json) =>
    SpaceDetailDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      businessHoursStart: json['businessHoursStart'] as String?,
      businessHoursEnd: json['businessHoursEnd'] as String?,
      category: json['category'] as String?,
      introduction: json['introduction'] as String?,
      locationDescription: json['locationDescription'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$SpaceDetailDtoToJson(SpaceDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'businessHoursStart': instance.businessHoursStart,
      'businessHoursEnd': instance.businessHoursEnd,
      'category': instance.category,
      'introduction': instance.introduction,
      'locationDescription': instance.locationDescription,
      'image': instance.image,
    };
