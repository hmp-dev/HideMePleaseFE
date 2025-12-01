part of 'profile_cubit.dart';

class ProfileState extends BaseState {
  final BaseUserEntity baseUserData;
  final UserProfileEntity userProfileEntity;
  final bool isProfileIncomplete;
  final String errorMessage;
  final List<PointTransactionEntity> pointsHistory;
  final RequestStatus pointsHistoryStatus;

  @override
  final RequestStatus submitStatus;

  const ProfileState({
    required this.baseUserData,
    required this.userProfileEntity,
    this.submitStatus = RequestStatus.initial,
    required this.isProfileIncomplete,
    required this.errorMessage,
    this.pointsHistory = const [],
    this.pointsHistoryStatus = RequestStatus.initial,
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
        pointsHistory,
        pointsHistoryStatus,
      ];

  @override
  ProfileState copyWith({
    BaseUserEntity? baseUserData,
    UserProfileEntity? userProfileEntity,
    RequestStatus? submitStatus,
    bool? isProfileIncomplete,
    String? errorMessage,
    List<PointTransactionEntity>? pointsHistory,
    RequestStatus? pointsHistoryStatus,
  }) {
    return ProfileState(
      baseUserData: baseUserData ?? this.baseUserData,
      userProfileEntity: userProfileEntity ?? this.userProfileEntity,
      submitStatus: submitStatus ?? this.submitStatus,
      isProfileIncomplete: isProfileIncomplete ?? this.isProfileIncomplete,
      errorMessage: errorMessage ?? this.errorMessage,
      pointsHistory: pointsHistory ?? this.pointsHistory,
      pointsHistoryStatus: pointsHistoryStatus ?? this.pointsHistoryStatus,
    );
  }
}
