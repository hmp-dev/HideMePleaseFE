// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_used_nft_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopUsedNftDto _$TopUsedNftDtoFromJson(Map<String, dynamic> json) =>
    TopUsedNftDto(
      pointFluctuation: (json['pointFluctuation'] as num?)?.toInt(),
      totalPoints: (json['totalPoints'] as num?)?.toInt(),
      tokenAddress: json['tokenAddress'] as String?,
      totalMembers: (json['totalMembers'] as num?)?.toInt(),
      communityRank: (json['communityRank'] as num?)?.toInt(),
      collectionLogo: json['collectionLogo'] as String?,
      name: json['name'] as String?,
      chain: json['chain'] as String?,
      ownedCollection: json['ownedCollection'] as bool?,
    );

Map<String, dynamic> _$TopUsedNftDtoToJson(TopUsedNftDto instance) =>
    <String, dynamic>{
      'pointFluctuation': instance.pointFluctuation,
      'totalPoints': instance.totalPoints,
      'tokenAddress': instance.tokenAddress,
      'totalMembers': instance.totalMembers,
      'communityRank': instance.communityRank,
      'collectionLogo': instance.collectionLogo,
      'name': instance.name,
      'chain': instance.chain,
      'ownedCollection': instance.ownedCollection,
    };
