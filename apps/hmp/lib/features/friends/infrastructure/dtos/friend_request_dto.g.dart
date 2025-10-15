// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRequestDto _$FriendRequestDtoFromJson(Map<String, dynamic> json) =>
    FriendRequestDto(
      id: json['id'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String?,
      requester: json['requester'] == null
          ? null
          : FriendUserDto.fromJson(json['requester'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FriendRequestDtoToJson(FriendRequestDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'requester': instance.requester,
    };
