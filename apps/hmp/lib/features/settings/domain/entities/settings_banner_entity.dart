import 'package:equatable/equatable.dart';

class SettingsBannerEntity extends Equatable {
  final String settingsBannerLink;
  final String settingsBannerHeading;
  final String settingsBannerDescription;
  final String settingsBannerDescriptionEn;
  final String settingsBannerHeadingEn;

  const SettingsBannerEntity({
    required this.settingsBannerLink,
    required this.settingsBannerHeading,
    required this.settingsBannerDescription,
    required this.settingsBannerDescriptionEn,
    required this.settingsBannerHeadingEn,
  });

  @override
  List<Object?> get props => [
        settingsBannerLink,
        settingsBannerHeading,
        settingsBannerDescription,
        settingsBannerDescriptionEn,
        settingsBannerHeadingEn,
      ];

  const SettingsBannerEntity.empty()
      : settingsBannerLink = '',
        settingsBannerHeading = '',
        settingsBannerDescription = '',
        settingsBannerDescriptionEn = '',
        settingsBannerHeadingEn = '';

  SettingsBannerEntity copyWith({
    String? settingsBannerLink,
    String? settingsBannerHeading,
    String? settingsBannerDescription,
    String? settingsBannerDescriptionEn,
    String? settingsBannerHeadingEn,
  }) {
    return SettingsBannerEntity(
      settingsBannerLink: settingsBannerLink ?? this.settingsBannerLink,
      settingsBannerHeading:
          settingsBannerHeading ?? this.settingsBannerHeading,
      settingsBannerDescription:
          settingsBannerDescription ?? this.settingsBannerDescription,
      settingsBannerDescriptionEn:
          settingsBannerDescriptionEn ?? this.settingsBannerDescriptionEn,
      settingsBannerHeadingEn:
          settingsBannerHeadingEn ?? this.settingsBannerHeadingEn,
    );
  }
}
