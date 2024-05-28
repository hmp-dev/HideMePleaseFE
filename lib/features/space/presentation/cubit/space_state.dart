part of 'space_cubit.dart';

class SpaceState extends BaseState {
  final String errorMessage;
  final SpacesResponseEntity spacesResponseEntity;
  final String selectedNftTokenAddress;
  final String nfcToken;
  final bool benefitRedeemStatus;
  final List<TopUsedNftEntity> topUsedNfts;
  final List<NewSpaceEntity> newSpaceList;
  final List<SpaceEntity> spaceList;

  @override
  final RequestStatus submitStatus;

  const SpaceState({
    this.submitStatus = RequestStatus.initial,
    required this.spacesResponseEntity,
    required this.errorMessage,
    required this.selectedNftTokenAddress,
    required this.nfcToken,
    required this.benefitRedeemStatus,
    required this.topUsedNfts,
    required this.newSpaceList,
    required this.spaceList,
  });

  factory SpaceState.initial() => SpaceState(
        submitStatus: RequestStatus.initial,
        spacesResponseEntity: SpacesResponseEntity.empty(),
        errorMessage: "",
        selectedNftTokenAddress: "",
        nfcToken: "",
        benefitRedeemStatus: false,
        topUsedNfts: const [],
        newSpaceList: const [],
        spaceList: const [],
      );

  @override
  List<Object?> get props => [
        submitStatus,
        spacesResponseEntity,
        errorMessage,
        selectedNftTokenAddress,
        nfcToken,
        benefitRedeemStatus,
        topUsedNfts,
        newSpaceList,
        spaceList,
      ];

  @override
  SpaceState copyWith({
    RequestStatus? submitStatus,
    SpacesResponseEntity? spacesResponseEntity,
    String? errorMessage,
    String? selectedNftTokenAddress,
    String? nfcToken,
    bool? benefitRedeemStatus,
    List<TopUsedNftEntity>? topUsedNfts,
    List<NewSpaceEntity>? newSpaceList,
    List<SpaceEntity>? spaceList,
  }) {
    return SpaceState(
      submitStatus: submitStatus ?? this.submitStatus,
      spacesResponseEntity: spacesResponseEntity ?? this.spacesResponseEntity,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedNftTokenAddress:
          selectedNftTokenAddress ?? this.selectedNftTokenAddress,
      nfcToken: nfcToken ?? this.nfcToken,
      benefitRedeemStatus: benefitRedeemStatus ?? this.benefitRedeemStatus,
      topUsedNfts: topUsedNfts ?? this.topUsedNfts,
      newSpaceList: newSpaceList ?? this.newSpaceList,
      spaceList: spaceList ?? this.spaceList,
    );
  }
}
