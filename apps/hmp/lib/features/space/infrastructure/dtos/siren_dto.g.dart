// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siren_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SirenDto _$SirenDtoFromJson(Map<String, dynamic> json) => SirenDto(
      id: json['id'] as String?,
      message: json['message'] as String?,
      createdAt: json['createdAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      pointsSpent: (json['pointsSpent'] as num?)?.toInt(),
      remainingDays: (json['remainingDays'] as num?)?.toInt(),
      space: json['space'] == null
          ? null
          : SirenSpaceDto.fromJson(json['space'] as Map<String, dynamic>),
      author: json['author'] == null
          ? null
          : SirenAuthorDto.fromJson(json['author'] as Map<String, dynamic>),
      distance: (json['distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SirenDtoToJson(SirenDto instance) => <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'createdAt': instance.createdAt,
      'expiresAt': instance.expiresAt,
      'pointsSpent': instance.pointsSpent,
      'remainingDays': instance.remainingDays,
      'space': instance.space,
      'author': instance.author,
      'distance': instance.distance,
    };
