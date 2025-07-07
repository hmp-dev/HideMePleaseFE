// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'welcome_nft_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WelcomeNftDto _$WelcomeNftDtoFromJson(Map<String, dynamic> json) =>
    WelcomeNftDto(
      id: (json['id'] as num?)?.toInt(),
      image: json['image'] as String?,
      totalCount: (json['totalCount'] as num?)?.toInt(),
      usedCount: (json['usedCount'] as num?)?.toInt(),
      name: json['name'] as String?,
      tokenAddress: json['tokenAddress'] as String?,
      redeemTermsUrl: json['redeemTermsUrl'] as String?,
      freeNftAvailable: json['freeNftAvailable'] as bool?,
      contractType: json['contractType'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$WelcomeNftDtoToJson(WelcomeNftDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
      'totalCount': instance.totalCount,
      'usedCount': instance.usedCount,
      'name': instance.name,
      'tokenAddress': instance.tokenAddress,
      'redeemTermsUrl': instance.redeemTermsUrl,
      'freeNftAvailable': instance.freeNftAvailable,
      'contractType': instance.contractType,
      'type': instance.type,
    };
