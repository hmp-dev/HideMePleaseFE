part of 'profile_cubit.dart';

class ProfileState extends BaseState {
  final BaseUserEntity baseUserData;
  final UserProfileEntity userProfileEntity;
  final bool isProfileIncomplete;
  final String errorMessage;

  @override
  final RequestStatus submitStatus;

  const ProfileState({
    required this.baseUserData,
    required this.userProfileEntity,
    this.submitStatus = RequestStatus.initial,
    required this.isProfileIncomplete,
    required this.errorMessage,
  });

  factory ProfileState.initial() => const ProfileState(
        baseUserData: BaseUserEntity.empty(),
        userProfileEntity: UserProfileEntity.empty(),
        submitStatus: RequestStatus.initial,
        isProfileIncomplete: false,
        errorMessage: "",
      );

  @override
  List<Object?> get props => [
        baseUserData,
        userProfileEntity,
        submitStatus,
        isProfileIncomplete,
        errorMessage,
      ];

  @override
  ProfileState copyWith({
    BaseUserEntity? baseUserData,
    UserProfileEntity? userProfileEntity,
    RequestStatus? submitStatus,
    bool? isProfileIncomplete,
    String? errorMessage,
  }) {
    return ProfileState(
      baseUserData: baseUserData ?? this.baseUserData,
      userProfileEntity: userProfileEntity ?? this.userProfileEntity,
      submitStatus: submitStatus ?? this.submitStatus,
      isProfileIncomplete: isProfileIncomplete ?? this.isProfileIncomplete,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
