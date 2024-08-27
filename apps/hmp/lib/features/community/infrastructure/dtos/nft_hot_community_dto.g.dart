// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_hot_community_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftHotCommunityDto _$NftHotCommunityDtoFromJson(Map<String, dynamic> json) =>
    NftHotCommunityDto(
      tokenAddress: json['tokenAddress'] as String?,
      name: json['name'] as String?,
      collectionLogo: json['collectionLogo'] as String?,
      chain: json['chain'] as String?,
    );

Map<String, dynamic> _$NftHotCommunityDtoToJson(NftHotCommunityDto instance) =>
    <String, dynamic>{
      'tokenAddress': instance.tokenAddress,
      'name': instance.name,
      'collectionLogo': instance.collectionLogo,
      'chain': instance.chain,
    };
