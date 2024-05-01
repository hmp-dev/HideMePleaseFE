// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseUserDto _$BaseUserDtoFromJson(Map<String, dynamic> json) => BaseUserDto(
      id: json['id'] as String?,
      wldNullifierHash: json['wldNullifierHash'] as String?,
      firebaseId: json['firebaseId'] as String?,
    );

Map<String, dynamic> _$BaseUserDtoToJson(BaseUserDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'wldNullifierHash': instance.wldNullifierHash,
      'firebaseId': instance.firebaseId,
    };
