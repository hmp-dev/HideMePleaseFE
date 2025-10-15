// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendListResponseDto _$FriendListResponseDtoFromJson(
        Map<String, dynamic> json) =>
    FriendListResponseDto(
      friends: (json['friends'] as List<dynamic>?)
          ?.map((e) => FriendshipDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FriendListResponseDtoToJson(
        FriendListResponseDto instance) =>
    <String, dynamic>{
      'friends': instance.friends,
      'pagination': instance.pagination,
    };
