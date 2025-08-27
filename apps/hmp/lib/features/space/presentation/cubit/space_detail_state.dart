part of 'space_detail_cubit.dart';

class SpaceDetailState extends BaseState {
  final String errorMessage;
  final SpaceDetailEntity spaceDetailEntity;
  final BenefitEntity selectedBenefitEntity;
  final CheckInUsersResponseEntity checkInUsersResponse;
  final RequestStatus checkInUsersStatus;

  @override
  final RequestStatus submitStatus;

  const SpaceDetailState({
    this.submitStatus = RequestStatus.initial,
    required this.errorMessage,
    required this.spaceDetailEntity,
    required this.selectedBenefitEntity,
    required this.checkInUsersResponse,
    this.checkInUsersStatus = RequestStatus.initial,
  });

  factory SpaceDetailState.initial() => SpaceDetailState(
        submitStatus: RequestStatus.initial,
        errorMessage: "",
        spaceDetailEntity: const SpaceDetailEntity.empty(),
        selectedBenefitEntity: const BenefitEntity.empty(),
        checkInUsersResponse: CheckInUsersResponseEntity(
          totalCount: 0,
          users: [],
          currentGroup: null,
        ),
      );

  @override
  List<Object?> get props => [
        submitStatus,
        errorMessage,
        spaceDetailEntity,
        selectedBenefitEntity,
        checkInUsersResponse,
        checkInUsersStatus,
      ];

  @override
  SpaceDetailState copyWith({
    String? errorMessage,
    RequestStatus? submitStatus,
    bool? benefitRedeemStatus,
    SpaceDetailEntity? spaceDetailEntity,
    BenefitEntity? selectedBenefitEntity,
    CheckInUsersResponseEntity? checkInUsersResponse,
    RequestStatus? checkInUsersStatus,
  }) {
    return SpaceDetailState(
      errorMessage: errorMessage ?? this.errorMessage,
      submitStatus: submitStatus ?? this.submitStatus,
      spaceDetailEntity: spaceDetailEntity ?? this.spaceDetailEntity,
      selectedBenefitEntity:
          selectedBenefitEntity ?? this.selectedBenefitEntity,
      checkInUsersResponse: checkInUsersResponse ?? this.checkInUsersResponse,
      checkInUsersStatus: checkInUsersStatus ?? this.checkInUsersStatus,
    );
  }
}
