// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_hours_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessHoursDto _$BusinessHoursDtoFromJson(Map<String, dynamic> json) =>
    BusinessHoursDto(
      dayOfWeek: json['dayOfWeek'] as String?,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      breakStartTime: json['breakStartTime'] as String?,
      breakEndTime: json['breakEndTime'] as String?,
      isClosed: json['isClosed'] as bool?,
    );

Map<String, dynamic> _$BusinessHoursDtoToJson(BusinessHoursDto instance) =>
    <String, dynamic>{
      'dayOfWeek': instance.dayOfWeek,
      'openTime': instance.openTime,
      'closeTime': instance.closeTime,
      'breakStartTime': instance.breakStartTime,
      'breakEndTime': instance.breakEndTime,
      'isClosed': instance.isClosed,
    };
