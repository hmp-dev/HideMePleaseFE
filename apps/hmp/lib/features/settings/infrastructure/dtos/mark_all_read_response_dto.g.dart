// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mark_all_read_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarkAllReadResponseDto _$MarkAllReadResponseDtoFromJson(
        Map<String, dynamic> json) =>
    MarkAllReadResponseDto(
      success: json['success'] as bool?,
      updatedCount: (json['updatedCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MarkAllReadResponseDtoToJson(
        MarkAllReadResponseDto instance) =>
    <String, dynamic>{
      'success': instance.success,
      'updatedCount': instance.updatedCount,
    };
