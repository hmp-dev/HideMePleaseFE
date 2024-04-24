// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_token_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftTokenDto _$NftTokenDtoFromJson(Map<String, dynamic> json) => NftTokenDto(
      tokenId: json['tokenId'] as String?,
      name: json['name'] as String?,
      imageUrl: json['imageUrl'] as String?,
      selected: json['selected'] as bool?,
    );

Map<String, dynamic> _$NftTokenDtoToJson(NftTokenDto instance) =>
    <String, dynamic>{
      'tokenId': instance.tokenId,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'selected': instance.selected,
    };
