// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationDto _$NotificationDtoFromJson(Map<String, dynamic> json) =>
    NotificationDto(
      id: json['id'] as String?,
      createdAt: json['createdAt'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      type: json['type'] as String?,
      params: json['params'] as String?,
    );

Map<String, dynamic> _$NotificationDtoToJson(NotificationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'title': instance.title,
      'body': instance.body,
      'type': instance.type,
      'params': instance.params,
    };
