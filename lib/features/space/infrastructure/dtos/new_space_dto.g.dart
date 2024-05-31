// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_space_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewSpaceDto _$NewSpaceDtoFromJson(Map<String, dynamic> json) => NewSpaceDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
      mainBenefitDescription: json['mainBenefitDescription'] as String?,
      remainingBenefitCount: json['remainingBenefitCount'] as int?,
      hidingCount: json['hidingCount'] as int?,
    );

Map<String, dynamic> _$NewSpaceDtoToJson(NewSpaceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'mainBenefitDescription': instance.mainBenefitDescription,
      'remainingBenefitCount': instance.remainingBenefitCount,
      'hidingCount': instance.hidingCount,
    };
