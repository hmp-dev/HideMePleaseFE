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
  final List<RecommendationSpaceEntity> recommendationSpaceList;
  final SpaceCategory spaceCategory;

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
    required this.recommendationSpaceList,
    required this.spaceCategory,
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
        recommendationSpaceList: const [],
        spaceCategory: SpaceCategory.ENTIRE,
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
        recommendationSpaceList,
        spaceCategory,
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
    List<RecommendationSpaceEntity>? recommendationSpaceList,
    SpaceCategory? spaceCategory,
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
      recommendationSpaceList:
          recommendationSpaceList ?? this.recommendationSpaceList,
      spaceCategory: spaceCategory ?? this.spaceCategory,
    );
  }
}
