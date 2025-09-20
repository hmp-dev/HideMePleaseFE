// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'near_by_space_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NearBySpaceDto _$NearBySpaceDtoFromJson(Map<String, dynamic> json) =>
    NearBySpaceDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      nameEn: json['nameEn'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      image: json['image'] as String?,
      distance: (json['distance'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NearBySpaceDtoToJson(NearBySpaceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameEn': instance.nameEn,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'image': instance.image,
      'distance': instance.distance,
    };
