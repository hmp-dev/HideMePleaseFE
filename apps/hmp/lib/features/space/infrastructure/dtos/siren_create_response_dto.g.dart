// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siren_create_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SirenCreateResponseDto _$SirenCreateResponseDtoFromJson(
        Map<String, dynamic> json) =>
    SirenCreateResponseDto(
      success: json['success'] as bool?,
      sirenId: json['sirenId'] as String?,
      pointsSpent: (json['pointsSpent'] as num?)?.toInt(),
      remainingBalance: (json['remainingBalance'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SirenCreateResponseDtoToJson(
        SirenCreateResponseDto instance) =>
    <String, dynamic>{
      'success': instance.success,
      'sirenId': instance.sirenId,
      'pointsSpent': instance.pointsSpent,
      'remainingBalance': instance.remainingBalance,
    };
