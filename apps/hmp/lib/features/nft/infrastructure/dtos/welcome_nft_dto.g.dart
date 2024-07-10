// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'welcome_nft_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WelcomeNftDto _$WelcomeNftDtoFromJson(Map<String, dynamic> json) =>
    WelcomeNftDto(
      id: json['id'] as int?,
      image: json['image'] as String?,
      totalCount: json['totalCount'] as int?,
      usedCount: json['usedCount'] as int?,
      name: json['name'] as String?,
      tokenAddress: json['tokenAddress'] as String?,
    );

Map<String, dynamic> _$WelcomeNftDtoToJson(WelcomeNftDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
      'totalCount': instance.totalCount,
      'usedCount': instance.usedCount,
      'name': instance.name,
      'tokenAddress': instance.tokenAddress,
    };
