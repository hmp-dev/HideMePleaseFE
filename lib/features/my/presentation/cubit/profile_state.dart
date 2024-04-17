part of 'profile_cubit.dart';

class ProfileState extends BaseState {
  final UserEntity userProfile;
  final bool isProfileIncomplete;
  final String errorMessage;

  @override
  final RequestStatus submitStatus;

  const ProfileState({
    required this.userProfile,
    this.submitStatus = RequestStatus.initial,
    required this.isProfileIncomplete,
    required this.errorMessage,
  });

  factory ProfileState.initial() => const ProfileState(
        userProfile: UserEntity.empty(),
        submitStatus: RequestStatus.initial,
        isProfileIncomplete: false,
        errorMessage: "",
      );

  @override
  List<Object?> get props => [
        userProfile,
        submitStatus,
        isProfileIncomplete,
        errorMessage,
      ];

  @override
  ProfileState copyWith({
    UserEntity? userProfile,
    RequestStatus? submitStatus,
    bool? isProfileIncomplete,
    String? errorMessage,
  }) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      submitStatus: submitStatus ?? this.submitStatus,
      isProfileIncomplete: isProfileIncomplete ?? this.isProfileIncomplete,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
