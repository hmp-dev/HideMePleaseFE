// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_points_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftPointsDto _$NftPointsDtoFromJson(Map<String, dynamic> json) => NftPointsDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      tokenAddress: json['tokenAddress'] as String?,
      totalPoints: json['totalPoints'] as int?,
    );

Map<String, dynamic> _$NftPointsDtoToJson(NftPointsDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'tokenAddress': instance.tokenAddress,
      'totalPoints': instance.totalPoints,
    };
