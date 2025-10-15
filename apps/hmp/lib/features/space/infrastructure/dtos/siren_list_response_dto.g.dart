// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siren_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SirenListResponseDto _$SirenListResponseDtoFromJson(
        Map<String, dynamic> json) =>
    SirenListResponseDto(
      sirens: (json['sirens'] as List<dynamic>?)
          ?.map((e) => SirenDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : SirenPaginationDto.fromJson(
              json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SirenListResponseDtoToJson(
        SirenListResponseDto instance) =>
    <String, dynamic>{
      'sirens': instance.sirens,
      'pagination': instance.pagination,
    };
