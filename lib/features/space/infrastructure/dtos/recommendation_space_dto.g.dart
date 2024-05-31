// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_space_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationSpaceDto _$RecommendationSpaceDtoFromJson(
        Map<String, dynamic> json) =>
    RecommendationSpaceDto(
      spaceId: json['spaceId'] as String?,
      spaceName: json['spaceName'] as String?,
      users: json['users'] as int?,
    );

Map<String, dynamic> _$RecommendationSpaceDtoToJson(
        RecommendationSpaceDto instance) =>
    <String, dynamic>{
      'spaceId': instance.spaceId,
      'spaceName': instance.spaceName,
      'users': instance.users,
    };
