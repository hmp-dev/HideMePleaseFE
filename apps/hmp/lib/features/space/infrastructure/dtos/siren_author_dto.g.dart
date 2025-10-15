// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siren_author_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SirenAuthorDto _$SirenAuthorDtoFromJson(Map<String, dynamic> json) =>
    SirenAuthorDto(
      userId: json['userId'] as String?,
      nickName: json['nickName'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      finalProfileImageUrl: json['finalProfileImageUrl'] as String?,
      pfpImageUrl: json['pfpImageUrl'] as String?,
    );

Map<String, dynamic> _$SirenAuthorDtoToJson(SirenAuthorDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickName': instance.nickName,
      'profileImageUrl': instance.profileImageUrl,
      'finalProfileImageUrl': instance.finalProfileImageUrl,
      'pfpImageUrl': instance.pfpImageUrl,
    };
