// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siren_pagination_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SirenPaginationDto _$SirenPaginationDtoFromJson(Map<String, dynamic> json) =>
    SirenPaginationDto(
      page: (json['page'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SirenPaginationDtoToJson(SirenPaginationDto instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'totalPages': instance.totalPages,
    };
