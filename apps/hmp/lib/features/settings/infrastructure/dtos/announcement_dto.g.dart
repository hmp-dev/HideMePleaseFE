// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnnouncementDto _$AnnouncementDtoFromJson(Map<String, dynamic> json) =>
    AnnouncementDto(
      id: json['id'] as String?,
      createdAt: json['createdAt'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$AnnouncementDtoToJson(AnnouncementDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'title': instance.title,
      'description': instance.description,
    };
