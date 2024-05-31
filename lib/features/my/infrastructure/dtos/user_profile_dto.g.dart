// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileDto _$UserProfileDtoFromJson(Map<String, dynamic> json) =>
    UserProfileDto(
      nickName: json['nickName'] as String?,
      introduction: json['introduction'] as String?,
      locationPublic: json['locationPublic'] as bool?,
      pfpNftId: json['pfpNftId'] as String?,
      pfpImageUrl: json['pfpImageUrl'] as String?,
    );

Map<String, dynamic> _$UserProfileDtoToJson(UserProfileDto instance) =>
    <String, dynamic>{
      'nickName': instance.nickName,
      'introduction': instance.introduction,
      'locationPublic': instance.locationPublic,
      'pfpNftId': instance.pfpNftId,
      'pfpImageUrl': instance.pfpImageUrl,
    };
