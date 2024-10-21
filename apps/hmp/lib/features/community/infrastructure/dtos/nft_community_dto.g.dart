// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_community_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftCommunityResponseDto _$NftCommunityResponseDtoFromJson(
        Map<String, dynamic> json) =>
    NftCommunityResponseDto(
      communityCount: (json['communityCount'] as num?)?.toInt(),
      itemCount: (json['itemCount'] as num?)?.toInt(),
      allCommunities: (json['allCommunities'] as List<dynamic>?)
          ?.map((e) => NftCommunityDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NftCommunityResponseDtoToJson(
        NftCommunityResponseDto instance) =>
    <String, dynamic>{
      'communityCount': instance.communityCount,
      'itemCount': instance.itemCount,
      'allCommunities': instance.allCommunities,
    };

NftCommunityDto _$NftCommunityDtoFromJson(Map<String, dynamic> json) =>
    NftCommunityDto(
      communityRank: (json['communityRank'] as num?)?.toInt(),
      totalMembers: (json['totalMembers'] as num?)?.toInt(),
      tokenAddress: json['tokenAddress'] as String?,
      name: json['name'] as String?,
      collectionLogo: json['collectionLogo'] as String?,
      chain: json['chain'] as String?,
      lastConversation: json['lastConversation'] as String?,
    );

Map<String, dynamic> _$NftCommunityDtoToJson(NftCommunityDto instance) =>
    <String, dynamic>{
      'communityRank': instance.communityRank,
      'totalMembers': instance.totalMembers,
      'tokenAddress': instance.tokenAddress,
      'name': instance.name,
      'collectionLogo': instance.collectionLogo,
      'chain': instance.chain,
      'lastConversation': instance.lastConversation,
    };
