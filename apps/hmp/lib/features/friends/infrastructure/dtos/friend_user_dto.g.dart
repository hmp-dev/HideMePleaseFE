// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendUserDto _$FriendUserDtoFromJson(Map<String, dynamic> json) =>
    FriendUserDto(
      userId: json['userId'] as String?,
      nickName: json['nickName'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      introduction: json['introduction'] as String?,
    );

Map<String, dynamic> _$FriendUserDtoToJson(FriendUserDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickName': instance.nickName,
      'profileImageUrl': instance.profileImageUrl,
      'introduction': instance.introduction,
    };
