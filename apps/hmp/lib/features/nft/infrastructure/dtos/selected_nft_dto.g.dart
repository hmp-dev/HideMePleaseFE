// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_nft_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectedNFTDto _$SelectedNFTDtoFromJson(Map<String, dynamic> json) =>
    SelectedNFTDto(
      id: json['id'] as String?,
      order: json['order'] as int?,
      name: json['name'] as String?,
      tokenAddress: json['tokenAddress'] as String?,
      symbol: json['symbol'] as String?,
      chain: json['chain'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      totalPoints: json['totalPoints'] as int?,
      communityRank: json['communityRank'] as int?,
      totalMembers: json['totalMembers'] as int?,
      pointFluctuation: json['pointFluctuation'] as int?,
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
    };
