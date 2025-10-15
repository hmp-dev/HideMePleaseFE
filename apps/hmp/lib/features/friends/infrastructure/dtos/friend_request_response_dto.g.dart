// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRequestResponseDto _$FriendRequestResponseDtoFromJson(
        Map<String, dynamic> json) =>
    FriendRequestResponseDto(
      requests: (json['requests'] as List<dynamic>?)
          ?.map((e) => FriendRequestDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FriendRequestResponseDtoToJson(
        FriendRequestResponseDto instance) =>
    <String, dynamic>{
      'requests': instance.requests,
      'pagination': instance.pagination,
    };
