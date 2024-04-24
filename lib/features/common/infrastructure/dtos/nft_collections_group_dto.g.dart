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
      next: json['next'] == null
          ? null
          : NextCollectionsDto.fromJson(json['next'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NftCollectionsGroupDtoToJson(
        NftCollectionsGroupDto instance) =>
    <String, dynamic>{
      'collections': instance.collections,
      'next': instance.next,
    };
