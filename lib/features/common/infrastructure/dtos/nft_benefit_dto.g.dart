// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_benefit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftBenefitDto _$NftBenefitDtoFromJson(Map<String, dynamic> json) =>
    NftBenefitDto(
      id: json['id'] as String?,
      description: json['description'] as String?,
      singleUse: json['singleUse'] as bool?,
      spaceId: json['spaceId'] as String?,
      spaceName: json['spaceName'] as String?,
      spaceImage: json['spaceImage'] as String?,
      used: json['used'] as bool?,
    );

Map<String, dynamic> _$NftBenefitDtoToJson(NftBenefitDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'singleUse': instance.singleUse,
      'spaceId': instance.spaceId,
      'spaceName': instance.spaceName,
      'spaceImage': instance.spaceImage,
      'used': instance.used,
    };
