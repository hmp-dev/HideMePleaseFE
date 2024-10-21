// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_collections_group_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftCollectionsGroupDto _$NftCollectionsGroupDtoFromJson(
        Map<String, dynamic> json) =>
    NftCollectionsGroupDto(
      collections: (json['collections'] as List<dynamic>?)
          ?.map((e) => NftCollectionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedNftCount: (json['selectedNftCount'] as num?)?.toInt(),
      next: json['next'] as String?,
    );

Map<String, dynamic> _$NftCollectionsGroupDtoToJson(
        NftCollectionsGroupDto instance) =>
    <String, dynamic>{
      'collections': instance.collections,
      'selectedNftCount': instance.selectedNftCount,
      'next': instance.next,
    };
