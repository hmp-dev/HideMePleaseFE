// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_community_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftCommunityResponseDto _$NftCommunityResponseDtoFromJson(
        Map<String, dynamic> json) =>
    NftCommunityResponseDto(
      communityCount: json['communityCount'] as int?,
      itemCount: json['itemCount'] as int?,
      allCommunities: (json['allCommunities'] as List<dynamic>?)
          ?.map((e) => NftCommunitytDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NftCommunityResponseDtoToJson(
        NftCommunityResponseDto instance) =>
    <String, dynamic>{
      'communityCount': instance.communityCount,
      'itemCount': instance.itemCount,
      'allCommunities': instance.allCommunities,
    };

NftCommunitytDto _$NftCommunitytDtoFromJson(Map<String, dynamic> json) =>
    NftCommunitytDto(
      communityRank: json['communityRank'] as int?,
      totalMembers: json['totalMembers'] as int?,
      tokenAddress: json['tokenAddress'] as String?,
      name: json['name'] as String?,
      collectionLogo: json['collectionLogo'] as String?,
      chain: json['chain'] as String?,
      lastConversation: json['lastConversation'] as String?,
      eventCount: json['eventCount'] as int?,
    );

Map<String, dynamic> _$NftCommunitytDtoToJson(NftCommunitytDto instance) =>
    <String, dynamic>{
      'communityRank': instance.communityRank,
      'totalMembers': instance.totalMembers,
      'tokenAddress': instance.tokenAddress,
      'name': instance.name,
      'collectionLogo': instance.collectionLogo,
      'chain': instance.chain,
      'lastConversation': instance.lastConversation,
      'eventCount': instance.eventCount,
    };
