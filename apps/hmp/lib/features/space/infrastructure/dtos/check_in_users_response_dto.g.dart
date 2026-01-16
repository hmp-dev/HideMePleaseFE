// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_users_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInUsersResponseDto _$CheckInUsersResponseDtoFromJson(
        Map<String, dynamic> json) =>
    CheckInUsersResponseDto(
      totalCount: (json['totalCount'] as num).toInt(),
      users: (json['users'] as List<dynamic>)
          .map((e) => CheckInUserDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentGroup: json['currentGroup'] == null
          ? null
          : CurrentGroupDto.fromJson(
              json['currentGroup'] as Map<String, dynamic>),
      hasCheckedInToday: json['hasCheckedInToday'] as bool?,
      isUnlimitedUser: json['isUnlimitedUser'] as bool?,
    );

Map<String, dynamic> _$CheckInUsersResponseDtoToJson(
        CheckInUsersResponseDto instance) =>
    <String, dynamic>{
      'totalCount': instance.totalCount,
      'users': instance.users,
      'currentGroup': instance.currentGroup,
      'hasCheckedInToday': instance.hasCheckedInToday,
      'isUnlimitedUser': instance.isUnlimitedUser,
    };
