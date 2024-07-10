import 'package:equatable/equatable.dart';

class SettingsBannerEntity extends Equatable {
  final String settingsBannerLink;
  final String settingsBannerHeading;
  final String settingsBannerDescription;

  const SettingsBannerEntity({
    required this.settingsBannerLink,
    required this.settingsBannerHeading,
    required this.settingsBannerDescription,
  });

  @override
  List<Object?> get props => [
        settingsBannerLink,
        settingsBannerHeading,
        settingsBannerDescription,
      ];

  const SettingsBannerEntity.empty()
      : settingsBannerLink = '',
        settingsBannerHeading = '',
        settingsBannerDescription = '';

  SettingsBannerEntity copyWith({
    String? settingsBannerLink,
    String? settingsBannerHeading,
    String? settingsBannerDescription,
  }) {
    return SettingsBannerEntity(
      settingsBannerLink: settingsBannerLink ?? this.settingsBannerLink,
      settingsBannerHeading:
          settingsBannerHeading ?? this.settingsBannerHeading,
      settingsBannerDescription:
          settingsBannerDescription ?? this.settingsBannerDescription,
    );
  }
}
