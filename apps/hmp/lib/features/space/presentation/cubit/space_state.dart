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
  final SpaceDetailEntity spaceDetailEntity;
  final BenefitsGroupEntity benefitsGroupEntity;
  final bool isLoadingMoreFetch;
  final String currentSpaceId;
  final bool allSpacesLoaded;
  final RequestStatus loadingMoreStatus;
  final int spacesPage;
  final SpaceEntity? selectedSpace;
  
  // Check-in tracking fields
  final String? currentCheckedInSpaceId;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final DateTime? checkInTime;

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
    required this.spaceDetailEntity,
    required this.benefitsGroupEntity,
    required this.isLoadingMoreFetch,
    required this.currentSpaceId,
    required this.allSpacesLoaded,
    required this.loadingMoreStatus,
    required this.spacesPage,
    this.selectedSpace,
    this.currentCheckedInSpaceId,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInTime,
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
    spaceDetailEntity: const SpaceDetailEntity.empty(),
    benefitsGroupEntity: BenefitsGroupEntity.empty(),
    isLoadingMoreFetch: false,
    currentSpaceId: "",
    allSpacesLoaded: false,
    loadingMoreStatus: RequestStatus.initial,
    spacesPage: 1,
    selectedSpace: null,
    currentCheckedInSpaceId: null,
    checkInLatitude: null,
    checkInLongitude: null,
    checkInTime: null,
  );

  //bool get isLoadingMore => loadingMoreStatus == RequestStatus.loading;

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
    spaceDetailEntity,
    benefitsGroupEntity,
    isLoadingMoreFetch,
    currentSpaceId,
    allSpacesLoaded,
    loadingMoreStatus,
    spacesPage,
    selectedSpace,
    currentCheckedInSpaceId,
    checkInLatitude,
    checkInLongitude,
    checkInTime,
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
    SpaceDetailEntity? spaceDetailEntity,
    BenefitsGroupEntity? benefitsGroupEntity,
    bool? isLoadingMoreFetch,
    String? currentSpaceId,
    bool? allSpacesLoaded,
    RequestStatus? loadingMoreStatus,
    int? spacesPage,
    SpaceEntity? selectedSpace,
    bool clearSelectedSpace = false,
    String? currentCheckedInSpaceId,
    double? checkInLatitude,
    double? checkInLongitude,
    DateTime? checkInTime,
    bool clearCheckInData = false,
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
      spaceDetailEntity: spaceDetailEntity ?? this.spaceDetailEntity,
      benefitsGroupEntity: benefitsGroupEntity ?? this.benefitsGroupEntity,
      isLoadingMoreFetch: isLoadingMoreFetch ?? this.isLoadingMoreFetch,
      currentSpaceId: currentSpaceId ?? this.currentSpaceId,
      allSpacesLoaded: allSpacesLoaded ?? this.allSpacesLoaded,
      loadingMoreStatus: loadingMoreStatus ?? this.loadingMoreStatus,
      spacesPage: spacesPage ?? this.spacesPage,
      selectedSpace: clearSelectedSpace ? null : selectedSpace ?? this.selectedSpace,
      currentCheckedInSpaceId: clearCheckInData ? null : currentCheckedInSpaceId ?? this.currentCheckedInSpaceId,
      checkInLatitude: clearCheckInData ? null : checkInLatitude ?? this.checkInLatitude,
      checkInLongitude: clearCheckInData ? null : checkInLongitude ?? this.checkInLongitude,
      checkInTime: clearCheckInData ? null : checkInTime ?? this.checkInTime,
    );
  }
}