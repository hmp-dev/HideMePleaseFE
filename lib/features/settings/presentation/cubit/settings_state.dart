part of 'settings_cubit.dart';

class SettingsState extends BaseState {
  final SettingsBannerEntity settingsBannerEntity;
  final List<AnnouncementEntity> announcements;
  final String errorMessage;
  final String storeVersion;
  final String installedVersion;
  final String buildNumber;

  @override
  final RequestStatus submitStatus;

  const SettingsState({
    required this.settingsBannerEntity,
    required this.announcements,
    required this.errorMessage,
    required this.storeVersion,
    required this.installedVersion,
    required this.buildNumber,
    this.submitStatus = RequestStatus.initial,
  });

  factory SettingsState.initial() => const SettingsState(
        settingsBannerEntity: SettingsBannerEntity.empty(),
        announcements: [],
        errorMessage: "",
        storeVersion: "",
        installedVersion: "",
        buildNumber: "",
      );

  @override
  List<Object?> get props => [
        submitStatus,
        settingsBannerEntity,
        announcements,
        errorMessage,
        storeVersion,
        installedVersion,
        buildNumber,
      ];

  @override
  SettingsState copyWith({
    SettingsBannerEntity? settingsBannerEntity,
    List<AnnouncementEntity>? announcements,
    RequestStatus? submitStatus,
    String? errorMessage,
    String? storeVersion,
    String? installedVersion,
    String? buildNumber,
  }) {
    return SettingsState(
      settingsBannerEntity: settingsBannerEntity ?? this.settingsBannerEntity,
      announcements: announcements ?? this.announcements,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      storeVersion: storeVersion ?? this.storeVersion,
      installedVersion: installedVersion ?? this.installedVersion,
      buildNumber: buildNumber ?? this.buildNumber,
    );
  }
}
