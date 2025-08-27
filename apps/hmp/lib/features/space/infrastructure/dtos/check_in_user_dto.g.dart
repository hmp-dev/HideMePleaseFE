// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInUserDto _$CheckInUserDtoFromJson(Map<String, dynamic> json) =>
    CheckInUserDto(
      userId: json['userId'] as String,
      nickName: json['nickName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      checkedInAt: DateTime.parse(json['checkedInAt'] as String),
    );

Map<String, dynamic> _$CheckInUserDtoToJson(CheckInUserDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickName': instance.nickName,
      'profileImageUrl': instance.profileImageUrl,
      'checkedInAt': instance.checkedInAt.toIso8601String(),
    };
