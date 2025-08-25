// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checked_in_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckedInUserDto _$CheckedInUserDtoFromJson(Map<String, dynamic> json) =>
    CheckedInUserDto(
      userId: json['userId'] as String?,
      nickName: json['nickName'] as String?,
      checkedInAt: json['checkedInAt'] as String?,
    );

Map<String, dynamic> _$CheckedInUserDtoToJson(CheckedInUserDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickName': instance.nickName,
      'checkedInAt': instance.checkedInAt,
    };
