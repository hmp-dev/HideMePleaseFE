// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spaces_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpacesResponseDto _$SpacesResponseDtoFromJson(Map<String, dynamic> json) =>
    SpacesResponseDto(
      spaces: (json['spaces'] as List<dynamic>?)
          ?.map((e) => NearBySpaceDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      ambiguous: json['ambiguous'] as bool?,
    );

Map<String, dynamic> _$SpacesResponseDtoToJson(SpacesResponseDto instance) =>
    <String, dynamic>{
      'spaces': instance.spaces,
      'ambiguous': instance.ambiguous,
    };
