// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_check_in_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActiveCheckInDto _$ActiveCheckInDtoFromJson(Map<String, dynamic> json) =>
    ActiveCheckInDto(
      spaceId: json['spaceId'] as String,
      spaceName: json['spaceName'] as String,
      checkedInAt: json['checkedInAt'] as String,
    );

Map<String, dynamic> _$ActiveCheckInDtoToJson(ActiveCheckInDto instance) =>
    <String, dynamic>{
      'spaceId': instance.spaceId,
      'spaceName': instance.spaceName,
      'checkedInAt': instance.checkedInAt,
    };
