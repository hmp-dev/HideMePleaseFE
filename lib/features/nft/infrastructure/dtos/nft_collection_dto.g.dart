// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_collection_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftCollectionDto _$NftCollectionDtoFromJson(Map<String, dynamic> json) =>
    NftCollectionDto(
      symbol: json['symbol'] as String?,
      chain: json['chain'] as String?,
      tokenAddress: json['tokenAddress'] as String?,
      contractType: json['contractType'] as String?,
      name: json['name'] as String?,
      collectionLogo: json['collectionLogo'] as String?,
      chainSymbol: json['chainSymbol'] as String?,
      tokens: (json['tokens'] as List<dynamic>?)
          ?.map((e) => NftTokenDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NftCollectionDtoToJson(NftCollectionDto instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'chain': instance.chain,
      'tokenAddress': instance.tokenAddress,
      'contractType': instance.contractType,
      'name': instance.name,
      'collectionLogo': instance.collectionLogo,
      'chainSymbol': instance.chainSymbol,
      'tokens': instance.tokens,
    };
