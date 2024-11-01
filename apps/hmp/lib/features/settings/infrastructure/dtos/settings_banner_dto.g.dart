// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_banner_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsBannerDto _$SettingsBannerDtoFromJson(Map<String, dynamic> json) =>
    SettingsBannerDto(
      settingsBannerLink: json['settingsBannerLink'] as String?,
      settingsBannerHeading: json['settingsBannerHeading'] as String?,
      settingsBannerDescription: json['settingsBannerDescription'] as String?,
      settingsBannerDescriptionEn:
          json['settingsBannerDescriptionEn'] as String?,
      settingsBannerHeadingEn: json['settingsBannerHeadingEn'] as String?,
    );

Map<String, dynamic> _$SettingsBannerDtoToJson(SettingsBannerDto instance) =>
    <String, dynamic>{
      'settingsBannerLink': instance.settingsBannerLink,
      'settingsBannerHeading': instance.settingsBannerHeading,
      'settingsBannerDescription': instance.settingsBannerDescription,
      'settingsBannerDescriptionEn': instance.settingsBannerDescriptionEn,
      'settingsBannerHeadingEn': instance.settingsBannerHeadingEn,
    };
