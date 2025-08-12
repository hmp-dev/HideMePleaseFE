// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileDto _$UserProfileDtoFromJson(Map<String, dynamic> json) =>
    UserProfileDto(
      id: json['id'] as String?,
      nickName: json['nickName'] as String?,
      introduction: json['introduction'] as String?,
      locationPublic: json['locationPublic'] as bool?,
      notificationsEnabled: json['notificationsEnabled'] as bool?,
      chatAccessToken: json['chatAccessToken'] as String?,
      pfpNftId: json['pfpNftId'] as String?,
      pfpImageUrl: json['pfpImageUrl'] as String?,
      freeNftClaimed: json['freeNftClaimed'] as bool?,
      chatAppId: json['chatAppId'] as String?,
      profilePartsString: json['profilePartsString'] as String?,
      finalProfileImageUrl: json['finalProfileImageUrl'] as String?,
    );

Map<String, dynamic> _$UserProfileDtoToJson(UserProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickName': instance.nickName,
      'introduction': instance.introduction,
      'locationPublic': instance.locationPublic,
      'notificationsEnabled': instance.notificationsEnabled,
      'freeNftClaimed': instance.freeNftClaimed,
      'chatAccessToken': instance.chatAccessToken,
      'pfpNftId': instance.pfpNftId,
      'pfpImageUrl': instance.pfpImageUrl,
      'chatAppId': instance.chatAppId,
      'profilePartsString': instance.profilePartsString,
      'finalProfileImageUrl': instance.finalProfileImageUrl,
    };
