// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_network_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftNetworkDto _$NftNetworkDtoFromJson(Map<String, dynamic> json) =>
    NftNetworkDto(
      network: json['network'] as String?,
      holderCount: json['holderCount'] as String?,
      floorPrice: json['floorPrice'] as int?,
    );

Map<String, dynamic> _$NftNetworkDtoToJson(NftNetworkDto instance) =>
    <String, dynamic>{
      'network': instance.network,
      'holderCount': instance.holderCount,
      'floorPrice': instance.floorPrice,
    };
