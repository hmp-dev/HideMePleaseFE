part of 'settings_cubit.dart';

class SettingsState extends BaseState {
  final CmsLinkEntity cmsLinkEntity;
  final String errorMessage;

  @override
  final RequestStatus submitStatus;

  const SettingsState({
    required this.cmsLinkEntity,
    required this.errorMessage,
    this.submitStatus = RequestStatus.initial,
  });

  factory SettingsState.initial() => const SettingsState(
        cmsLinkEntity: CmsLinkEntity.empty(),
        errorMessage: "",
      );

  @override
  List<Object?> get props => [
        submitStatus,
        cmsLinkEntity,
        errorMessage,
      ];

  @override
  SettingsState copyWith({
    CmsLinkEntity? cmsLinkEntity,
    RequestStatus? submitStatus,
    String? errorMessage,
  }) {
    return SettingsState(
      cmsLinkEntity: cmsLinkEntity ?? this.cmsLinkEntity,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
