// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mint_nft_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MintNftResponseDto _$MintNftResponseDtoFromJson(Map<String, dynamic> json) =>
    MintNftResponseDto(
      success: json['success'] as bool,
      nftId: json['nftId'] as String,
      tokenId: (json['tokenId'] as num).toInt(),
      tokenAddress: json['tokenAddress'] as String,
      transactionHash: json['transactionHash'] as String,
      imageUrl: json['imageUrl'] as String,
      chain: json['chain'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$MintNftResponseDtoToJson(MintNftResponseDto instance) =>
    <String, dynamic>{
      'success': instance.success,
      'nftId': instance.nftId,
      'tokenId': instance.tokenId,
      'tokenAddress': instance.tokenAddress,
      'transactionHash': instance.transactionHash,
      'imageUrl': instance.imageUrl,
      'chain': instance.chain,
      'message': instance.message,
    };
