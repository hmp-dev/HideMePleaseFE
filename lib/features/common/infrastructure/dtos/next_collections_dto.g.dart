// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_collections_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NextCollectionsDto _$NextCollectionsDtoFromJson(Map<String, dynamic> json) =>
    NextCollectionsDto(
      type: json['type'] as String?,
      cursor: json['cursor'] as String?,
      nextWalletAddress: json['nextWalletAddress'] as String?,
    );

Map<String, dynamic> _$NextCollectionsDtoToJson(NextCollectionsDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'cursor': instance.cursor,
      'nextWalletAddress': instance.nextWalletAddress,
    };
