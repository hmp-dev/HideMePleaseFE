// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_event_category_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpaceEventCategoryDto _$SpaceEventCategoryDtoFromJson(
        Map<String, dynamic> json) =>
    SpaceEventCategoryDto(
      eventCategory: json['eventCategory'] == null
          ? null
          : EventCategoryDto.fromJson(
              json['eventCategory'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SpaceEventCategoryDtoToJson(
        SpaceEventCategoryDto instance) =>
    <String, dynamic>{
      'eventCategory': instance.eventCategory,
    };
