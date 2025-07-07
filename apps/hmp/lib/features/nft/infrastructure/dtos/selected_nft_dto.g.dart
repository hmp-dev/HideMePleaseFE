// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_nft_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectedNFTDto _$SelectedNFTDtoFromJson(Map<String, dynamic> json) =>
    SelectedNFTDto(
      id: json['id'] as String?,
      order: (json['order'] as num?)?.toInt(),
      name: json['name'] as String?,
      tokenAddress: json['tokenAddress'] as String?,
      symbol: json['symbol'] as String?,
      chain: json['chain'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      totalPoints: (json['totalPoints'] as num?)?.toInt(),
      communityRank: (json['communityRank'] as num?)?.toInt(),
      totalMembers: (json['totalMembers'] as num?)?.toInt(),
      pointFluctuation: (json['pointFluctuation'] as num?)?.toInt(),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$SelectedNFTDtoToJson(SelectedNFTDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'order': instance.order,
      'tokenAddress': instance.tokenAddress,
      'symbol': instance.symbol,
      'chain': instance.chain,
      'totalPoints': instance.totalPoints,
      'communityRank': instance.communityRank,
      'totalMembers': instance.totalMembers,
      'pointFluctuation': instance.pointFluctuation,
      'type': instance.type,
    };
