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
  final List<NftBenefitEntity> nftBenefitList;
  final List<NftPointsEntity> nftPointsList;
  final NftNetworkEntity nftNetworkEntity;
  final NftUsageHistoryEntity nftUsageHistoryEntity;
  final bool isLoadingMore;

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
      );

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
    List<NftBenefitEntity>? nftBenefitList,
    List<NftPointsEntity>? nftPointsList,
    NftNetworkEntity? nftNetworkEntity,
    NftUsageHistoryEntity? nftUsageHistoryEntity,
    bool? isLoadingMore,
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
    );
  }
}
