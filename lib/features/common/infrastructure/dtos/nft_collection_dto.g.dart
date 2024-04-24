// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_collection_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftCollectionDto _$NftCollectionDtoFromJson(Map<String, dynamic> json) =>
    NftCollectionDto(
      tokenAddress: json['tokenAddress'] as String?,
      possibleSpam: json['possibleSpam'] as bool?,
      contractType: json['contractType'] as String?,
      name: json['name'] as String?,
      symbol: json['symbol'] as String?,
      verifiedCollection: json['verifiedCollection'] as bool?,
      collectionLogo: json['collectionLogo'] as String?,
      collectionBannerImage: json['collectionBannerImage'] as String?,
      chain: json['chain'] as String?,
      walletAddress: json['walletAddress'] as String?,
      tokens: (json['tokens'] as List<dynamic>?)
          ?.map((e) => NftTokenDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      chainSymbol: json['chainSymbol'] as String?,
    );

Map<String, dynamic> _$NftCollectionDtoToJson(NftCollectionDto instance) =>
    <String, dynamic>{
      'tokenAddress': instance.tokenAddress,
      'possibleSpam': instance.possibleSpam,
      'contractType': instance.contractType,
      'name': instance.name,
      'symbol': instance.symbol,
      'verifiedCollection': instance.verifiedCollection,
      'collectionLogo': instance.collectionLogo,
      'collectionBannerImage': instance.collectionBannerImage,
      'chain': instance.chain,
      'walletAddress': instance.walletAddress,
      'tokens': instance.tokens,
      'chainSymbol': instance.chainSymbol,
    };
