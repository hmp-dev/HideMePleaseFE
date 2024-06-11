// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_used_nft_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopUsedNftDto _$TopUsedNftDtoFromJson(Map<String, dynamic> json) =>
    TopUsedNftDto(
      pointFluctuation: json['pointFluctuation'] as int?,
      totalPoints: json['totalPoints'] as int?,
      tokenAddress: json['tokenAddress'] as String?,
      totalMembers: json['totalMembers'] as int?,
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
      'collectionLogo': instance.collectionLogo,
      'name': instance.name,
      'chain': instance.chain,
      'ownedCollection': instance.ownedCollection,
    };
