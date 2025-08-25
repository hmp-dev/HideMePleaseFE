// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInResponseDto _$CheckInResponseDtoFromJson(Map<String, dynamic> json) =>
    CheckInResponseDto(
      success: json['success'] as bool?,
      checkInId: json['checkInId'] as String?,
      groupProgress: json['groupProgress'] as String?,
      earnedPoints: (json['earnedPoints'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CheckInResponseDtoToJson(CheckInResponseDto instance) =>
    <String, dynamic>{
      'success': instance.success,
      'checkInId': instance.checkInId,
      'groupProgress': instance.groupProgress,
      'earnedPoints': instance.earnedPoints,
    };
