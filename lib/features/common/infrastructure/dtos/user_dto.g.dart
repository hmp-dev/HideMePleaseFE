// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
      id: json['id'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      deleted: json['deleted'] as bool?,
      wldNullifierHash: json['wldNullifierHash'] as String?,
      firebaseId: json['firebaseId'] as String?,
    );

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'deleted': instance.deleted,
      'wldNullifierHash': instance.wldNullifierHash,
      'firebaseId': instance.firebaseId,
    };
