// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_collection_nft_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopCollectionNftDto _$TopCollectionNftDtoFromJson(Map<String, dynamic> json) =>
    TopCollectionNftDto(
      pointFluctuation: (json['pointFluctuation'] as num?)?.toInt(),
      totalPoints: (json['totalPoints'] as num?)?.toInt(),
      totalMembers: (json['totalMembers'] as num?)?.toInt(),
      tokenAddress: json['tokenAddress'] as String?,
      collectionLogo: json['collectionLogo'] as String?,
      name: json['name'] as String?,
      chain: json['chain'] as String?,
      ownedCollection: json['ownedCollection'] as bool?,
      communityRank: (json['communityRank'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TopCollectionNftDtoToJson(
        TopCollectionNftDto instance) =>
    <String, dynamic>{
      'pointFluctuation': instance.pointFluctuation,
      'totalPoints': instance.totalPoints,
      'totalMembers': instance.totalMembers,
      'tokenAddress': instance.tokenAddress,
      'collectionLogo': instance.collectionLogo,
      'name': instance.name,
      'chain': instance.chain,
      'ownedCollection': instance.ownedCollection,
      'communityRank': instance.communityRank,
    };
