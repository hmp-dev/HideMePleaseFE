// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpaceDetailDto _$SpaceDetailDtoFromJson(Map<String, dynamic> json) =>
    SpaceDetailDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      nameEn: json['nameEn'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      addressEn: json['addressEn'] as String?,
      businessHoursStart: json['businessHoursStart'] as String?,
      businessHoursEnd: json['businessHoursEnd'] as String?,
      category: json['category'] as String?,
      introduction: json['introduction'] as String?,
      introductionEn: json['introductionEn'] as String?,
      locationDescription: json['locationDescription'] as String?,
      image: json['image'] as String?,
      checkInCount: (json['checkInCount'] as num?)?.toInt(),
      spaceOpen: json['spaceOpen'] as bool?,
      checkedInUsers: (json['checkedInUsers'] as List<dynamic>?)
          ?.map((e) => CheckedInUserDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentGroupProgress: json['currentGroupProgress'] as String?,
    );

Map<String, dynamic> _$SpaceDetailDtoToJson(SpaceDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameEn': instance.nameEn,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'addressEn': instance.addressEn,
      'businessHoursStart': instance.businessHoursStart,
      'businessHoursEnd': instance.businessHoursEnd,
      'category': instance.category,
      'introduction': instance.introduction,
      'introductionEn': instance.introductionEn,
      'locationDescription': instance.locationDescription,
      'image': instance.image,
      'checkInCount': instance.checkInCount,
      'spaceOpen': instance.spaceOpen,
      'checkedInUsers': instance.checkedInUsers,
      'currentGroupProgress': instance.currentGroupProgress,
    };
