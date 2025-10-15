// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendStatsDto _$FriendStatsDtoFromJson(Map<String, dynamic> json) =>
    FriendStatsDto(
      totalFriends: (json['totalFriends'] as num?)?.toInt(),
      receivedRequests: (json['receivedRequests'] as num?)?.toInt(),
      sentRequests: (json['sentRequests'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FriendStatsDtoToJson(FriendStatsDto instance) =>
    <String, dynamic>{
      'totalFriends': instance.totalFriends,
      'receivedRequests': instance.receivedRequests,
      'sentRequests': instance.sentRequests,
    };
