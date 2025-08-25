// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_status_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInStatusDto _$CheckInStatusDtoFromJson(Map<String, dynamic> json) =>
    CheckInStatusDto(
      isCheckedIn: json['isCheckedIn'] as bool?,
      checkedInAt: json['checkedInAt'] as String?,
      groupProgress: json['groupProgress'] as String?,
      earnedPoints: (json['earnedPoints'] as num?)?.toInt(),
      groupId: json['groupId'] as String?,
    );

Map<String, dynamic> _$CheckInStatusDtoToJson(CheckInStatusDto instance) =>
    <String, dynamic>{
      'isCheckedIn': instance.isCheckedIn,
      'checkedInAt': instance.checkedInAt,
      'groupProgress': instance.groupProgress,
      'earnedPoints': instance.earnedPoints,
      'groupId': instance.groupId,
    };
