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
      symbol: json['symbol'] as String?,
      chain: json['chain'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$SelectedNFTDtoToJson(SelectedNFTDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order': instance.order,
      'name': instance.name,
      'symbol': instance.symbol,
      'chain': instance.chain,
      'imageUrl': instance.imageUrl,
    };
