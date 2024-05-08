// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_token_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftTokenDto _$NftTokenDtoFromJson(Map<String, dynamic> json) => NftTokenDto(
      id: json['id'] as String?,
      tokenId: json['tokenId'] as String?,
      name: json['name'] as String?,
      imageUrl: json['imageUrl'] as String?,
      selected: json['selected'] as bool?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$NftTokenDtoToJson(NftTokenDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tokenId': instance.tokenId,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'selected': instance.selected,
      'updatedAt': instance.updatedAt,
    };
