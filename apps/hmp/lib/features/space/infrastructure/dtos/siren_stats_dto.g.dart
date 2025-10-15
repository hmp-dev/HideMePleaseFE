// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siren_stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SirenStatsDto _$SirenStatsDtoFromJson(Map<String, dynamic> json) =>
    SirenStatsDto(
      activeSirensCount: (json['activeSirensCount'] as num?)?.toInt(),
      totalSirensCount: (json['totalSirensCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SirenStatsDtoToJson(SirenStatsDto instance) =>
    <String, dynamic>{
      'activeSirensCount': instance.activeSirensCount,
      'totalSirensCount': instance.totalSirensCount,
    };
