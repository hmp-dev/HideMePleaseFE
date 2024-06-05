part of 'settings_cubit.dart';

class SettingsState extends BaseState {
  final CmsLinkEntity cmsLinkEntity;
  final List<AnnouncementEntity> announcements;
  final String errorMessage;

  @override
  final RequestStatus submitStatus;

  const SettingsState({
    required this.cmsLinkEntity,
    required this.announcements,
    required this.errorMessage,
    this.submitStatus = RequestStatus.initial,
  });

  factory SettingsState.initial() => const SettingsState(
        cmsLinkEntity: CmsLinkEntity.empty(),
        announcements: [],
        errorMessage: "",
      );

  @override
  List<Object?> get props => [
        submitStatus,
        cmsLinkEntity,
        announcements,
        errorMessage,
      ];

  @override
  SettingsState copyWith({
    CmsLinkEntity? cmsLinkEntity,
    List<AnnouncementEntity>? announcements,
    RequestStatus? submitStatus,
    String? errorMessage,
  }) {
    return SettingsState(
      cmsLinkEntity: cmsLinkEntity ?? this.cmsLinkEntity,
      announcements: announcements ?? this.announcements,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
