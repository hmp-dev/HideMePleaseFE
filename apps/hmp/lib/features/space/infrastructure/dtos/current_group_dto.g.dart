// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_group_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentGroupDto _$CurrentGroupDtoFromJson(Map<String, dynamic> json) =>
    CurrentGroupDto(
      groupId: json['groupId'] as String,
      progress: json['progress'] as String,
      isCompleted: json['isCompleted'] as bool,
      members: (json['members'] as List<dynamic>)
          .map((e) => CheckInUserDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      bonusPoints: (json['bonusPoints'] as num).toInt(),
    );

Map<String, dynamic> _$CurrentGroupDtoToJson(CurrentGroupDto instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'progress': instance.progress,
      'isCompleted': instance.isCompleted,
      'members': instance.members,
      'bonusPoints': instance.bonusPoints,
    };
