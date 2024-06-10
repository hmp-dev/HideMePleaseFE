// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftBenefitsResponseDto _$NftBenefitsResponseDtoFromJson(
        Map<String, dynamic> json) =>
    NftBenefitsResponseDto(
      benefits: (json['benefits'] as List<dynamic>?)
          ?.map((e) => BenefitDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      benefitCount: json['benefitCount'] as int,
    );

Map<String, dynamic> _$NftBenefitsResponseDtoToJson(
        NftBenefitsResponseDto instance) =>
    <String, dynamic>{
      'benefits': instance.benefits,
      'benefitCount': instance.benefitCount,
    };

BenefitDto _$BenefitDtoFromJson(Map<String, dynamic> json) => BenefitDto(
      id: json['id'] as String?,
      description: json['description'] as String?,
      singleUse: json['singleUse'] as bool?,
      spaceId: json['spaceId'] as String?,
      spaceName: json['spaceName'] as String?,
      spaceImage: json['spaceImage'] as String?,
      used: json['used'] as bool?,
      tokenAddress: json['tokenAddress'] as String?,
    );

Map<String, dynamic> _$BenefitDtoToJson(BenefitDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'singleUse': instance.singleUse,
      'spaceId': instance.spaceId,
      'spaceName': instance.spaceName,
      'spaceImage': instance.spaceImage,
      'used': instance.used,
      'tokenAddress': instance.tokenAddress,
    };
