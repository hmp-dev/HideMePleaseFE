part of 'member_details_cubit.dart';

class MemberDetailsState extends BaseState {
  final UserProfileEntity profile;
  @override
  final RequestStatus status;

  const MemberDetailsState({
    required this.profile,
    required this.status,
  });

  factory MemberDetailsState.initial() => const MemberDetailsState(
        profile: UserProfileEntity.empty(),
        status: RequestStatus.initial,
      );

  @override
  List<Object?> get props => [
        profile,
        status,
      ];

  @override
  MemberDetailsState copyWith({
    UserProfileEntity? profile,
    RequestStatus? status,
  }) {
    return MemberDetailsState(
      profile: profile ?? this.profile,
      status: status ?? this.status,
    );
  }
}
