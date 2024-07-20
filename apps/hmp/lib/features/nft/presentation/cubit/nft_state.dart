part of 'nft_cubit.dart';

class NftState extends BaseState {
  final NftCollectionsGroupEntity nftCollectionsGroupEntity;
  final List<SelectedNFTEntity> selectedNftTokensList;
  final List<SelectedNFTEntity> nftsListHome;
  final DateTime collectionFetchTime;
  final String errorMessage;
  final String selectedChain;
  final WelcomeNftEntity welcomeNftEntity;
  final String consumeWelcomeNftUrl;
  final List<BenefitEntity> nftBenefitList;
  final List<NftPointsEntity> nftPointsList;
  final NftNetworkEntity nftNetworkEntity;
  final NftUsageHistoryEntity nftUsageHistoryEntity;
  final BenefitUsageType benefitUsageType;
  final bool isLoadingMore;
  final String nextCursor;
  final int selectedCollectionCount;
  @override
  final RequestStatus submitStatus;

  const NftState({
    required this.nftCollectionsGroupEntity,
    required this.selectedNftTokensList,
    required this.nftsListHome,
    required this.collectionFetchTime,
    this.submitStatus = RequestStatus.initial,
    required this.errorMessage,
    required this.selectedChain,
    required this.welcomeNftEntity,
    required this.consumeWelcomeNftUrl,
    required this.nftBenefitList,
    required this.nftPointsList,
    required this.nftNetworkEntity,
    required this.nftUsageHistoryEntity,
    required this.isLoadingMore,
    required this.benefitUsageType,
    required this.nextCursor,
    required this.selectedCollectionCount,
  });

  factory NftState.initial() => NftState(
        nftCollectionsGroupEntity: NftCollectionsGroupEntity.empty(),
        selectedNftTokensList: const [],
        nftsListHome: const [],
        collectionFetchTime: DateTime.now(),
        submitStatus: RequestStatus.initial,
        errorMessage: "",
        selectedChain: ChainType.ALL.name,
        welcomeNftEntity: const WelcomeNftEntity.empty(),
        consumeWelcomeNftUrl: "",
        nftBenefitList: const [],
        nftPointsList: const [],
        nftNetworkEntity: const NftNetworkEntity.empty(),
        nftUsageHistoryEntity: NftUsageHistoryEntity.empty(),
        isLoadingMore: false,
        benefitUsageType: BenefitUsageType.ENTIRE,
        nextCursor: "",
        selectedCollectionCount: 0,
      );

  // int get selectedCollectionCount => nftCollectionsGroupEntity.collections.fold(
  //     0,
  //     (value, element) =>
  //         element.tokens.where((element) => element.selected).length + value);

  int get maxSelectableCount => 3;

  @override
  List<Object?> get props => [
        nftCollectionsGroupEntity,
        selectedNftTokensList,
        nftsListHome,
        collectionFetchTime,
        submitStatus,
        errorMessage,
        selectedChain,
        welcomeNftEntity,
        consumeWelcomeNftUrl,
        nftBenefitList,
        nftPointsList,
        nftNetworkEntity,
        nftUsageHistoryEntity,
        isLoadingMore,
        benefitUsageType,
        nextCursor,
        selectedCollectionCount,
      ];

  @override
  NftState copyWith({
    NftCollectionsGroupEntity? nftCollectionsGroupEntity,
    List<SelectedNFTEntity>? selectedNftTokensList,
    List<SelectedNFTEntity>? nftsListHome,
    DateTime? collectionFetchTime,
    RequestStatus? submitStatus,
    bool? isProfileIncomplete,
    String? errorMessage,
    String? selectedChain,
    WelcomeNftEntity? welcomeNftEntity,
    String? consumeWelcomeNftUrl,
    List<BenefitEntity>? nftBenefitList,
    List<NftPointsEntity>? nftPointsList,
    NftNetworkEntity? nftNetworkEntity,
    NftUsageHistoryEntity? nftUsageHistoryEntity,
    bool? isLoadingMore,
    BenefitUsageType? benefitUsageType,
    String? nextCursor,
    int? selectedCollectionCount,
  }) {
    return NftState(
      nftCollectionsGroupEntity:
          nftCollectionsGroupEntity ?? this.nftCollectionsGroupEntity,
      selectedNftTokensList:
          selectedNftTokensList ?? this.selectedNftTokensList,
      nftsListHome: nftsListHome ?? this.nftsListHome,
      collectionFetchTime: collectionFetchTime ?? this.collectionFetchTime,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedChain: selectedChain ?? this.selectedChain,
      welcomeNftEntity: welcomeNftEntity ?? this.welcomeNftEntity,
      consumeWelcomeNftUrl: consumeWelcomeNftUrl ?? this.consumeWelcomeNftUrl,
      nftBenefitList: nftBenefitList ?? this.nftBenefitList,
      nftPointsList: nftPointsList ?? this.nftPointsList,
      nftNetworkEntity: nftNetworkEntity ?? this.nftNetworkEntity,
      nftUsageHistoryEntity:
          nftUsageHistoryEntity ?? this.nftUsageHistoryEntity,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      benefitUsageType: benefitUsageType ?? this.benefitUsageType,
      nextCursor: nextCursor ?? this.nextCursor,
      selectedCollectionCount:
          selectedCollectionCount ?? this.selectedCollectionCount,
    );
  }

  @override
  String toString() {
    return 'NftState(nftCollectionsGroupEntity: $nftCollectionsGroupEntity, selectedNftTokensList: $selectedNftTokensList, nftsListHome: $nftsListHome, collectionFetchTime: $collectionFetchTime, errorMessage: $errorMessage, selectedChain: $selectedChain, welcomeNftEntity: $welcomeNftEntity, consumeWelcomeNftUrl: $consumeWelcomeNftUrl, nftBenefitList: $nftBenefitList, nftPointsList: $nftPointsList, nftNetworkEntity: $nftNetworkEntity, nftUsageHistoryEntity: $nftUsageHistoryEntity, benefitUsageType: $benefitUsageType, isLoadingMore: $isLoadingMore, nextCursor: $nextCursor, selectedCollectionCount: $selectedCollectionCount, submitStatus: $submitStatus)';
  }
}
