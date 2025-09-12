// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mint_nft_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MintNftRequestDto _$MintNftRequestDtoFromJson(Map<String, dynamic> json) =>
    MintNftRequestDto(
      walletAddress: json['walletAddress'] as String,
      imageUrl: json['imageUrl'] as String,
      metadataUrl: json['metadataUrl'] as String,
    );

Map<String, dynamic> _$MintNftRequestDtoToJson(MintNftRequestDto instance) =>
    <String, dynamic>{
      'walletAddress': instance.walletAddress,
      'imageUrl': instance.imageUrl,
      'metadataUrl': instance.metadataUrl,
    };
