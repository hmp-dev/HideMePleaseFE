// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_banner_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelBannerDto _$ModelBannerDtoFromJson(Map<String, dynamic> json) =>
    ModelBannerDto(
      image: json['image'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
    );

Map<String, dynamic> _$ModelBannerDtoToJson(ModelBannerDto instance) =>
    <String, dynamic>{
      'image': instance.image,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
    };
