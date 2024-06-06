import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/settings/domain/entities/settings_banner_entity.dart';

part 'settings_banner_dto.g.dart';

@JsonSerializable()
class SettingsBannerDto extends Equatable {
  @JsonKey(name: "settingsBannerLink")
  final String? settingsBannerLink;
  @JsonKey(name: "settingsBannerHeading")
  final String? settingsBannerHeading;
  @JsonKey(name: "settingsBannerDescription")
  final String? settingsBannerDescription;

  const SettingsBannerDto({
    this.settingsBannerLink,
    this.settingsBannerHeading,
    this.settingsBannerDescription,
  });

  factory SettingsBannerDto.fromJson(Map<String, dynamic> json) =>
      _$SettingsBannerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsBannerDtoToJson(this);

  @override
  List<Object?> get props => [
        settingsBannerLink,
        settingsBannerHeading,
        settingsBannerDescription,
      ];

  SettingsBannerEntity toEntity() => SettingsBannerEntity(
        settingsBannerLink: settingsBannerLink ?? "",
        settingsBannerHeading: settingsBannerHeading ?? "",
        settingsBannerDescription: settingsBannerDescription ?? "",
      );
}
