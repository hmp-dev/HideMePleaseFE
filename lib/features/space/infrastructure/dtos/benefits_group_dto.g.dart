// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefits_group_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BenefitsGroupDto _$BenefitsGroupDtoFromJson(Map<String, dynamic> json) =>
    BenefitsGroupDto(
      benefits: (json['benefits'] as List<dynamic>?)
          ?.map((e) => BenefitDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      next: json['next'] as String?,
    );

Map<String, dynamic> _$BenefitsGroupDtoToJson(BenefitsGroupDto instance) =>
    <String, dynamic>{
      'benefits': instance.benefits,
      'next': instance.next,
    };
