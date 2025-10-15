// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendshipDto _$FriendshipDtoFromJson(Map<String, dynamic> json) =>
    FriendshipDto(
      id: json['id'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String?,
      friend: json['friend'] == null
          ? null
          : FriendUserDto.fromJson(json['friend'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FriendshipDtoToJson(FriendshipDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'friend': instance.friend,
    };
