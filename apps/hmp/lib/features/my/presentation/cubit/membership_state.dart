part of 'membership_cubit.dart';

class MembershipState extends BaseState {
  final List<SelectedNFTEntity> selectedNftTokensList;
  @override
  final RequestStatus status;

  const MembershipState({
    required this.selectedNftTokensList,
    required this.status,
  });

  factory MembershipState.initial() => const MembershipState(
        selectedNftTokensList: [],
        status: RequestStatus.initial,
      );

  @override
  List<Object?> get props => [
        selectedNftTokensList,
        status,
      ];

  @override
  MembershipState copyWith({
    List<SelectedNFTEntity>? selectedNftTokensList,
    RequestStatus? status,
  }) {
    return MembershipState(
      selectedNftTokensList:
          selectedNftTokensList ?? this.selectedNftTokensList,
      status: status ?? this.status,
    );
  }
}
